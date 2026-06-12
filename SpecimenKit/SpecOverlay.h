// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
//
// SpecOverlay.h — non-interactive diagnostic HUD drawn over the widgets.
//
// Toggled by SPECIMEN_OVERLAY=1 or the Debug menu. Draws, per registered widget,
// its frame outline, text baseline and tag number so screenshots make
// misalignment obvious. Passes all clicks through (hitTest: returns nil).
//
#ifndef SPEC_OVERLAY_H
#define SPEC_OVERLAY_H

#import <AppKit/AppKit.h>

@interface SpecOverlay : NSView
// Attach (once) an overlay covering a window's content view. Returns it.
+ (SpecOverlay *)attachToWindow:(NSWindow *)win;
@end

#endif
