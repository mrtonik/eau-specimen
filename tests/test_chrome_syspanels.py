#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""B-tier visual (stretch): the shared system panels NSColorPanel + NSFontPanel,
opened in-app and driven inside a private Xephyr.

NSColorPanel's default content is deterministic, so it is golden'd. NSFontPanel
lists the machine's installed font families (system-dependent), so it is checked
structurally (opens, is a panel of the expected size, no crash) and its shot is
saved for the record rather than pixel-compared. Both exercise Eau control
theming (color wheel/sliders/swatches; font lists + the blue Set default).

NB out of scope: NSOpenPanel/NSSavePanel run out-of-process via GWorkspace on
Gershwin — a different harness; not attempted here.
"""

import os
import time

import screenshot as S
from spec_harness import Bridge, run_xephyr

ARTIFACTS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "artifacts", "chrome")


def open_panel(b, ident, w, h, tol=8, settle=1.0):
    b.click_dump_widget(Bridge.widget(b.dump(), identifier=ident))
    time.sleep(settle)
    return b.window_box_by_size(w, h, tol=tol)


def body(t, sess, xeph):
    b = sess.bridge
    b.dump()

    # --- NSColorPanel (deterministic default -> golden) ---
    color = open_panel(b, "ShowColor", 200, 270)
    t.ok(color is not None, "NSColorPanel opened without crashing")
    if color:
        b.park_mouse()
        shot = S.capture(color["id"], "/tmp/spec_chrome_color.png", display=xeph.display)
        ok, msg = S.compare_golden("chrome", "color", shot, tolerance=0)
        t.ok(ok, "color panel golden: %s" % msg)

    # --- NSFontPanel (system-dependent font list -> structural only) ---
    font = open_panel(b, "ShowFont", 320, 300)
    t.ok(font is not None, "NSFontPanel opened without crashing")
    if font:
        b.park_mouse()
        os.makedirs(ARTIFACTS, exist_ok=True)
        S.capture(font["id"], os.path.join(ARTIFACTS, "font.png"), display=xeph.display)
        t.ok(font["w"] >= 300 and font["h"] >= 260,
             "font panel laid out at expected size (%dx%d)" % (font["w"], font["h"]))

    try:
        b.dump(); alive = True
    except Exception:
        alive = False
    t.ok(alive, "Chrome app survived opening both system panels")


if __name__ == "__main__":
    run_xephyr("chrome_syspanels", "Chrome", body)
