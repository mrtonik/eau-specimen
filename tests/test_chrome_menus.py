#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""B-tier visual: NSPopUpButton menu pixels — popup style + pulldown style
(NSPopUpButton+Eau.m / NSMenuView+Eau.m / NSMenuItemCell+Eau.m).

A popup is the one menu kind that renders WITHOUT the external Gershwin Menu
server (the global Mac-style bar needs that server, which we deliberately don't
run in the sandbox — it registers a host-global DO name and would collide with
the user's live desktop). The popup pops its own NSMenuView window, so it
exercises Eau's menu-item drawing (selection highlight, item layout) directly.

Each popup is captured in its OWN Xephyr session: once opened via synthetic
mouse-down the tracking loop does not release on a synthetic mouse-up/Escape
(harness finding), so we cannot open a second menu in the same app instance.
"""

import time
import traceback

import screenshot as S
from spec_harness import Bridge, Session, Test
from xephyr import Xephyr


def capture_menu(t, identifier, case, expect_blue_sel):
    """Fresh Xephyr+Chrome; open one popup, golden its menu window."""
    with Xephyr(1100, 700) as xeph:
        with Session("Chrome", display=xeph.display) as s:
            b = s.bridge
            d = b.dump()
            main = b.main_window_box()
            w = Bridge.widget(d, identifier=identifier)
            t.ok(w is not None, "%s: popup widget present" % case)
            b.mouse_down(w)
            time.sleep(0.5)

            # the menu is the only extra top-level window in this clean session
            box = None
            for xw in b.x11_windows():
                if xw["id"] != main["id"] and xw["width"] > 60 and xw["height"] > 30:
                    box = xw
                    break
            t.ok(box is not None, "%s: menu window opened (frontmost in Xephyr)" % case)
            if box:
                shot = S.capture(box["id"], "/tmp/spec_chrome_%s.png" % case,
                                 display=xeph.display)
                if expect_blue_sel:
                    # selected item (Bravo, the middle of 3) draws a blue Eau
                    # highlight; sample its centre
                    px = S.sample_pixel(shot, box["width"] / 2.0, box["height"] / 2.0)
                    t.ok(px is not None and px[2] > px[0] and px[2] > 120,
                         "%s: selected item highlighted blue rgb=%s" % (case, px))
                ok, msg = S.compare_golden("chrome", case, shot, tolerance=0)
                t.ok(ok, "%s golden: %s" % (case, msg))
            b.mouse_up()


def main():
    t = Test("chrome_menus")
    try:
        capture_menu(t, "Popup", "popup", expect_blue_sel=True)
        capture_menu(t, "Pulldown", "pulldown", expect_blue_sel=False)
    except SystemExit:
        raise
    except Exception:
        t.fail("session/setup", traceback.format_exc())
    t.done()


if __name__ == "__main__":
    main()
