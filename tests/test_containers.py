#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Containers specimen: NSBox border types, NSTabView, NSScrollView, NSImageView
frame styles. Exercises NSBox+Eau.m / Eau+TabView.m / Eau+Scroller.m and the
(base-GSTheme) image-frame drawing. All deterministic -> a single full golden.

NSSplitView coverage + Eau-specific styling of image frames are deferred (noted
in planning.html §7).
"""

import metrics as M
import screenshot as S
from spec_harness import Bridge, run


def body(t, sess):
    b = sess.bridge
    dump = b.dump()
    widgets = dump.get("widgets", [])

    def w(idn):
        return Bridge.widget(dump, identifier=idn)

    # ---- presence ----
    t.ok(len(widgets) >= 11, "all Containers widgets registered (%d)" % len(widgets))
    for idn, cls in [("Box groove", "NSBox"), ("Tab view", "NSTabView"),
                     ("Scroll view", "NSScrollView"), ("Img Photo", "NSImageView")]:
        got = w(idn)
        t.eq(got and got.get("class"), cls, "%s is a %s" % (idn, cls))

    t.ok(not any(x.get("firstResponder") for x in widgets), "no widget holds focus at rest")

    # ---- geometry ----
    def fr(idn):
        return M.frame_of(w(idn).get("windowFrame"))

    bx = fr("Box groove")
    t.approx(bx[3], 70, 1, "box height as laid out (70)")
    # scroll view shows an 11px-ish scroller (Eau metric) — sanity check width sane
    sv = fr("Scroll view")
    t.ok(sv and sv[2] > 100, "scroll view has a sane width")

    # ---- golden (all deterministic; no masks) ----
    box = b.main_window_box()
    t.ok(box is not None, "found main window to screenshot")
    if box:
        b.activate(box["id"])
        shot = S.capture(box["id"], "/tmp/spec_containers_static.png")
        ok, msg = S.compare_golden("containers", "static", shot, tolerance=0)
        t.ok(ok, "containers static golden: %s" % msg)


if __name__ == "__main__":
    run("containers", "Containers", body)
