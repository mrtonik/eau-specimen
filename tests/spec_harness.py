# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Specimen-suite glue over the reusable `goldstep` harness.

The reusable core (sandbox / session / bridge / xephyr / screenshot / TAP / MCP)
now lives in the standalone `goldstep` package. This module keeps ONLY the
Eau-specimen specifics: locating a built specimen binary, defaulting to the dev
Eau theme, and wiring the SpecimenKit JSON state-dump so existing tests'
`b.dump()` / `Bridge.widget(...)` keep working. Tests import
`Bridge / Session / run / run_xephyr / Test` from here unchanged.

invoke_selector is NEVER used (it use-after-frees the Eau bridge). State comes
from the dump; geometry from find_widgets/the dump; input from XTEST.
"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SPECIMEN_DIR = os.path.normpath(os.path.join(HERE, ".."))
WORK_DIR = os.path.normpath(os.path.join(HERE, "..", ".."))

# Reusable harness: prefer an installed / $PYTHONPATH goldstep, else the sibling
# build tree. Override the location with $GOLDSTEP_DIR.
_GOLDSTEP = os.environ.get("GOLDSTEP_DIR") or os.path.expanduser("~/build/goldstep")
if os.path.isdir(_GOLDSTEP) and _GOLDSTEP not in sys.path:
    sys.path.insert(0, _GOLDSTEP)

from goldstep import Bridge, Test                              # noqa: E402,F401
from goldstep import Session as _Session                       # noqa: E402
from goldstep import run as _run, run_xephyr as _run_xephyr    # noqa: E402
from goldstep.statedump import StateDump                       # noqa: E402

DUMP_INTERVAL = "0.3"

# The Eau theme under test: a writable clone of the public repo, loaded per-sandbox
# via GSTheme so the dev build is exercised and the live /System Eau is untouched.
# $SPEC_THEME overrides; empty string => whatever the seeded GlobalDefaults say.
DEV_THEME = os.path.join(WORK_DIR, "gershwin-eau-theme", "Eau.theme")
SPEC_THEME = os.environ.get("SPEC_THEME", DEV_THEME if os.path.isdir(DEV_THEME) else "")


def specimen_binary(name):
    """Path to a built specimen binary, e.g. name='Buttons' -> .../Buttons.app/Buttons.
    Override with $SPECIMEN_<NAME>."""
    env = os.environ.get("SPECIMEN_%s" % name.upper())
    if env:
        return env
    return os.path.join(SPECIMEN_DIR, name, "%s.app" % name, name)


def _dump_factory(specimen_name):
    """A StateDump bound to SpecimenKit's env contract (SPECIMEN_DUMP_DIR /
    SPECIMEN_DUMP_INTERVAL, <name>.state.json)."""
    def make(sandbox):
        return StateDump(sandbox, specimen_name,
                         dir_env="SPECIMEN_DUMP_DIR",
                         interval_env="SPECIMEN_DUMP_INTERVAL",
                         interval=DUMP_INTERVAL, suffix=".state.json")
    return make


def _spec_kw(specimen_name):
    return dict(theme=SPEC_THEME or None,
                state_dump=_dump_factory(specimen_name),
                require_dump=True,
                keep=bool(os.environ.get("SPEC_TEST_KEEP")))


class Session(_Session):
    """goldstep.Session preconfigured for a specimen: locate the binary, force the
    dev Eau theme, wire the SpecimenKit state-dump."""

    def __init__(self, specimen_name, **kw):
        kw = {**_spec_kw(specimen_name), **kw}
        super().__init__(specimen_binary(specimen_name), name=specimen_name, **kw)


def run(name, specimen_name, body, display=None):
    _run(name, specimen_binary(specimen_name), body, app_name=specimen_name,
         display=display, **_spec_kw(specimen_name))


def run_xephyr(name, specimen_name, body, size=(1280, 900), extra_defaults=None):
    _run_xephyr(name, specimen_binary(specimen_name), body, app_name=specimen_name,
                size=size, extra_defaults=extra_defaults, **_spec_kw(specimen_name))
