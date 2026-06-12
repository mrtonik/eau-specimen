#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""1E — dynamic interaction / state-transition tests via real XTEST input.

Drives the patched UIBridgeServer (point UIBRIDGE_SERVER at it) inside a private
Xephyr (app frontmost), then asserts the state actually changed:

  A. mouse: click an NSButton checkbox -> dump state 0->1->0 (bidirectional, so it
     proves real input, not luck).
  B. keyboard: focus an empty NSTextField, type -> its live-tree stringValue
     updates (read live tree, not the dump: the dump timer is suspended while a
     field editor holds focus).
  C. keyboard: Tab from a focused field -> the focused field editor moves to the
     next key view (informational).
"""
import os, re, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "tests"))   # suite spec_harness/screenshot
_GS = os.environ.get("GOLDSTEP_DIR") or os.path.expanduser("~/build/goldstep")
if os.path.isdir(_GS) and _GS not in sys.path:
    sys.path.insert(0, _GS)
import spec_harness as SH                         # noqa: E402
from goldstep.xephyr import Xephyr                # noqa: E402

R = []
def chk(name, cond, detail=""):
    R.append(bool(cond))
    print("  %s %s%s" % ("PASS" if cond else "FAIL", name,
                          (" [%s]" % detail) if detail else ""), flush=True)


def state_of(b, ident):
    w = SH.Bridge.widget(b.dump(), identifier=ident)
    return w.get("state") if w else None


def live_field_value(b, screen_frame, tol=4):
    """stringValue of the NSTextField matching the dump screenFrame x/w, read from
    the LIVE tree (dump is stale while the field editor has focus)."""
    fx, fw = screen_frame["x"], screen_frame["w"]
    for hnd in b.find(cls="NSTextField", visible_only=False):
        m = re.findall(r"[-\d.]+", hnd.get("screen_frame") or "")
        if len(m) >= 3 and abs(float(m[0]) - fx) <= tol and abs(float(m[2]) - fw) <= tol:
            return hnd.get("stringValue")
    return None


def focused_ident(b):
    for w in b.dump().get("widgets", []):
        if w.get("firstResponder"):
            return w.get("identifier")
    return None


def main():
    # ---- A: mouse-driven checkbox toggle (Buttons) ----
    print("[1E/A] checkbox toggle via XTEST click (Buttons)", flush=True)
    with Xephyr(1280, 900) as xeph:
        with SH.Session("Buttons", display=xeph.display, ready_timeout=60,
                        require_dump=True) as s:
            b = s.bridge
            cb = SH.Bridge.widget(b.dump(), identifier="Check off")
            xid = b.main_window_xid()
            if xid:
                b.activate(xid)
            s0 = cb.get("state")
            b.click_dump_widget(cb); time.sleep(0.8); s1 = state_of(b, "Check off")
            b.click_dump_widget(cb); time.sleep(0.8); s2 = state_of(b, "Check off")
            chk("click toggles off->on", s0 == 0 and s1 == 1, "state %s->%s" % (s0, s1))
            chk("click toggles on->off", s1 == 1 and s2 == 0, "state %s->%s" % (s1, s2))

    # ---- B/C: keyboard into a text field (TextInput) ----
    print("[1E/B] type + Tab via XTEST (TextInput)", flush=True)
    with Xephyr(1280, 900) as xeph:
        with SH.Session("TextInput", display=xeph.display, ready_timeout=60,
                        require_dump=True) as s:
            b = s.bridge
            f = SH.Bridge.widget(b.dump(), identifier="Field empty")
            sf = f["screenFrame"]
            before = f.get("stringValue")
            xid = b.main_window_xid()
            if xid:
                b.activate(xid)
            b.click_dump_widget(f); time.sleep(0.5)
            foc_before = focused_ident(b)              # may be stale (editor active)
            b.type_text("ab")
            b.c.call_json("x11_chord", {"modifiers": [], "key": "c"})  # -> "abc"
            time.sleep(0.4)
            val = live_field_value(b, sf)
            chk("typing updates field value", (before in ("", None)) and val == "abc",
                "value %r->%r" % (before, val))
            # commit, then Tab to move the key view
            b.c.call_json("x11_chord", {"modifiers": [], "key": "Return"}); time.sleep(0.4)
            b.c.call_json("x11_chord", {"modifiers": [], "key": "Tab"}); time.sleep(0.5)
            foc_after = focused_ident(b)
            chk("Tab moves first responder (info)", True,
                "focus %r -> %r" % (foc_before, foc_after))

    print("\n[1E] %d/%d interaction assertions passed" % (sum(R), len(R)), flush=True)


if __name__ == "__main__":
    main()
