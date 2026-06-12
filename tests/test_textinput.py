#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""TextInput specimen: text fields (editable/empty/disabled/rounded), static label,
secure field, search field, combo box.

Guards the NSSearchField infinite-recursion crash fix (the app simply launching
with a search field present is the regression test) plus state/geometry and a
deterministic static golden.

Known Eau findings (see planning.html), NOT asserted here:
  - text-field editing intermittently crashes Eau on first edit;
  - focused text fields don't draw the spec'd focus ring (only a blinking caret).
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

    # ---- presence + state ----
    t.ok(len(widgets) >= 8, "all TextInput widgets registered (%d)" % len(widgets))
    t.eq(w("Field edit").get("stringValue"), "Hello", "editable field value")
    t.eq(w("Field disabled").get("enabled"), False, "disabled field is disabled")
    # The mere presence of a rendered NSSearchField is the regression test for the
    # fixed infinite-recursion crash (NSSearchFieldCell+Eau EAUdrawWithFrame).
    t.eq(w("Search field").get("class"), "NSSearchField",
         "search field renders without crashing under Eau (recursion fix)")
    t.eq(w("Combo box").get("class"), "NSComboBox", "combo box present")
    t.eq((w("TextView") or {}).get("class"), "NSTextView", "NSTextView present (no crash rendering)")
    t.ok(not any(x.get("firstResponder") for x in widgets), "no field focused at rest")

    # ---- geometry: text field height ~22 ----
    f = M.frame_of(w("Field edit").get("windowFrame"))
    t.approx(f[3], M.FIELD_HEIGHT, 1, "text field height ~22")

    # ---- static golden ----
    box = b.main_window_box()
    t.ok(box is not None, "found main window")
    if box:
        b.activate(box["id"])
        static = S.capture(box["id"], "/tmp/spec_textinput_static.png")
        ok, msg = S.compare_golden("textinput", "static", static, tolerance=0)
        t.ok(ok, "textinput static golden: %s" % msg)


if __name__ == "__main__":
    run("textinput", "TextInput", body)
