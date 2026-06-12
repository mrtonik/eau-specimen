# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Specimen shim: re-export goldstep.xephyr so `from xephyr import Xephyr` works."""

import os as _os
import sys as _sys

_GOLDSTEP = _os.environ.get("GOLDSTEP_DIR") or _os.path.expanduser("~/build/goldstep")
if _os.path.isdir(_GOLDSTEP) and _GOLDSTEP not in _sys.path:
    _sys.path.insert(0, _GOLDSTEP)

from goldstep.xephyr import *  # noqa: E402,F401,F403
from goldstep.xephyr import Xephyr  # noqa: E402,F401
