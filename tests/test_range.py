#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Range specimen: sliders / stepper / progress / spinner / color well / segmented,
plus the (currently un-themed) level indicator + date picker.

Exercises Eau+Slider.m / Eau+Stepper.m / Eau+ProgressIndicator.m / Eau+ColorWell.m /
Eau+Segmented.m. Widgets flagged expected.animated (spinner) or expected.todoTheme
(level indicator, date picker) are masked out of the golden — the rest compares
pixel-exactly.
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
    t.ok(len(widgets) >= 14, "all Range widgets registered (%d)" % len(widgets))
    t.eq(w("Slider mid").get("class"), "NSSlider", "Slider mid is an NSSlider")
    t.eq(w("Segmented").get("class"), "NSSegmentedControl", "Segmented control present")
    t.eq(w("Color well").get("class"), "NSColorWell", "Color well present")
    t.eq(w("Level indicator").get("class"), "NSLevelIndicator", "Level indicator present")
    t.eq(w("Date picker").get("class"), "NSDatePicker", "Date picker present")
    t.eq((w("Slider circular") or {}).get("class"), "NSSlider", "circular slider present (no crash)")
    t.eq((w("DatePickerGraphical") or {}).get("class"), "NSDatePicker",
         "graphical date picker present (renders as text only — finding)")
    # Level indicator is now Eau-themed (green fill at 60%) and part of the golden;
    # the date picker is still bare text (todoTheme) and stays masked.

    # ---- state ----
    t.eq(w("Slider disabled").get("enabled"), False, "disabled slider is disabled")
    t.eq(w("Stepper disabled").get("enabled"), False, "disabled stepper is disabled")
    t.ok(not any(x.get("firstResponder") for x in widgets), "no widget holds focus at rest")

    # ---- geometry vs metrics ----
    def hh(idn):
        f = M.frame_of(w(idn).get("windowFrame"))
        return f[3] if f else None

    t.approx(hh("Slider mid"), 20, 2, "horizontal slider height ~20")
    t.approx(hh("Segmented"), 24, 3, "segmented control height ~24")

    # ---- golden (mask animated + not-yet-themed widgets) ----
    box = b.main_window_box()
    t.ok(box is not None, "found main window to screenshot")
    if box:
        b.activate(box["id"])
        shot = S.capture(box["id"], "/tmp/spec_range_static.png")
        _, sh = b.screen_size()
        masks = []
        for x in widgets:
            exp = x.get("expected") or {}
            if exp.get("animated") or exp.get("todoTheme"):
                sf = x.get("screenFrame")
                if sf:
                    masks.append(S.screen_frame_to_image(sf, box, sh, pad=3))
        t.ok(len(masks) >= 2, "masking spinner + date picker (%d regions)" % len(masks))
        ok, msg = S.compare_golden("range", "static", shot, tolerance=0, mask_rects=masks)
        t.ok(ok, "range static golden: %s" % msg)


if __name__ == "__main__":
    run("range", "Range", body)
