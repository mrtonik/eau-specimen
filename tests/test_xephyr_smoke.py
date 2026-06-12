#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""B-tier harness smoke: prove the private-Xephyr pipeline end to end.

Launch a plain specimen (Buttons) INSIDE a nested Xephyr and verify the whole
chain the visual tests depend on: the app starts on the nested display, the DO
bridge attaches there, the state-dump flows, the app's window is enumerable on
the nested server, and we can screenshot both a single window and the whole
nested framebuffer. If this is green, panels/menus/alerts can be driven the same
way with the app guaranteed frontmost.
"""

import screenshot as S
from spec_harness import run_xephyr


def body(t, sess, xeph):
    b = sess.bridge
    t.ok(b.display == xeph.display, "specimen pinned to nested display %s" % xeph.display)

    dump = b.dump()
    t.ok(isinstance(dump.get("widgets"), list) and dump["widgets"],
         "state-dump flows from the nested-display app (%d widgets)" % len(dump.get("widgets", [])))

    root = b.get_root()
    t.ok(bool(root.get("NSApp")), "DO bridge attached to the nested-display app")

    box = b.main_window_box()
    t.ok(box is not None, "specimen window enumerable on the nested server")
    if box:
        shot = S.capture(box["id"], "/tmp/spec_xephyr_window.png", display=xeph.display)
        import os
        t.ok(os.path.getsize(shot) > 0, "captured a single window from the nested server")

    rootshot = S.capture_root("/tmp/spec_xephyr_root.png", xeph.display)
    import os
    t.ok(os.path.getsize(rootshot) > 0, "captured the whole nested framebuffer")


if __name__ == "__main__":
    run_xephyr("xephyr_smoke", "Buttons", body)
