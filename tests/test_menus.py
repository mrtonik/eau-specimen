#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Menus specimen (A-tier: structure / state / dispatch, no pixels).

Drives Eau's menu DO bridge via list_menus / invoke_menu_item to verify the menu
tree, checkmark state, disabled items, separators, a one-level submenu, and that
invoking an item actually dispatches its action (toggles a marker checkbox).
Covers the menu *logic* — where bugs like upstream issue #31 live — without
needing the global menu bar's pixels (rendered by a separate Menu.app process).

Note: list_menus does not serialize key-equivalents (always null), so those are
not asserted here.
"""

import time

from spec_harness import Bridge, run


def body(t, sess):
    b = sess.bridge
    tree = b.menu_tree()

    # ---- structure ----
    for top in ["Menus", "File", "Edit", "View", "Debug"]:
        t.ok(top in tree, "top menu %r present" % top)

    file_items = [it["title"] for it in tree.get("File", {}).get("items", [])
                  if not it.get("isSeparator")]
    for it in ["New", "Open…", "Close"]:
        t.ok(it in file_items, "File contains %r" % it)
    t.ok(any(x.get("isSeparator") for x in tree["File"]["items"]), "File has a separator")

    # ---- state ----
    t.eq(b.menu_item("View", "Show Grid").get("state"), 1, "Show Grid is checked (state=1)")
    t.eq(b.menu_enabled("View", "Toggle Marker"), True, "Toggle Marker is enabled")
    t.eq(b.menu_enabled("View", "Unavailable"), False, "Unavailable item is disabled")
    t.ok(b.menu_item("View", "More") is not None, "View has a 'More' submenu item")

    # ---- id resolution ----
    t.ok(b.menu_item_id("View", "Toggle Marker") is not None,
         "menu_item_id resolves for View > Toggle Marker")

    # ---- dispatch: invoking the item runs its action (toggles the marker) ----
    m0 = Bridge.widget(b.dump(), identifier="Marker").get("state")
    ts = time.time()
    b.invoke_menu("View", "Toggle Marker")
    time.sleep(0.3)
    m1 = Bridge.widget(b.dump(after=ts), identifier="Marker").get("state")
    t.ne(m1, m0, "Toggle Marker dispatched: marker state changed via the menu")

    ts = time.time()
    b.invoke_menu("View", "Toggle Marker")
    time.sleep(0.3)
    m2 = Bridge.widget(b.dump(after=ts), identifier="Marker").get("state")
    t.eq(m2, m0, "toggling twice returns to the original state")


if __name__ == "__main__":
    run("menus", "Menus", body)
