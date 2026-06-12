#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""B-tier visual: the Eau NSAlert panel CHROME (EauAlertPanel / NSAlert+Eau.m).

Deferred on the shared :0 because the alert panel hid when the app wasn't
frontmost. Inside a private Xephyr the specimen is the only client, so the modal
panel stays up and can be screenshotted. We golden the panel with its default
button (which pulses) masked, and pixel-sample the default button to prove it is
the blue Eau default. Driver-side this is non-blocking: runModal blocks the app's
main thread, but the DO bridge + X server keep answering.
"""

import re
import time

import screenshot as S
from spec_harness import Bridge, run_xephyr


def wait_alert(b, timeout=6):
    deadline = time.time() + timeout
    while time.time() < deadline:
        if b.alert_button("OK") and b.alert_button("Cancel") and b.alert_button("Maybe"):
            return True
        time.sleep(0.2)
    return False


def alert_box(b, exclude_id):
    """The alert panel's X window: largest real nested window that isn't the main
    window (and isn't a GNUstep helper sliver)."""
    best = None
    for w in b.x11_windows():
        if w["id"] == exclude_id:
            continue
        if w.get("width", 0) < 200 or w.get("height", 0) < 80:
            continue
        area = w["width"] * w["height"]
        if best is None or area > best[1]:
            best = (w, area)
    return best[0] if best else None


def screen_frame_str_to_dict(s):
    nums = re.findall(r"[-\d.]+", s or "")
    if len(nums) < 4:
        return None
    x, y, w, h = (float(n) for n in nums[:4])
    return {"x": x, "y": y, "w": w, "h": h}


def body(t, sess, xeph):
    b = sess.bridge
    main = b.main_window_box()
    t.ok(main is not None, "found Dialogs main window")
    if not main:
        return

    show = Bridge.widget(b.dump(), identifier="ShowAlert")
    b.click_dump_widget(show)
    t.ok(wait_alert(b), "alert panel opened and stayed up (frontmost in Xephyr)")

    abox = alert_box(b, main["id"])
    t.ok(abox is not None, "alert panel is a visible top-level window")
    if not abox:
        return

    box = {"id": abox["id"], "x": abox["x"], "y": abox["y"],
           "w": abox["width"], "h": abox["height"]}
    b.park_mouse()
    shot = S.capture(box["id"], "/tmp/spec_chrome_alert.png", display=xeph.display)

    # mask the default (OK) button: it pulses (Eau DefaultButtonAnimation).
    _, screen_h = b.screen_size()
    ok = b.alert_button("OK")
    sf = screen_frame_str_to_dict(ok.get("screen_frame")) if ok else None
    mask = []
    if sf:
        rx, ry, rw, rh = S.screen_frame_to_image(sf, box, screen_h, pad=4)
        mask = [(rx, ry, rw, rh)]
        # the OK button should be the blue Eau default: sample its centre
        px = S.sample_pixel(shot, rx + rw / 2.0, ry + rh / 2.0)
        t.ok(px is not None and px[2] > px[0] and px[2] > 100,
             "default (OK) button renders blue: rgb=%s" % (px,))

    ok_g, msg = S.compare_golden("chrome", "alert", shot, tolerance=0, mask_rects=mask)
    t.ok(ok_g, "alert panel golden (default button masked): %s" % msg)

    # dismiss so the app can exit cleanly
    btn = b.alert_button("Cancel")
    if btn:
        b.click_find_widget(btn)


if __name__ == "__main__":
    run_xephyr("chrome_alert", "Dialogs", body)
