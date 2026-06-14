// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "WindowsController.h"
#import "SpecimenKit.h"

@implementation WindowsController

- (NSString *)specimenName { return @"Windows"; }

- (NSWindow *)makeWindow:(Class)cls
                   style:(NSUInteger)mask
                    size:(NSSize)size
                  origin:(NSPoint)origin
                   title:(NSString *)title
                   label:(NSString *)labelText
                      id:(NSString *)idn
{
  NSWindow *win = [[cls alloc] initWithContentRect:NSMakeRect(0, 0, size.width, size.height)
                                         styleMask:mask
                                           backing:NSBackingStoreBuffered defer:NO];
  [win setTitle:title];

  NSView *content = [win contentView];
  NSTextField *l = [[NSTextField alloc] initWithFrame:
                       NSMakeRect(SPEC_SIDE_MARGIN, size.height / 2.0 - 12, size.width - 2 * SPEC_SIDE_MARGIN, 24)];
  [l setStringValue:labelText];
  [l setBezeled:NO]; [l setBordered:NO]; [l setDrawsBackground:NO];
  [l setEditable:NO]; [l setSelectable:NO];
  [l setAlignment:NSCenterTextAlignment];
  [l setFont:[NSFont systemFontOfSize:13]];
  [content addSubview:l];
  [win setFrameOrigin:origin];

  [[SpecRegistry shared] add:l identifier:idn expected:@{} eau:@"NSWindow+Eau.m"];
  return win;
}

- (void)buildWindows
{
  NSUInteger doc = NSTitledWindowMask | NSClosableWindowMask
                 | NSMiniaturizableWindowMask | NSResizableWindowMask;

  // Background (non-key) titled window — distinct height for size-targeting.
  NSWindow *bg = [self makeWindow:[NSWindow class] style:doc
                             size:NSMakeSize(500, 120) origin:NSMakePoint(80, 110)
                            title:@"Background Window" label:@"Background (inactive) window"
                               id:@"BgLabel"];
  [self trackWindow:bg];

  // NB: NSPanels (utility or plain) hide intermittently when the app is not the
  // frontmost X client, so they can't be reliably screenshotted in this headless
  // test env — panel/sheet/drawer chrome coverage is deferred (needs a frontmost
  // app). Document-window chrome is stable and covered here.

  // A6: borderless window — no chrome (content only). Distinct 300x100 frame.
  NSWindow *bl = [self makeWindow:[NSWindow class] style:NSBorderlessWindowMask
                             size:NSMakeSize(300, 100) origin:NSMakePoint(700, 120)
                            title:@"Borderless" label:@"Borderless window"
                               id:@"BorderlessLabel"];
  [self trackWindow:bl];

  // Active (key) titled window — tracked last so it is key; 500x150.
  NSWindow *active = [self makeWindow:[NSWindow class] style:doc
                                 size:NSMakeSize(500, 150) origin:NSMakePoint(80, 360)
                                title:@"Active Window" label:@"Active (key) window"
                                   id:@"ActiveLabel"];
  [self trackWindow:active];
}

- (void)setupSpecimen { [self buildWindows]; }

@end
