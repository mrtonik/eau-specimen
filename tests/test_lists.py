#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Lists specimen: NSTableView (multi-col + header + selected row), NSOutlineView
(expanded tree + disclosure triangles), NSBrowser. Exercises Eau+Table.m /
NSTableHeaderCell+Eau.m / Eau+Browser.m / NSBrowserCell+Eau.m. Deterministic ->
single full golden.
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
    t.ok(len(widgets) >= 3, "Lists widgets registered (%d)" % len(widgets))
    t.ok("Table" in (w("Table") or {}).get("class", ""), "NSTableView present")
    t.ok("Outline" in (w("Outline") or {}).get("class", ""), "NSOutlineView present")
    t.ok("Browser" in (w("Browser") or {}).get("class", ""), "NSBrowser present")
    t.ok(not any(x.get("firstResponder") for x in widgets), "nothing focused at rest")

    # ---- geometry sanity ----
    tf = M.frame_of(w("Table").get("windowFrame"))
    t.ok(tf and tf[2] > 200 and tf[3] > 100, "table view has a sane size")

    # ---- golden (selected row + expanded tree are deterministic) ----
    box = b.main_window_box()
    t.ok(box is not None, "found main window")
    if box:
        b.activate(box["id"])
        shot = S.capture(box["id"], "/tmp/spec_lists_static.png")
        ok, msg = S.compare_golden("lists", "static", shot, tolerance=0)
        t.ok(ok, "lists static golden: %s" % msg)


if __name__ == "__main__":
    run("lists", "Lists", body)
