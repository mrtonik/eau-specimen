#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Windows specimen: document-window decoration (Eau+WindowDecoration.m /
NSWindow+Eau.m / EauGrowBox / titlebar buttons).

Environmental findings driving the design:
  - NSPanels hide when the app isn't frontmost -> panel/sheet/drawer chrome can't
    be screenshotted headless; deferred.
  - Which window is KEY flips non-deterministically when the app isn't frontmost,
    and Eau draws the titlebar differently for key vs inactive (the whole ~11k px
    delta is the titlebar). So we MASK the 22px titlebar and golden the stable
    remainder (borders, grow box, content). Titlebar-chrome golden is deferred to
    a frontmost-app harness.
"""

import time

import screenshot as S
from spec_harness import run

BG_FRAME = (500, 142)       # 120 content + 22 titlebar
TITLEBAR_H = 22


def find_window(b, size, tries=5):
    for _ in range(tries):
        xid = b.window_xid_by_size(*size, tol=3)
        if xid:
            return xid
        time.sleep(0.3)
    return None


def body(t, sess):
    b = sess.bridge
    b.dump()  # ensure up

    titles = b.window_titles()
    t.ok("Active Window" in titles, "active document window is open")
    t.ok("Background Window" in titles, "background document window is open")

    b.mouse_move(3, 3)
    time.sleep(0.2)
    xid = find_window(b, BG_FRAME)
    t.ok(xid is not None, "found a document window (frame == content+22, titlebar 22px)")
    if xid:
        b.mouse_move(3, 3)
        shot = S.capture(xid, "/tmp/spec_windows_body.png")
        # mask the titlebar (top 22px), which flips with non-deterministic key state
        mask = [(0, 0, BG_FRAME[0], TITLEBAR_H)]
        ok, msg = S.compare_golden("windows", "body", shot, tolerance=0, mask_rects=mask)
        t.ok(ok, "window body/grow-box golden (titlebar masked): %s" % msg)

    # A6: borderless window — no chrome (frame == content, NO +22 titlebar)
    t.ok("Borderless" in titles, "borderless window is open")
    bxid = find_window(b, (300, 100))
    t.ok(bxid is not None, "borderless window has NO titlebar (frame == content 300x100)")
    if bxid:
        b.mouse_move(3, 3)
        shot = S.capture(bxid, "/tmp/spec_windows_borderless.png")
        ok, msg = S.compare_golden("windows", "borderless", shot, tolerance=0)
        t.ok(ok, "borderless window golden: %s" % msg)


if __name__ == "__main__":
    run("windows", "Windows", body)
