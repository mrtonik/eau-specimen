#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""1F — ASan soak: cycle an ASan-instrumented specimen (under the ASan theme)
launch -> attach -> exercise -> teardown, K times, in one Xephyr. Each teardown
runs the autorelease-pool drain (the B1 stack-overflow trigger) and each DO
connection re-fires Eau's enableMultipleThreads (B3). ASan runs threads
concurrently (unlike memcheck) and its SEGV/stack-overflow handler emits a clean
backtrace even when the faulting frame is in uninstrumented libgnustep-base.

ASAN_OPTIONS (incl. log_path) is set by the caller and inherited via the sandbox.
Any analysis/1F/asan.<pid> file = a fault ASan caught that iteration.

  python3.11 run_asan_soak.py [Specimen] [iterations] [tree_reads_per_iter]
"""
import os, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "tests"))   # suite spec_harness/screenshot
_GS = os.environ.get("GOLDSTEP_DIR") or os.path.expanduser("~/build/goldstep")
if os.path.isdir(_GS) and _GS not in sys.path:
    sys.path.insert(0, _GS)
import spec_harness as SH                         # noqa: E402
from goldstep.mcp import MCPError                 # noqa: E402
from goldstep.xephyr import Xephyr                # noqa: E402

app = sys.argv[1] if len(sys.argv) > 1 else "Buttons"
iters = int(sys.argv[2]) if len(sys.argv) > 2 else 12
reads = int(sys.argv[3]) if len(sys.argv) > 3 else 4
# SOAK_BASE=1 => run under the built-in base GSTheme (theme=False) instead of Eau,
# as the attribution control: does the teardown stack-overflow need Eau?
THEME_KW = {"theme": False} if os.environ.get("SOAK_BASE") else {}
print("[ASan soak] theme = %s" % ("BASE" if THEME_KW else "Eau",), flush=True)

ok = fail = 0
t0 = time.time()
print("[ASan soak] %s x%d (%d tree reads each)" % (app, iters, reads), flush=True)
with Xephyr(1280, 900) as xeph:
    for i in range(1, iters + 1):
        try:
            with SH.Session(app, display=xeph.display, ready_timeout=240,
                            require_dump=True, **THEME_KW) as s:
                for _ in range(reads):
                    s.bridge.get_root()
                    s.bridge.find(cls="NSButton")
                    time.sleep(0.25)
            ok += 1
            print("[ASan soak] iter %2d/%d ok" % (i, iters), flush=True)
        except (MCPError, Exception) as e:
            fail += 1
            print("[ASan soak] iter %2d/%d FAILED: %r" % (i, iters, e), flush=True)
print("[ASan soak] done in %.0fs: %d ok, %d failed" % (time.time() - t0, ok, fail), flush=True)
