#!/bin/sh
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
#
# Build the specimen apps, then run the UIBridge-driven specimen tests. Each
# test_*.py is an independent TAP stream that launches its own sandboxed specimen
# under the theme being tested. Exits nonzero if any file fails.
#
#   ./run.sh                       # build the specimens, run all test_*.py
#   ./run.sh test_buttons.py       # run one file (still builds first)
#   SKIP_BUILD=1 ./run.sh          # skip the build step
#   SPEC_UPDATE_GOLDENS=1 ./run.sh # (re)write golden baselines
#
# By default the specimens run against the installed theme. To exercise a local
# theme checkout instead, point $EAU_THEME_DIR at it (gets built here) and
# $SPEC_THEME at its built .theme bundle (loaded per-sandbox; see spec_harness.py).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)   # repo root: the specimen apps live directly here
cd "$HERE"

if [ -z "${PYTHON:-}" ]; then
  for c in python3.11 python3 python; do
    command -v "$c" >/dev/null 2>&1 && { PYTHON=$c; break; }
  done
fi
[ -n "${PYTHON:-}" ] || { echo "Bail out! no python"; exit 2; }

: "${UIBRIDGE_SERVER:=$HOME/Library/Tools/UIBridgeServer}"; export UIBRIDGE_SERVER
[ -x "$UIBRIDGE_SERVER" ] || { echo "Bail out! UIBRIDGE_SERVER not executable: $UIBRIDGE_SERVER"; exit 2; }
[ -n "${DISPLAY:-}" ] || { echo "Bail out! no DISPLAY"; exit 2; }

# The reusable harness core lives in the standalone `goldstep` package; the
# specimen tests are a consumer of it. Put it on PYTHONPATH and pin the golden /
# artifact roots to this dir (spec_harness.py/screenshot.py also self-locate it).
: "${GOLDSTEP_DIR:=$HOME/build/goldstep}"; export GOLDSTEP_DIR
case ":${PYTHONPATH:-}:" in *":$GOLDSTEP_DIR:"*) ;; *) PYTHONPATH="$GOLDSTEP_DIR${PYTHONPATH:+:$PYTHONPATH}";; esac
export PYTHONPATH
export GOLDSTEP_GOLDENS="$HERE/goldens" GOLDSTEP_ARTIFACTS="$HERE/artifacts"

if [ -z "${GNUSTEP_MAKEFILES:-}" ] && [ -r /System/Library/Makefiles/GNUstep.sh ]; then
  . /System/Library/Makefiles/GNUstep.sh
fi

if [ -z "${SKIP_BUILD:-}" ]; then
  : >/tmp/spec-build.log
  # Build a local theme checkout only if $EAU_THEME_DIR points at one; otherwise
  # the specimens run against the installed theme (or whatever $SPEC_THEME picks).
  if [ -n "${EAU_THEME_DIR:-}" ] && [ -f "$EAU_THEME_DIR/GNUmakefile" ]; then
    echo "=== building theme ($EAU_THEME_DIR) ==="
    ( cd "$EAU_THEME_DIR" && gmake ) >>/tmp/spec-build.log 2>&1 || {
      echo "Bail out! theme build failed (see /tmp/spec-build.log)"; tail -8 /tmp/spec-build.log; exit 2; }
  fi
  for app in Buttons TextInput Lists Menus Range Containers Windows Dialogs Extras Chrome; do
    [ -f "$ROOT/$app/GNUmakefile" ] || continue
    echo "=== building $app ==="
    ( cd "$ROOT/$app" && gmake ) >>/tmp/spec-build.log 2>&1 || {
      echo "Bail out! $app build failed (see /tmp/spec-build.log)"; tail -8 /tmp/spec-build.log; exit 2; }
  done
fi

# Reap any sandboxed specimens that outlived a hard-killed test.
cleanup() { pkill -9 -f "spec-test-" 2>/dev/null; rm -rf /tmp/spec-test-* 2>/dev/null; }
trap cleanup EXIT INT TERM

if [ "$#" -gt 0 ]; then files="$*"; else files=$(ls test_*.py 2>/dev/null); fi
[ -n "$files" ] || { echo "no test files"; exit 0; }

rc=0; pass=0; fail=0
for f in $files; do
  echo "=== $f ==="
  if "$PYTHON" "$f"; then pass=$((pass + 1)); else fail=$((fail + 1)); rc=1; fi
done
echo "=== suite: $pass file(s) passed, $fail failed ==="
exit $rc
