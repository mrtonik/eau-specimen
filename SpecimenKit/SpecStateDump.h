// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
//
// SpecStateDump.h — serialize every registered widget's live state to JSON.
//
// UIBridge exposes geometry/enabled/tag/title but NOT cell state (on/off/mixed),
// stringValue, first-responder, default-ness or font — and its invoke_selector
// path use-after-frees the target. So the specimen dumps that state itself, to a
// file the tests read as ground truth. Crash-free, synchronous, deterministic.
//
#ifndef SPEC_STATE_DUMP_H
#define SPEC_STATE_DUMP_H

#import <Foundation/Foundation.h>

@interface SpecStateDump : NSObject

// Build the dump dict for all registered widgets (+ window context).
+ (NSDictionary *)snapshot:(NSString *)specimenName;

// Write the snapshot to <SPECIMEN_DUMP_DIR or tmp>/<specimenName>.state.json.
// Returns the path written, or nil on failure.
+ (NSString *)write:(NSString *)specimenName;

@end

#endif
