#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""1F — run a TSan-instrumented specimen (under the TSan-built Eau theme) and
collect ThreadSanitizer race reports. No launch wrapper: TSan is compiled in.

The bridge attach opens a DO connection -> Eau's enableMultipleThreads (B3) spawns
the connection thread; teardown drains the autorelease pool (B1). TSan watches both.
TSAN_OPTIONS (incl. log_path) is set by the caller and inherited via the sandbox env.
"""
import os, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "tests"))   # suite spec_harness/screenshot
_GS = os.environ.get("GOLDSTEP_DIR") or os.path.expanduser("~/build/goldstep")
if os.path.isdir(_GS) and _GS not in sys.path:
    sys.path.insert(0, _GS)
import spec_harness as SH                         # noqa: E402
from goldstep.xephyr import Xephyr                # noqa: E402

app = sys.argv[1] if len(sys.argv) > 1 else "Buttons"
hold = float(sys.argv[2]) if len(sys.argv) > 2 else 6.0

print("[1F/TSan] launching %s (TSan build, TSan theme) in Xephyr" % app, flush=True)
t0 = time.time()
with Xephyr(1280, 900) as xeph:
    with SH.Session(app, display=xeph.display, ready_timeout=300,
                    require_dump=True, keep=True) as s:
        print("[1F/TSan] ready in %.0fs" % (time.time() - t0), flush=True)
        try:
            n = len(s.bridge.find(cls="NSButton"))
            print("[1F/TSan] tree reachable: %d NSButtons" % n, flush=True)
        except Exception as e:
            print("[1F/TSan] tree read failed: %r" % e, flush=True)
        time.sleep(hold)
        print("[1F/TSan] tearing down (pool drain runs under TSan)", flush=True)
print("[1F/TSan] done in %.0fs" % (time.time() - t0), flush=True)
