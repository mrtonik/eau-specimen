#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Extras specimen: the §7 gap widgets rendered as-is (NSForm, NSTokenField,
NSPathControl, NSImageView/NSImageCell, NSMatrix). Per §11 (reference-only) these
are NOT themed — the goal is to surface crashes / un-themed rendering. Presence +
no-crash + a full golden (these are static, so deterministic).
"""

import screenshot as S
from spec_harness import Bridge, run


def body(t, sess):
    b = sess.bridge
    dump = b.dump()

    def w(idn):
        return Bridge.widget(dump, identifier=idn)

    # NSTokenField excluded: throws on creation in this GNUstep (finding).
    for idn, cls in [("Form", "NSForm"),
                     ("Path", "NSPathControl"), ("Image", "NSImageView"),
                     ("Matrix", "NSMatrix")]:
        got = (w(idn) or {}).get("class")
        t.eq(got, cls, "%s present, renders without crashing (%s)" % (cls, cls))

    # app survived building/rendering all of them
    try:
        b.dump(); alive = True
    except Exception:
        alive = False
    t.ok(alive, "Extras app survived rendering all gap widgets")

    # golden (static widgets -> deterministic)
    box = b.main_window_box()
    t.ok(box is not None, "found Extras window")
    if box:
        b.activate(box["id"]); b.park_mouse()
        shot = S.capture(box["id"], "/tmp/spec_extras.png")
        ok, msg = S.compare_golden("extras", "static", shot, tolerance=0)
        t.ok(ok, "extras golden: %s" % msg)


if __name__ == "__main__":
    run("extras", "Extras", body)
