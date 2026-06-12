<!-- SPDX-License-Identifier: BSD-2-Clause -->
# diagnostics

Runtime-analysis drivers that exercise the specimen apps under memory/concurrency
checkers and differential oracles. These are the scripts behind the Eau
[bug-overview](../../eau-bug-overview.md) findings (crash/UAF/race attribution,
state-cue regressions, spec drift). Each is a standalone driver that reuses the
suite's [`spec_harness`](../tests/spec_harness.py) and the
[goldstep](https://github.com/mrtonik/goldstep) `diagnostics` API.

They are **drivers, not pass/fail TAP tests** — they launch a specimen, probe it,
and print a verdict / leave a checker report behind for you to read.

| Script | What it does | Needs |
|---|---|---|
| `run_diag.py` | Run a specimen under **valgrind** (`memcheck` / `helgrind` / `drd`) via `launch_wrapper`, inside a private Xephyr; leaves the report. | a normal build; `valgrind` |
| `diff_base.py` | **Eau-vs-base differential**: render the checkbox states under Eau and the built-in base GSTheme (`theme=False`) and flag any state cue Eau collapses (disabled greying, mixed glyph). | a normal build |
| `interact.py` | **State-transition** checks via real XTEST input: click toggles a checkbox `0↔1`; typing updates a field's live value; Tab moves the key view. | a normal build |
| `run_asan_soak.py` | **ASan soak**: cycle launch→exercise→teardown ×K (the teardown pool-drain is the stack-overflow trigger). `SOAK_BASE=1` runs the base-theme control. | an **ASan build** (below) |
| `run_tsan.py` | **TSan run** to collect data-race reports from the bridge's DO connection + teardown. | a **TSan build** (below) |
| `spec_oracle.py` | Parse `AppearanceMetrics.h` and assert measured widget geometry (button heights, scroller width, …) against the documented metrics. | `EAU_THEME_DIR` set |

## Running

Same prerequisites as the [suite](../README.md) (X11, goldstep, a patched
UIBridge server, `DISPLAY`). Build the specimens first (`tests/run.sh` or `gmake`
in each app), then run a driver directly:

```sh
# valgrind memcheck on Buttons (no rebuild needed)
python3 diagnostics/run_diag.py memcheck Buttons

# Eau-vs-base checkbox differential
python3 diagnostics/diff_base.py

# XTEST state-transition checks
python3 diagnostics/interact.py

# spec-oracle (needs the theme source for AppearanceMetrics.h)
EAU_THEME_DIR=~/src/gershwin-eau-theme python3 diagnostics/spec_oracle.py
```

Honoured env vars: `GOLDSTEP_DIR`, `UIBRIDGE_SERVER`, `DISPLAY`, `SPEC_THEME`
(see the suite README), plus `EAU_THEME_DIR` for `spec_oracle.py`. Reports/PNGs
are written next to the scripts and are git-ignored.

## Sanitizer builds (for `run_asan_soak.py` / `run_tsan.py`)

valgrind needs no special build, but the sanitizers must be **compiled in** — both
the **theme** and the **specimen** under test. Rebuild each with the matching flags,
e.g. ASan:

```sh
gmake clean
gmake ADDITIONAL_OBJCFLAGS="-fsanitize=address -fno-omit-frame-pointer -O1 -g" \
      ADDITIONAL_LDFLAGS="-fsanitize=address"
```

and TSan with `-fsanitize=thread -O1 -g` (and `ADDITIONAL_LDFLAGS=-fsanitize=thread`).
Point `EAU_THEME_DIR`/`SPEC_THEME` at the instrumented theme, then:

```sh
ASAN_OPTIONS=log_path=$PWD/diagnostics/asan python3 diagnostics/run_asan_soak.py Buttons 12
TSAN_OPTIONS=log_path=$PWD/diagnostics/tsan python3 diagnostics/run_tsan.py Buttons
```

`run_asan_soak.py` also takes `iterations` and `tree_reads_per_iter` args;
`SOAK_BASE=1` runs the base-GSTheme control to attribute a fault to Eau vs the
GNUstep base. `run_diag.py memcheck` serialises threads, so use `helgrind`/`drd`
(or a TSan build) for the data race.
