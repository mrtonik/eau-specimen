#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""1F runtime-diagnostics driver: launch a specimen under a valgrind tool via the
new goldstep launch_wrapper, INSIDE a private Xephyr (so the valgrind'd app is the
only GNUstep client on that display — on bare :0 the bridge falls back to the
desktop's Terminal), exercise it, let it tear down (so the autorelease-pool drain
runs), and leave valgrind's report behind.

  python3.11 run_diag.py [memcheck|helgrind|drd] [Specimen] [hold_seconds]

memcheck → heap errors / UAF / leaks. NOTE memcheck serialises threads, so it does
NOT reproduce the B1 data race; use helgrind/drd (or a TSan build) for that.
GNUstep startup under valgrind is very slow — ready_timeout is large on purpose.
"""
import os, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "tests"))   # suite spec_harness/screenshot
_GS = os.environ.get("GOLDSTEP_DIR") or os.path.expanduser("~/build/goldstep")
if os.path.isdir(_GS) and _GS not in sys.path:
    sys.path.insert(0, _GS)
import spec_harness as S                         # noqa: E402
from goldstep import diagnostics as diag         # noqa: E402
from goldstep.xephyr import Xephyr                # noqa: E402

tool = sys.argv[1] if len(sys.argv) > 1 else "memcheck"
app  = sys.argv[2] if len(sys.argv) > 2 else "Buttons"
hold = float(sys.argv[3]) if len(sys.argv) > 3 else 5.0
log  = os.path.join(HERE, "%s-%s.log" % (app.lower(), tool))

wrap = diag.valgrind(tool, log, num_callers=50, extra=["--smc-check=all-non-file"])

print("[1F] %s under valgrind %s, inside Xephyr (log -> %s)" % (app, tool, log), flush=True)
t0 = time.time()
with Xephyr(1280, 900) as xeph:
    with S.Session(app, display=xeph.display, launch_wrapper=wrap,
                   ready_timeout=900, keep=True, require_dump=False) as s:
        print("[1F] ready in %.0fs" % (time.time() - t0), flush=True)
        try:
            btns = s.bridge.find(cls="NSButton")
            print("[1F] tree reachable: %d NSButtons" % len(btns), flush=True)
        except Exception as e:
            print("[1F] tree read failed: %r" % e, flush=True)
        time.sleep(hold)
        print("[1F] tearing down (pool-drain path runs under valgrind now)", flush=True)
print("[1F] done in %.0fs; report: %s" % (time.time() - t0, log), flush=True)
