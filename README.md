<!-- SPDX-License-Identifier: BSD-2-Clause -->
# Eau specimen suite

A set of small **GNUstep / Gershwin** "specimen" apps — widget galleries — plus a
golden-image + introspection **test suite** that drives them through the
[**UIBridge**](https://github.com/gershwin-desktop/gershwin-components/tree/main/UIBridge)
MCP service and asserts on structure, the live widget tree, and per-window
**golden-image** diffs. Output is **TAP**.

It was built to regression-test the [**Eau** theme](https://github.com/gershwin-desktop/gershwin-eau-theme),
but the apps are plain AppKit widget galleries, so the suite doubles as a
**general GSTheme regression harness**: point it at any theme and diff against a
baseline (the reusable core already supports a base-GNUstep-theme differential
control).

No AI is involved — "MCP" here is just JSON-RPC over stdio used as a plain
automation API.

## What's here

| Path | Purpose |
|---|---|
| `Buttons/` `Chrome/` `Containers/` `Dialogs/` `Extras/` `Lists/` `Menus/` `Range/` `TextInput/` `Windows/` | One specimen app each — a deterministic gallery of related widgets/states, built programmatically (no Gorm/NIB). |
| `SpecimenKit/` | Shared support code the apps link against: grid layout, debug overlay, deterministic state dump, widget registry, metrics, logging, app delegate. |
| `tests/` | One `test_*.py` per app (independent TAP streams), `goldens/` baselines, `run.sh` orchestrator. |
| `diagnostics/` | Runtime-analysis drivers (valgrind / ASan / TSan, Eau-vs-base differential, spec-oracle) — see [Diagnostics](#diagnostics). |

## Requirements

- A GNUstep / Gershwin desktop on **X11** (Linux or FreeBSD). Wayland is not
  supported — input uses XTEST.
- The [**goldstep**](https://github.com/mrtonik/goldstep) harness (the reusable
  test core; the specimen tests are a consumer of it).
- A **patched UIBridge server** — the per-app introspection service vended by the
  Eau theme. The suite needs the improvements in PR
  [**gershwin-components#68 "UIBridge improvements"**](https://github.com/gershwin-desktop/gershwin-components/pull/68);
  build `UIBridge` from that branch and point `$UIBRIDGE_SERVER` at it. Base:
  [gershwin-components/UIBridge](https://github.com/gershwin-desktop/gershwin-components/tree/main/UIBridge).
- CLI tools used by goldstep: `xdotool`, ImageMagick (`import`/`convert`/`compare`),
  and for the Xephyr smoke tests `Xephyr` + `xdpyinfo`.
- GNUstep Make + `clang` (the standard Gershwin toolchain). Python ≥ 3.8.

## Build & run

```sh
. /System/Library/Makefiles/GNUstep.sh        # source the GNUstep env

cd tests
./run.sh                       # build the theme + all specimens, run every test_*.py
./run.sh test_buttons.py       # one file (still builds first)
SKIP_BUILD=1 ./run.sh          # skip the build step
SPEC_UPDATE_GOLDENS=1 ./run.sh # (re)write the golden baselines
```

By default the specimens run against your **installed** theme. To exercise a
local theme checkout instead, set `EAU_THEME_DIR` (built by `run.sh`) and
`SPEC_THEME` (the built `.theme` bundle, loaded per-sandbox):

```sh
EAU_THEME_DIR=~/src/gershwin-eau-theme \
SPEC_THEME=~/src/gershwin-eau-theme/Eau.theme ./run.sh
```

`run.sh` honours these environment overrides:

| Var | Default | Meaning |
|---|---|---|
| `UIBRIDGE_SERVER` | `$HOME/Library/Tools/UIBridgeServer` | path to the UIBridge server binary |
| `GOLDSTEP_DIR` | `$HOME/build/goldstep` | location of the goldstep package (added to `PYTHONPATH`) |
| `EAU_THEME_DIR` | (unset) | a theme source checkout to `gmake` before running |
| `SPEC_THEME` | installed theme | a built `.theme` bundle to load per-sandbox |
| `PYTHON` | autodetected | Python interpreter |
| `DISPLAY` | (required) | the X display to drive |

Each `test_*.py` launches its own specimen under a throwaway defaults sandbox,
loads the selected theme, attaches over UIBridge, exercises the widgets, and
diffs each window against `tests/goldens/<app>/`.

## Diagnostics

`diagnostics/` holds runtime-analysis drivers that exercise the specimens under
memory/concurrency checkers and differential oracles — the scripts behind the Eau
findings (crash/UAF/race attribution, dropped state cues, spec drift). They reuse
`tests/spec_harness.py` and goldstep's `diagnostics` API. These are **drivers, not
pass/fail TAP** — each launches a specimen, probes it, and prints a verdict or
leaves a checker report behind.

| Script | What it does | Build needed |
|---|---|---|
| `run_diag.py` | Run a specimen under **valgrind** (`memcheck` / `helgrind` / `drd`) via `launch_wrapper`, inside a private Xephyr; leaves the report. | normal |
| `diff_base.py` | **Eau-vs-base differential**: render the checkbox states under Eau and the built-in base GSTheme (`theme=False`) and flag any state cue Eau collapses (disabled greying, mixed glyph). | normal |
| `interact.py` | **State-transition** checks via real XTEST input: click toggles a checkbox `0↔1`; typing updates a field's live value; Tab moves the key view. | normal |
| `run_asan_soak.py` | **ASan soak**: cycle launch→exercise→teardown ×K (the teardown pool-drain is the stack-overflow trigger); `SOAK_BASE=1` runs the base-theme control. | ASan build |
| `run_tsan.py` | **TSan run** collecting data-race reports from the bridge's DO connection + teardown. | TSan build |
| `spec_oracle.py` | Parse `AppearanceMetrics.h` and assert measured widget geometry (button heights, scroller width, …) against the documented metrics. | `EAU_THEME_DIR` |

Build the specimens first (`tests/run.sh`), then run a driver directly. They honour
the same env as above, plus `EAU_THEME_DIR` for `spec_oracle.py`; reports/PNGs are
written next to the scripts and are git-ignored.

```sh
python3 diagnostics/run_diag.py memcheck Buttons   # valgrind, no rebuild
python3 diagnostics/diff_base.py                   # Eau-vs-base checkbox differential
python3 diagnostics/interact.py                    # XTEST state-transition checks
EAU_THEME_DIR=~/src/gershwin-eau-theme python3 diagnostics/spec_oracle.py
```

**Sanitizer builds** (`run_asan_soak.py` / `run_tsan.py`): valgrind needs no special
build, but the sanitizers must be compiled into **both the theme and the specimen**.
Rebuild each with the matching flags, e.g. ASan:

```sh
gmake clean
gmake ADDITIONAL_OBJCFLAGS="-fsanitize=address -fno-omit-frame-pointer -O1 -g" \
      ADDITIONAL_LDFLAGS="-fsanitize=address"
```

(TSan: `-fsanitize=thread -O1 -g`.) Point `EAU_THEME_DIR`/`SPEC_THEME` at the
instrumented theme, then run e.g. `ASAN_OPTIONS=log_path=$PWD/diagnostics/asan
python3 diagnostics/run_asan_soak.py Buttons 12`. `memcheck` serialises threads, so
use `helgrind`/`drd` (or a TSan build) for the data race.

## Goldens are host-sensitive

The baselines in `tests/goldens/` are pixel renderings, so font rendering,
backend, and display can produce legitimate diffs across machines. Regenerate
them on your own host with `SPEC_UPDATE_GOLDENS=1 ./run.sh` and commit the result
for your environment, or use the base-theme differential mode instead of fixed
baselines.

## License

BSD-2-Clause — see [LICENSE](LICENSE).
