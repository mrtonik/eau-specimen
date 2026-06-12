// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import <AppKit/AppKit.h>
#import "SpecAppDelegate.h"

// B-tier "chrome" widgets that only render when the app is frontmost (driven
// inside a private Xephyr): NSPopUpButton (popup + pulldown menus), an NSPanel
// (utility window), a sheet, and an NSDrawer. The on-demand ones are built
// lazily in their action so an instantiation crash is isolated to that trigger
// instead of aborting app launch.
@interface ChromeController : SpecAppDelegate
@end
