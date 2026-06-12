#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""1C — differential vs base GSTheme.

Renders the Buttons specimen under Eau and under the built-in base GSTheme (the new
goldstep `theme=False` control), then uses base as an *independent oracle*: for a
pair of checkbox states that base renders differently, check whether Eau collapses
them to the same pixels — i.e. a regression Eau introduced.

  disabled-greying : glyph of the DISABLED checked box vs the ENABLED checked box
                     (both state=1; differ only in enabled). base greys it; does Eau?
  mixed-glyph      : glyph of the MIXED box (state=-1) vs the ON box (state=1).
                     base draws a dash vs a check; does Eau draw both as a check?

A large base AE + a ~0 Eau AE on the same pair = Eau regressed that state cue.
"""
import os, sys, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "tests"))   # suite spec_harness/screenshot
_GS = os.environ.get("GOLDSTEP_DIR") or os.path.expanduser("~/build/goldstep")
if os.path.isdir(_GS) and _GS not in sys.path:
    sys.path.insert(0, _GS)
import spec_harness as SH                         # noqa: E402
import screenshot as S                            # noqa: E402
from goldstep.xephyr import Xephyr                # noqa: E402

# checkbox tags from the Buttons dump: 1008 off, 1009 on, 1010 mixed, 1011 disabled
TAGS = {"off": 1008, "on": 1009, "mixed": 1010, "disabled": 1011}
GW = 18  # glyph square width (the checkmark box at the widget's left edge)


def glyph_image_rect(sf, sh, box):
    g = {"x": sf["x"], "y": sf["y"], "w": GW, "h": sf["h"]}
    return [int(round(v)) for v in S.screen_frame_to_image(g, box, sh, pad=0)]


def crop(src, rect, dst):
    x, y, w, h = rect
    subprocess.run(["convert", src, "-crop", "%dx%d+%d+%d" % (w, h, x, y),
                    "+repage", dst], check=True)


def ae(a, b):
    r = subprocess.run(["compare", "-metric", "AE", a, b, "/tmp/_1c_diff.png"],
                       capture_output=True, text=True)
    tok = (r.stderr or r.stdout).strip().split()
    try:
        return int(float(tok[0]))
    except Exception:
        return None


def render(label, theme):
    """Launch Buttons under `theme`, capture the window + each checkbox glyph crop.
    Returns (window_png, {state: glyph_png})."""
    with Xephyr(1280, 900) as xeph:
        with SH.Session("Buttons", display=xeph.display, theme=theme) as s:
            b = s.bridge
            box = b.main_window_box()
            b.activate(box["id"])
            shot = os.path.join(HERE, "buttons-%s.png" % label)
            S.capture(box["id"], shot)
            _, sh = b.screen_size()
            dump = b.dump()
            glyphs = {}
            for state, tag in TAGS.items():
                sf = SH.Bridge.widget(dump, tag=tag).get("screenFrame")
                rect = glyph_image_rect(sf, sh, box)
                gp = os.path.join(HERE, "glyph-%s-%s.png" % (label, state))
                crop(shot, rect, gp)
                glyphs[state] = gp
            return shot, glyphs


def main():
    print("[1C] rendering Buttons under Eau and base GSTheme...", flush=True)
    eau_win, eau = render("eau", SH.SPEC_THEME or None)
    base_win, base = render("base", False)        # theme=False => base GSTheme

    pairs = [("disabled-greying", "disabled", "on"),
             ("mixed-glyph", "mixed", "on")]
    print("\n%-18s %-12s %-12s  verdict" % ("regression", "base AE", "Eau AE"))
    print("-" * 60)
    for name, a, bb in pairs:
        base_ae = ae(base[a], base[bb])
        eau_ae = ae(eau[a], eau[bb])
        # base distinguishes the states (AE>0) but Eau collapses them (AE~0) => regression
        regressed = (base_ae or 0) > 0 and (eau_ae or 0) <= max(2, (base_ae or 0) // 8)
        print("%-18s %-12s %-12s  %s" % (
            name, base_ae, eau_ae,
            "REGRESSION (base shows it, Eau doesn't)" if regressed
            else "ok / inconclusive"))
    print("\n[1C] window captures: %s , %s" % (eau_win, base_win))


if __name__ == "__main__":
    main()
