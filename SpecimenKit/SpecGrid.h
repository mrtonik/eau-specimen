// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
//
// SpecGrid.h — deterministic labeled-grid layout for "static states" windows.
//
// Lays widgets out in a fixed grid with a caption under each, on the Eau spacing
// metrics, so every specimen window has an identical, stable layout (good for
// golden images) and every cell is registered with SpecRegistry.
//
#ifndef SPEC_GRID_H
#define SPEC_GRID_H

#import <AppKit/AppKit.h>

@interface SpecGrid : NSObject

+ (instancetype)gridWithColumns:(NSInteger)cols cellSize:(NSSize)cellSize;

// Add a widget to the next cell. The widget keeps its own size and is centered
// in the cell above its caption. Registers it (auto tag + identifier=caption).
- (void)add:(NSView *)widget
    caption:(NSString *)caption
   expected:(NSDictionary *)expected
        eau:(NSString *)eauFile;

// Build a content view sized to fit every added cell. Use as a window's
// contentView. Safe to call once.
- (NSView *)build;

@property (readonly) NSSize contentSize;  // valid after -build

@end

#endif
