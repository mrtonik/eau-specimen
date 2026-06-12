// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
//
// SpecLog.h — env-guarded diagnostic logging.
//
// Verbose only when SPECIMEN_DIAG is set in the environment, so production runs
// stay quiet but the test harness (which captures each launch's stdout/stderr)
// can trace draw calls and state transitions when chasing an intermittent bug.
//
#ifndef SPEC_LOG_H
#define SPEC_LOG_H

#import <Foundation/Foundation.h>

#define SpecLog(...)                                   \
  do {                                                 \
    if (getenv("SPECIMEN_DIAG")) NSLog(__VA_ARGS__);   \
  } while (0)

#endif
