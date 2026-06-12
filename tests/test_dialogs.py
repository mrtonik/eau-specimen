#!/usr/bin/env python3.11
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2026 Michael Hupp
"""Dialogs specimen (A-tier: modal NSAlert structure + round-trip, no golden).

Triggers a 3-button NSAlert via XTEST (non-blocking for the driver), inspects it
with find_widgets WHILE it is modal (the state-dump is stopped then, but the
UIBridge DO server still answers), asserts the button set / default / cancel, then
dismisses it and verifies the returned result propagated back to the app.

Exercises NSAlert+Eau.m (Eau's swizzled runModal / EauAlertPanel).

Runs INSIDE a private Xephyr: on the shared :0 the second dismissal round-trip
was intermittently flaky (clicking a modal-alert button is focus-sensitive on a
busy display). As the only client in Xephyr the alert is reliably frontmost, so
the XTEST clicks land deterministically.
"""

import time

from spec_harness import Bridge, run_xephyr


def wait_alert(b, timeout=6):
    deadline = time.time() + timeout
    while time.time() < deadline:
        if b.alert_button("OK") and b.alert_button("Cancel"):
            return True
        time.sleep(0.2)
    return False


def wait_gone(b, title, timeout=6):
    deadline = time.time() + timeout
    while time.time() < deadline:
        if b.alert_button(title) is None:
            return True
        time.sleep(0.2)
    return False


def run_once(t, b, box, dismiss_title, expect_result):
    # trigger
    b.activate(box["id"])
    show = Bridge.widget(b.dump(), identifier="ShowAlert")
    b.click_dump_widget(show)

    if not wait_alert(b):
        t.fail("alert did not appear after clicking Show Alert")
        return
    t.ok(True, "alert opened (modal) via Show Alert")

    # structure (read while modal)
    ok = b.alert_button("OK")
    cancel = b.alert_button("Cancel")
    maybe = b.alert_button("Maybe")
    t.ok(ok and cancel and maybe, "alert has OK / Cancel / Maybe buttons")
    t.eq(ok.get("keyEquivalent"), "\r", "OK is the default button (Return)")
    t.eq(cancel.get("keyEquivalent"), "\x1b", "Cancel responds to Escape")

    # dismiss by clicking the chosen button
    btn = b.alert_button(dismiss_title)
    ts = time.time()
    b.click_find_widget(btn)
    t.ok(wait_gone(b, dismiss_title), "alert dismissed (%s)" % dismiss_title)

    # the modal result propagated back to the app (dump resumes after modal)
    deadline = time.time() + 4
    got = None
    while time.time() < deadline:
        r = Bridge.widget(b.dump(after=ts), identifier="Result")
        got = r.get("stringValue") if r else None
        if got and got != "Result: (none)":
            break
        time.sleep(0.2)
    t.eq(got, "Result: " + expect_result,
         "modal result propagated: %s -> %r" % (dismiss_title, got))


def body(t, sess, xeph):
    b = sess.bridge
    box = b.main_window_box()
    t.ok(box is not None, "found Dialogs main window")
    if not box:
        return
    # round-trip 1: dismiss with OK
    run_once(t, b, box, "OK", "OK")
    # round-trip 2: dismiss with Maybe (proves the specific button is returned)
    run_once(t, b, box, "Maybe", "Maybe")


if __name__ == "__main__":
    run_xephyr("dialogs", "Dialogs", body)
