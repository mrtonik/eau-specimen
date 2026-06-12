// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
//
// SpecRegistry.h — curated catalogue of the specimen's widgets.
//
// Every widget the specimen wants the tests to inspect is registered here, in
// creation order, with the state it is *supposed* to be in and the Eau source
// file it exercises. The state-dump and the visual overlay both iterate this
// registry, so the order is deterministic (stable goldens) and each widget
// carries the metadata the tests assert against.
//
#ifndef SPEC_REGISTRY_H
#define SPEC_REGISTRY_H

#import <AppKit/AppKit.h>

@interface SpecEntry : NSObject
@property (assign)            NSInteger    tag;
@property (copy)              NSString    *identifier;
@property (assign) /*weak*/   NSView      *view;     // owned by its window
@property (copy)              NSDictionary *expected; // expected state (assert target)
@property (copy)              NSString    *eauFile;   // Eau source under test
@property (copy)              NSString    *note;
@end

@interface SpecRegistry : NSObject
+ (instancetype)shared;

// Register a widget. Auto-assigns a unique tag (>= 1000) and sets it on the
// view if it is an NSControl, so UIBridge find_widgets can locate it by tag.
- (SpecEntry *)add:(NSView *)view
        identifier:(NSString *)identifier
          expected:(NSDictionary *)expected
               eau:(NSString *)eauFile;

@property (readonly) NSArray<SpecEntry *> *entries;
- (void)reset;
@end

#endif
