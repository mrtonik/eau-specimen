#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""B-tier visual: NSPanel (utility window), a document sheet, and an NSDrawer —
the frontmost-only chrome deferred from the A-tier Windows specimen.

Driven inside a private Xephyr (the specimen is the only client, so these stay
up). Each is a separate top-level window matched by its known size and captured
by xid. Panel/sheet carry a default button that pulses (Eau DefaultButton-
Animation), so that button is masked and separately sampled for blue. The drawer
is static. NB: with no window manager in the sandbox GNUstep does not draw the
titlebar/sheet-edge decoration here (the document-window titlebar body is golden
ed on the real WM in test_windows); this covers the panel/sheet/drawer *bodies*.
"""

import re
import time

import screenshot as S
from spec_harness import Bridge, run_xephyr


def _sf(s):
    nums = re.findall(r"[-\d.]+", s or "")
    if len(nums) < 4:
        return None
    x, y, w, h = (float(n) for n in nums[:4])
    return {"x": x, "y": y, "w": w, "h": h}


def default_button_mask(b, box, title):
    """Image-space mask rect for the pulsing default button (found by title), or
    [] if not found. Also returns its centre for a blue spot-check."""
    btn = b.alert_button(title)
    sf = _sf(btn.get("screen_frame")) if btn else None
    if not sf:
        return [], None
    _, screen_h = b.screen_size()
    rx, ry, rw, rh = S.screen_frame_to_image(sf, box, screen_h, pad=4)
    return [(rx, ry, rw, rh)], (rx + rw / 2.0, ry + rh / 2.0)


def golden_window(t, b, xeph, box, case, default_title=None):
    b.park_mouse()
    shot = S.capture(box["id"], "/tmp/spec_chrome_%s.png" % case, display=xeph.display)
    mask = []
    if default_title:
        mask, centre = default_button_mask(b, box, default_title)
        if centre:
            px = S.sample_pixel(shot, *centre)
            t.ok(px is not None and px[2] > px[0] and px[2] > 100,
                 "%s default button is blue rgb=%s" % (case, px))
    ok, msg = S.compare_golden("chrome", case, shot, tolerance=0, mask_rects=mask)
    t.ok(ok, "%s golden%s: %s" % (case, " (default masked)" if mask else "", msg))


def body(t, sess, xeph):
    b = sess.bridge
    b.dump()

    # --- NSPanel (utility) ---
    b.click_dump_widget(Bridge.widget(b.dump(), identifier="ShowPanel"))
    time.sleep(0.6)
    panel = b.window_box_by_size(280, 130, tol=6)
    t.ok(panel is not None, "NSPanel opened (utility window)")
    if panel:
        golden_window(t, b, xeph, panel, "panel", default_title="OK")

    # --- sheet (attached to main window) ---
    b.click_dump_widget(Bridge.widget(b.dump(), identifier="ShowSheet"))
    time.sleep(0.6)
    sheet = b.window_box_by_size(320, 120, tol=6)
    t.ok(sheet is not None, "document sheet opened over its parent")
    if sheet:
        golden_window(t, b, xeph, sheet, "sheet", default_title="Done")
    done = b.alert_button("Done")
    if done:
        b.click_find_widget(done)
        time.sleep(0.3)

    # --- NSDrawer (attached to main window, right edge) ---
    b.click_dump_widget(Bridge.widget(b.dump(), identifier="ToggleDrawer"))
    time.sleep(0.8)
    drawer = None
    for w in b.x11_windows():
        if 150 < w["width"] < 190 and w["height"] > 200:
            drawer = {"id": w["id"], "x": w["x"], "y": w["y"], "w": w["width"], "h": w["height"]}
            break
    t.ok(drawer is not None, "NSDrawer opened without crashing (base NSDrawer)")
    if drawer:
        golden_window(t, b, xeph, drawer, "drawer")

    # app survived all of it
    try:
        b.dump(); alive = True
    except Exception:
        alive = False
    t.ok(alive, "Chrome app survived panel + sheet + drawer")


if __name__ == "__main__":
    run_xephyr("chrome_panels", "Chrome", body)
