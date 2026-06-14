// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "MenusController.h"
#import "SpecimenKit.h"

@implementation MenusController
{
  BOOL _marker;
  NSButton *_markerBox;
}

- (NSString *)specimenName { return @"Menus"; }

// ---- rich menu (structure / state / dispatch coverage) ----
- (void)addExtraTopMenus:(NSMenu *)mainMenu
{
  // File
  NSMenuItem *fileItem = [[NSMenuItem alloc] initWithTitle:@"File" action:NULL keyEquivalent:@""];
  NSMenu *file = [[NSMenu alloc] initWithTitle:@"File"];
  [file setAutoenablesItems:NO];
  [file addItemWithTitle:@"New"   action:NULL keyEquivalent:@"n"];
  [file addItemWithTitle:@"Open…" action:NULL keyEquivalent:@"o"];
  [file addItem:[NSMenuItem separatorItem]];
  [file addItemWithTitle:@"Close" action:NULL keyEquivalent:@"w"];
  [fileItem setSubmenu:file];
  [mainMenu addItem:fileItem];

  // Edit
  NSMenuItem *editItem = [[NSMenuItem alloc] initWithTitle:@"Edit" action:NULL keyEquivalent:@""];
  NSMenu *edit = [[NSMenu alloc] initWithTitle:@"Edit"];
  [edit setAutoenablesItems:NO];
  [edit addItemWithTitle:@"Cut"   action:NULL keyEquivalent:@"x"];
  [edit addItemWithTitle:@"Copy"  action:NULL keyEquivalent:@"c"];
  [edit addItemWithTitle:@"Paste" action:NULL keyEquivalent:@"v"];
  [editItem setSubmenu:edit];
  [mainMenu addItem:editItem];

  // View — checkmark state, dispatch item, separator, disabled item, submenu
  NSMenuItem *viewItem = [[NSMenuItem alloc] initWithTitle:@"View" action:NULL keyEquivalent:@""];
  NSMenu *view = [[NSMenu alloc] initWithTitle:@"View"];
  [view setAutoenablesItems:NO];

  id<NSMenuItem> grid = [view addItemWithTitle:@"Show Grid" action:NULL keyEquivalent:@""];
  [grid setState:NSOnState];   // checkmark; list_menus reports state=1

  id<NSMenuItem> toggle = [view addItemWithTitle:@"Toggle Marker"
                                          action:@selector(toggleMarker:) keyEquivalent:@"t"];
  [toggle setTarget:self];     // explicit target: reliable dispatch

  [view addItem:[NSMenuItem separatorItem]];

  id<NSMenuItem> disabled = [view addItemWithTitle:@"Unavailable" action:NULL keyEquivalent:@""];
  [disabled setEnabled:NO];

  // one-level submenu
  id<NSMenuItem> moreItem = [view addItemWithTitle:@"More" action:NULL keyEquivalent:@""];
  NSMenu *more = [[NSMenu alloc] initWithTitle:@"More"];
  [more setAutoenablesItems:NO];
  [more addItemWithTitle:@"Deeper" action:NULL keyEquivalent:@""];
  [moreItem setSubmenu:more];

  [viewItem setSubmenu:view];
  [mainMenu addItem:viewItem];
}

// dispatch target for "View > Toggle Marker"
- (void)toggleMarker:(id)sender
{
  _marker = !_marker;
  [_markerBox setState:(_marker ? NSOnState : NSOffState)];
  [SpecStateDump write:[self specimenName]];   // reflect immediately
}

- (void)setupSpecimen
{
  CGFloat bh = METRICS_RADIO_BUTTON_SIZE;
  CGFloat totalH = METRICS_CONTENT_BOTTOM_MARGIN + bh + SPEC_TOP_MARGIN;
  CGFloat totalW = SPEC_SIDE_MARGIN + 120 + SPEC_SIDE_MARGIN;
  NSRect cr = NSMakeRect(0, 0, totalW, totalH);
  NSView *content = [[NSView alloc] initWithFrame:cr];

  _markerBox = [[NSButton alloc] initWithFrame:NSMakeRect(SPEC_SIDE_MARGIN, METRICS_CONTENT_BOTTOM_MARGIN, 120, bh)];
  [_markerBox setButtonType:NSSwitchButton];
  [_markerBox setTitle:@"Marker"];
  [_markerBox setState:NSOffState];
  [_markerBox setEnabled:NO];   // display-only; toggled by the menu, not clicks
  [content addSubview:_markerBox];
  [[SpecRegistry shared] add:_markerBox identifier:@"NSButton (marker)" expected:@{@"state":@0} eau:@"NSMenu (dispatch)"];

  NSWindow *win = [[NSWindow alloc] initWithContentRect:cr
                                              styleMask:(NSTitledWindowMask | NSClosableWindowMask
                                                         | NSMiniaturizableWindowMask)
                                                backing:NSBackingStoreBuffered defer:NO];
  [win setTitle:@"Menus"];
  [win setContentView:content];
  [win setFrameOrigin:NSMakePoint(160, 360)];
  [win setInitialFirstResponder:content];
  [self trackWindow:win];
}

@end
