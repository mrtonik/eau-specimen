#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Smoke test for the generalized UIBridgeServer's x11_chord tool, driven against
a real GNUstep app (the TextInput specimen) inside a private Xephyr.

Proof design: focus an empty editable NSTextField, then build a string with a
mix of chorded and plain input —

    x11_chord(shift, "a")  -> "A"      (modifier held by the chord)
    x11_chord(shift, "b")  -> "B"      (modifier held by the chord)
    x11_type("c")          -> "c"      (no modifier; lowercase)
    x11_chord(key="Return")            (no modifiers + a named keysym -> commit)

If the field then reads exactly "ABc", x11_chord demonstrably held Shift
(uppercase A/B) while plain typing did not (lowercase c), and released it after.
The committed value is read from the live UIBridge tree (find_widgets), not the
JSON state-dump: GNUstep suspends the app's dump timer while a field editor is
active, so the dump goes stale mid-edit even though the app is fine.

Requires the generalized server:

    UIBRIDGE_SERVER=~/build/uibridge-series/Server/obj/UIBridgeServer \\
        python3.11 test_chord_smoke.py
"""

import re
import time

from spec_harness import Bridge, run_xephyr

FIELD = "Field empty"   # identifier == caption of the empty editable NSTextField


def chord(b, key, mods=None):
    return b.c.call_json("x11_chord", {"modifiers": mods or [], "key": key})


def field_value_at(b, x, w, tol=4):
    """Live stringValue of the NSTextField at GNUstep screen x/width (via the live
    tree, since the dump timer is suspended while a field editor holds focus)."""
    for h in b.find(cls="NSTextField", visible_only=False):
        m = re.findall(r"[-\d.]+", h.get("screen_frame") or "")
        if len(m) >= 3 and abs(float(m[0]) - x) <= tol and abs(float(m[2]) - w) <= tol:
            return h.get("stringValue")
    return None


def body(t, sess, xeph):
    b = sess.bridge

    names = {tool.get("name") for tool in (b.c.list_tools() or [])}
    t.ok("x11_chord" in names, "server advertises x11_chord tool")

    f = Bridge.widget(b.dump(), identifier=FIELD)
    t.ok(f is not None, "found empty editable NSTextField ('%s')" % FIELD)
    if not f:
        return
    sf = f["screenFrame"]
    t.eq(f.get("stringValue"), "", "field starts empty")

    # Focus the field's editor (XTEST click via the dump's screenFrame).
    xid = b.main_window_xid()
    if xid:
        b.activate(xid)
    b.click_dump_widget(f)
    time.sleep(0.5)

    # Build "ABc": uppercase via chord(shift, ...), lowercase via plain type.
    chord(b, "a", ["shift"])
    chord(b, "b", ["shift"])
    b.type_text("c")
    chord(b, "Return")          # commit; exercises a named keysym with no modifiers
    time.sleep(0.4)

    val = field_value_at(b, sf["x"], sf["w"])
    t.eq(val, "ABc",
         "chord(shift+a)+chord(shift+b)+type(c) -> 'ABc' (chord holds Shift, plain type does not)")
    t.ok(sess.app.alive(), "TextInput survived chord input")


if __name__ == "__main__":
    run_xephyr("chord_smoke", "TextInput", body)
