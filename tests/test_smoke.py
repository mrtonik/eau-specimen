#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Smoke test: a specimen launches under the dev Eau theme, comes up cleanly, and
its UIBridge service + state-dump work. Guards the whole pipeline before the
per-family tests dig into widgets."""

import os
from spec_harness import Session, Test


KNOWN_OK = (
    "NSColorListNotEditableException",  # Eau throws this on theme activate (non-fatal; tracked)
)


def main():
    t = Test("smoke")
    try:
        with Session("Buttons") as s:
            b = s.bridge
            root = b.get_root()
            t.ok(root.get("NSApp"), "NSApp present (UIBridge attached)")
            t.ok(any(not w.get("hidden") for w in root.get("windows", [])),
                 "at least one visible window")

            dump = b.dump()
            t.ok(len(dump.get("widgets", [])) > 0, "state-dump has widgets")
            t.eq(dump.get("specimen"), "Buttons", "dump names the specimen")

            # no crash signature in the app log
            log = os.path.join(s.sandbox.dir, "app.log")
            text = open(log).read() if os.path.exists(log) else ""
            t.ok("Segmentation" not in text and "stop reason = signal SIG" not in text,
                 "no SIGSEGV/crash in app log")
            bad = [ln for ln in text.splitlines()
                   if "Exception" in ln and not any(k in ln for k in KNOWN_OK)]
            t.ok(not bad, "no unexpected exceptions in app log")
            if bad:
                for ln in bad[:5]:
                    t.fail("  unexpected: %s" % ln.strip()[:120])
    except SystemExit:
        raise
    except Exception:
        import traceback
        t.fail("session/setup", traceback.format_exc())
    t.done()


if __name__ == "__main__":
    main()
