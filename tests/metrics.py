# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Eau HIG metric constants mirrored for the Python test side.

Kept in sync with specimen/SpecimenKit/SpecMetrics.h and the theme's
AppearanceMetrics.h. Tests assert measured widget geometry against these.
"""

BUTTON_HEIGHT       = 20.0
BUTTON_SMALL_HEIGHT = 17.0
BUTTON_MIN_WIDTH    = 69.0

RADIO_SIZE       = 18.0
RADIO_SMALL_SIZE = 14.0

FIELD_HEIGHT     = 22.0
FOCUS_RING_TOP   = 2.0
FOCUS_RING_SIDES = 3.0

TAB_HEIGHT       = 30.0
TAB_SMALL_HEIGHT = 25.0
SCROLLBAR_WIDTH  = 11.0
DIALOG_ICON_SIDE = 64.0

TITLEBAR_HEIGHT  = 22.0
ORB_SIZE         = 15.0

SIDE_MARGIN   = 24.0
TOP_MARGIN    = 16.0
BOTTOM_MARGIN = 20.0


def frame_of(widget):
    """Parse a UIBridge/dump frame ('{x = ..; y = ..; width = ..; height = ..}'
    string OR a {'x','y','w','h'} dict) into (x, y, w, h)."""
    if isinstance(widget, dict) and "w" in widget and "h" in widget:
        return (widget["x"], widget["y"], widget["w"], widget["h"])
    s = widget.get("screen_frame") or widget.get("frame") if isinstance(widget, dict) else widget
    if not isinstance(s, str):
        return None
    nums = []
    for tok in s.replace("{", " ").replace("}", " ").replace(";", " ").split():
        try:
            nums.append(float(tok))
        except ValueError:
            pass
    return tuple(nums[:4]) if len(nums) >= 4 else None
