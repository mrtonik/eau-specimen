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

## Goldens are host-sensitive

The baselines in `tests/goldens/` are pixel renderings, so font rendering,
backend, and display can produce legitimate diffs across machines. Regenerate
them on your own host with `SPEC_UPDATE_GOLDENS=1 ./run.sh` and commit the result
for your environment, or use the base-theme differential mode instead of fixed
baselines.

## License

BSD-2-Clause — see [LICENSE](LICENSE).
