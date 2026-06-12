#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Smoke test for the generalized UIBridgeServer's arbitrary-Unicode x11_type
path, driven against a real GNUstep app (TextInput) inside a private Xephyr.

Characters that have no key on the active layout are typed by temporarily binding
the codepoint to a spare keycode (the xdotool technique). This exercises all
three bands:

  - ASCII + Latin-1 accents (é): keysym is the bare codepoint (U+0000..U+00FF);
  - BMP non-Latin (中 文 λ): direct-Unicode keysym 0x01000000 + codepoint;
  - astral (emoji 😀): UTF-16 surrogate pair combined into one scalar > 0xFFFF.

The committed value is read from the live UIBridge tree (find_widgets), not the
JSON state-dump, because GNUstep suspends the dump timer while a field editor is
focused (see test_chord_smoke.py).

Requires the generalized server:

    UIBRIDGE_SERVER=~/build/uibridge-series/Server/obj/UIBridgeServer \\
        python3.11 test_unicode_smoke.py
"""

import re
import time

from spec_harness import Bridge, run_xephyr

FIELD = "Field empty"


def field_value_at(b, x, w, tol=4):
    for h in b.find(cls="NSTextField", visible_only=False):
        m = re.findall(r"[-\d.]+", h.get("screen_frame") or "")
        if len(m) >= 3 and abs(float(m[0]) - x) <= tol and abs(float(m[2]) - w) <= tol:
            return h.get("stringValue")
    return None


def body(t, sess, xeph):
    b = sess.bridge

    f = Bridge.widget(b.dump(), identifier=FIELD)
    t.ok(f is not None, "found empty editable NSTextField ('%s')" % FIELD)
    if not f:
        return
    sf = f["screenFrame"]
    t.eq(f.get("stringValue"), "", "field starts empty")

    xid = b.main_window_xid()
    if xid:
        b.activate(xid)
    b.click_dump_widget(f)
    time.sleep(0.5)

    cases = [
        ("café", "ASCII + Latin-1 accent (é), bare-codepoint keysym"),
        ("中文λ", "BMP CJK + Greek, direct-Unicode keysym"),
        ("ab\U0001f600cd", "astral emoji (surrogate pair) -> scalar > 0xFFFF"),
    ]
    for text, desc in cases:
        b.type_text(text)
        time.sleep(0.4)
        got = field_value_at(b, sf["x"], sf["w"])
        t.eq(got, text, "x11_type round-trips %r (%s)" % (text, desc))
        b.type_text("\x08" * 24)   # backspace clear for the next case
        time.sleep(0.2)

    t.ok(sess.app.alive(), "TextInput survived Unicode input")


if __name__ == "__main__":
    run_xephyr("unicode_smoke", "TextInput", body)
