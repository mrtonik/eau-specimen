#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""1D — spec-oracle assertions. Parse the documented metrics from
AppearanceMetrics.h, then assert Eau's *measured* widget geometry (from the state
dump) against them. A mismatch on a theme-driven metric (scroller width, control
heights) is an Eau bug; a match confirms spec compliance.
"""
import os, re, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "tests"))   # suite spec_harness/screenshot
_GS = os.environ.get("GOLDSTEP_DIR") or os.path.expanduser("~/build/goldstep")
if os.path.isdir(_GS) and _GS not in sys.path:
    sys.path.insert(0, _GS)
import spec_harness as SH                         # noqa: E402
from goldstep.xephyr import Xephyr                # noqa: E402

_THEME_DIR = os.environ.get("EAU_THEME_DIR", "")
METRICS_H = os.path.join(_THEME_DIR, "AppearanceMetrics.h") if _THEME_DIR else ""


def load_metrics():
    if not METRICS_H or not os.path.exists(METRICS_H):
        sys.exit("spec_oracle: set $EAU_THEME_DIR to an Eau theme checkout (needs AppearanceMetrics.h)")
    txt = open(METRICS_H).read()
    m = dict(re.findall(r"static const float (METRICS_\w+)\s*=\s*([\d.]+)", txt))
    m.update(dict(re.findall(r"#define\s+(METRICS_\w+)\s+([\d.]+)", txt)))
    return {k: float(v) for k, v in m.items()}


def widgets(app):
    """Launch `app` under Eau in Xephyr, return its dumped widgets."""
    with Xephyr(1280, 900) as xeph:
        with SH.Session(app, display=xeph.display, ready_timeout=60,
                        require_dump=True) as s:
            return s.bridge.dump().get("widgets", [])


def live_scroller_width(app):
    """Measure the vertical NSScroller width from the LIVE tree (scrollers aren't
    SpecimenKit-registered, so they're absent from the dump). Theme-driven metric."""
    import re
    with Xephyr(1280, 900) as xeph:
        with SH.Session(app, display=xeph.display, ready_timeout=60,
                        require_dump=True) as s:
            for sc in s.bridge.find(cls="NSScroller", visible_only=False):
                nums = re.findall(r"[-\d.]+", sc.get("screen_frame") or "")
                if len(nums) >= 4:
                    w, hh = float(nums[2]), float(nums[3])
                    if hh > w:                      # vertical scroller
                        return round(w)
    return None


def by_title(ws, title, cls=None):
    for w in ws:
        if w.get("title") == title and (cls is None or w.get("class") == cls):
            return w
    return None


def by_cls(ws, cls):
    return [w for w in ws if w.get("class") == cls]


def h(w):
    return (w.get("screenFrame") or {}).get("h") if w else None


def w_(w):
    return (w.get("screenFrame") or {}).get("w") if w else None


def main():
    M = load_metrics()
    results = []  # (metric, spec, measured, where, tol)

    def check(label, spec, measured, where, tol=1.0):
        results.append((label, spec, measured, where, tol))

    b = widgets("Buttons")
    check("BUTTON_HEIGHT", M["METRICS_BUTTON_HEIGHT"], h(by_title(b, "Normal")), "Buttons/Normal")
    check("BUTTON_SMALL_HEIGHT", M["METRICS_BUTTON_SMALL_HEIGHT"], h(by_title(b, "Small")), "Buttons/Small")
    check("BUTTON_MIN_WIDTH", M["METRICS_BUTTON_MIN_WIDTH"], w_(by_title(b, "Normal")), "Buttons/Normal(width >=)")
    chk = by_title(b, "On")  # checkbox row, state=1
    check("RADIO_BUTTON_SIZE", M["METRICS_RADIO_BUTTON_SIZE"], h(chk), "Buttons/checkbox 'On'")

    ti = widgets("TextInput")
    fld = next((x for x in by_cls(ti, "NSTextField") if 20 <= (h(x) or 0) <= 26), None)
    check("TEXT_INPUT_FIELD_HEIGHT", M["METRICS_TEXT_INPUT_FIELD_HEIGHT"], h(fld), "TextInput/NSTextField")

    scw = live_scroller_width("Containers") or live_scroller_width("Lists")
    check("SCROLLBAR_WIDTH", M["METRICS_SCROLLBAR_WIDTH"], scw, "live NSScroller(vert width)")

    print("\n%-26s %-8s %-9s %-8s %s" % ("metric", "spec", "measured", "verdict", "where"))
    print("-" * 78)
    npass = nfail = nskip = 0
    for label, spec, meas, where, tol in results:
        if meas is None:
            verdict = "SKIP"; nskip += 1
        elif "width >=" in where:                     # min-width: measured must be >= spec
            verdict = "PASS" if meas + tol >= spec else "FAIL"
        elif abs(meas - spec) <= tol:
            verdict = "PASS"
        else:
            verdict = "FAIL"
        if verdict == "PASS": npass += 1
        elif verdict == "FAIL": nfail += 1
        print("%-26s %-8s %-9s %-8s %s" % (label, spec, meas, verdict, where))
    print("\n[1D] %d pass, %d fail, %d skip" % (npass, nfail, nskip))


if __name__ == "__main__":
    main()
