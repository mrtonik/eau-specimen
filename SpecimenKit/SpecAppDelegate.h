// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
//
// SpecAppDelegate.h — shared app-delegate base for every specimen app.
//
// Provides: the NSBoldFont registration fix (so bold text doesn't fall back to a
// missing face and crash on redraw), a minimal menu with a Debug submenu
// (Dump State / Toggle Overlay), state-dump-on-launch, and SPECIMEN_OVERLAY
// support. Subclasses override -setupSpecimen to build their windows and call
// -trackWindow: on each so the overlay + dump see them.
//
#ifndef SPEC_APP_DELEGATE_H
#define SPEC_APP_DELEGATE_H

#import <AppKit/AppKit.h>

@interface SpecAppDelegate : NSObject

// Subclass entry point: build windows here, calling -trackWindow: on each.
- (void)setupSpecimen;

// Short specimen name (used for the dump filename + window titles). Default: the
// process name.
- (NSString *)specimenName;

// Register a window for overlay + dump; orders it front.
- (void)trackWindow:(NSWindow *)win;

// Hook: insert extra top-level menus (File/Edit/View…) between the app menu and
// the Debug menu. Default is a no-op; the Menus specimen overrides it.
- (void)addExtraTopMenus:(NSMenu *)mainMenu;

// Actions (also wired to the Debug menu).
- (void)dumpState:(id)sender;
- (void)toggleOverlay:(id)sender;

@property (readonly) NSArray *trackedWindows;

@end

#endif
