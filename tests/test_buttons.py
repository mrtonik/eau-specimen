#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Buttons specimen: state + geometry assertions, then a golden-image check.

Exercises Eau+Button.m / NSButtonCell+Eau.m / NSCell+Eau.m across push/checkbox/
radio variants and states (normal, disabled, default, pressed, on/off/mixed).
"""

import time

import metrics as M
import screenshot as S
from spec_harness import Bridge, run


def body(t, sess):
    b = sess.bridge
    dump = b.dump()

    def w(idn):
        return Bridge.widget(dump, identifier=idn)

    # ---- presence ----
    widgets = dump.get("widgets", [])
    t.eq(len(widgets), 29, "29 widgets registered (incl. 12 bezel styles)")
    # every bezel-style button rendered (the app didn't crash drawing any of them)
    for name in ["Disclosure", "Help", "Circular", "Recessed", "TexRound", "RoundRect"]:
        t.ok(w(name) is not None, "bezel style %r present (no crash rendering it)" % name)

    # ---- state (ground truth the UIBridge can't see) ----
    t.eq(w("Normal").get("enabled"), True, "Normal enabled")
    t.eq(w("Disabled").get("enabled"), False, "Disabled is disabled")
    t.eq(w("Default").get("isDefault"), True, "Default is the window default button")
    t.eq(w("Pressed").get("highlighted"), True, "Pressed cell is highlighted")
    t.eq(w("Check off").get("state"), 0, "Checkbox off state=0")
    t.eq(w("Check on").get("state"), 1, "Checkbox on state=1")
    t.eq(w("Check mixed").get("state"), -1, "Checkbox mixed state=-1")
    t.eq(w("Check disabled").get("enabled"), False, "Disabled checkbox is disabled")

    # NSSwitch (Eau+Switch.m — new theming)
    t.eq(w("Switch off").get("class"), "NSSwitch", "Switch off is an NSSwitch")
    t.eq(w("Switch off").get("state"), 0, "Switch off state=0")
    t.eq(w("Switch on").get("state"), 1, "Switch on state=1")
    t.eq(w("Switch disabled").get("enabled"), False, "Disabled switch is disabled")

    # A1: hidden state
    t.eq(w("Hidden").get("hidden"), True, "hidden button reports hidden=true")

    # nothing steals the focus ring at rest (deterministic golden)
    t.ok(not any(x.get("firstResponder") for x in widgets), "no widget holds focus at rest")

    # ---- geometry vs Eau metrics ----
    def h(idn):
        f = M.frame_of(w(idn).get("windowFrame"))
        return f[3] if f else None

    def width(idn):
        f = M.frame_of(w(idn).get("windowFrame"))
        return f[2] if f else None

    t.approx(h("Normal"), M.BUTTON_HEIGHT, 1, "Normal push button height ~20")
    t.approx(h("Default"), M.BUTTON_HEIGHT, 1, "Default push button height ~20")
    t.approx(h("Small"), M.BUTTON_SMALL_HEIGHT, 1, "Small push button height ~17")
    t.ok(width("Normal") >= M.BUTTON_MIN_WIDTH - 0.5, "Normal width >= 69 min")

    # ---- UIBridge cross-check: find by tag returns matching enabled flag ----
    norm_tag = w("Normal").get("tag")
    hit = b.by_tag(norm_tag)
    t.ok(hit is not None and hit.get("title") == "Normal", "find_widgets by tag locates Normal")

    # ---- golden image ----
    box = b.main_window_box()
    t.ok(box is not None, "found main window to screenshot")
    if box:
        b.activate(box["id"])
        shot = S.capture(box["id"], "/tmp/spec_buttons_static.png")

        # The default button pulses (Eau DefaultButtonAnimation); mask its region
        # so the rest of the window compares pixel-exactly, and verify its blue
        # default styling separately by sampling the button centre.
        _, sh = b.screen_size()
        dsf = w("Default").get("screenFrame")
        drect = S.screen_frame_to_image(dsf, box, sh, pad=4)
        cx, cy = drect[0] + drect[2] / 2, drect[1] + drect[3] / 2
        rgb = S.sample_pixel(shot, cx, cy)
        t.ok(rgb is not None and rgb[2] > rgb[0] + 20 and rgb[2] > 120,
             "default button renders blue (centre=%s)" % (rgb,))

        ok, msg = S.compare_golden("buttons", "static", shot, tolerance=0,
                                   mask_rects=[drect])
        t.ok(ok, "buttons static golden (default masked): %s" % msg)

        # ---- A1: interactive transient states on the "Normal" button ----
        norm = w("Normal")
        region = S.screen_frame_to_image(norm.get("screenFrame"), box, sh, pad=3)
        golden = S.GOLDENS + "/buttons/static.png"

        # live press: holding the mouse down should render the button pressed
        b.activate(box["id"]); b.park_mouse(); time.sleep(0.2)
        b.mouse_down(norm); time.sleep(0.35)
        pressed = S.capture(box["id"], "/tmp/spec_buttons_pressed.png")
        b.mouse_up(); time.sleep(0.2)
        pdelta = S.crop_ae(golden, pressed, region)
        t.ok(pdelta and pdelta > 0,
             "live mouse-down renders the button pressed (delta=%s px)" % pdelta)

        # hover: record whether Eau draws any button hover state (informational)
        b.park_mouse(); time.sleep(0.2)
        b.hover(norm); time.sleep(0.35)
        hov = S.capture(box["id"], "/tmp/spec_buttons_hover.png")
        b.park_mouse()
        hdelta = S.crop_ae(golden, hov, region)
        t.ok(True, "hover delta=%s px (Eau button hover state: %s)"
             % (hdelta, "present" if (hdelta or 0) > 0 else "none"))

        # the app must survive the interaction (records any crash)
        try:
            b.dump(); alive = True
        except Exception:
            alive = False
        t.ok(alive, "app survived hover/press interaction (no crash)")


if __name__ == "__main__":
    run("buttons", "Buttons", body)
