# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Specimen shim: re-export goldstep.screenshot, pinning the golden/artifact roots
to this tests/ directory so `import screenshot as S` keeps writing goldens here."""

import os as _os
import sys as _sys

_HERE = _os.path.dirname(_os.path.abspath(__file__))
_os.environ.setdefault("GOLDSTEP_GOLDENS", _os.path.join(_HERE, "goldens"))
_os.environ.setdefault("GOLDSTEP_ARTIFACTS", _os.path.join(_HERE, "artifacts"))

_GOLDSTEP = _os.environ.get("GOLDSTEP_DIR") or _os.path.expanduser("~/build/goldstep")
if _os.path.isdir(_GOLDSTEP) and _GOLDSTEP not in _sys.path:
    _sys.path.insert(0, _GOLDSTEP)

from goldstep.screenshot import *  # noqa: E402,F401,F403
from goldstep.screenshot import GOLDENS, ARTIFACTS  # noqa: E402,F401
