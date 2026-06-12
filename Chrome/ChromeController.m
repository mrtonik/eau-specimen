// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "ChromeController.h"
#import "SpecimenKit.h"

@implementation ChromeController
{
  NSWindow *_main;
  NSPanel  *_panel;
  NSWindow *_sheet;
  NSDrawer *_drawer;
}

- (NSString *)specimenName { return @"Chrome"; }

- (NSButton *)button:(NSString *)title at:(NSRect)r action:(SEL)sel
                  id:(NSString *)idn eau:(NSString *)eau into:(NSView *)content
{
  NSButton *b = [[NSButton alloc] initWithFrame:r];
  [b setTitle:title];
  [b setBezelStyle:NSRoundedBezelStyle];
  [b setTarget:self];
  [b setAction:sel];
  [content addSubview:b];
  [[SpecRegistry shared] add:b identifier:idn expected:@{} eau:eau];
  return b;
}

- (void)setupSpecimen
{
  NSRect cr = NSMakeRect(0, 0, 520, 300);
  NSView *content = [[NSView alloc] initWithFrame:cr];

  // NSPopUpButton — popup style (NSPopUpButton+Eau / NSMenuItemCell+Eau)
  NSPopUpButton *popup = [[NSPopUpButton alloc]
                            initWithFrame:NSMakeRect(40, 240, 160, 24) pullsDown:NO];
  [popup addItemsWithTitles:@[@"Alpha", @"Bravo", @"Charlie"]];
  [popup selectItemAtIndex:1];
  [content addSubview:popup];
  [[SpecRegistry shared] add:popup identifier:@"Popup" expected:@{} eau:@"NSPopUpButton+Eau.m"];

  // NSPopUpButton — pulldown style (first item is the persistent title)
  NSPopUpButton *pull = [[NSPopUpButton alloc]
                           initWithFrame:NSMakeRect(240, 240, 160, 24) pullsDown:YES];
  [pull addItemsWithTitles:@[@"Actions", @"Duplicate", @"Rename", @"Delete"]];
  [content addSubview:pull];
  [[SpecRegistry shared] add:pull identifier:@"Pulldown" expected:@{} eau:@"NSPopUpButton+Eau.m"];

  [self button:@"Show Panel"   at:NSMakeRect(40, 180, 140, 28)
        action:@selector(showPanel:)   id:@"ShowPanel"   eau:@"NSPanel/decoration" into:content];
  [self button:@"Show Sheet"   at:NSMakeRect(40, 130, 140, 28)
        action:@selector(showSheet:)   id:@"ShowSheet"   eau:@"sheet decoration" into:content];
  [self button:@"Toggle Drawer" at:NSMakeRect(40, 80, 140, 28)
        action:@selector(toggleDrawer:) id:@"ToggleDrawer" eau:@"NSDrawer (base)" into:content];

  // shared system panels (in-app NSPanels) — Eau themes their controls
  [self button:@"Color Panel" at:NSMakeRect(240, 180, 140, 28)
        action:@selector(showColorPanel:) id:@"ShowColor" eau:@"NSColorPanel/Eau+ColorWell" into:content];
  [self button:@"Font Panel" at:NSMakeRect(240, 130, 140, 28)
        action:@selector(showFontPanel:) id:@"ShowFont" eau:@"NSFontPanel" into:content];

  _main = [[NSWindow alloc] initWithContentRect:cr
                                      styleMask:(NSTitledWindowMask | NSClosableWindowMask
                                                 | NSMiniaturizableWindowMask)
                                        backing:NSBackingStoreBuffered defer:NO];
  [_main setTitle:@"Chrome"];
  [_main setContentView:content];
  [_main setFrameOrigin:NSMakePoint(120, 360)];
  [_main setInitialFirstResponder:content];
  [self trackWindow:_main];
}

// ---- NSPanel (utility window) ----
- (void)showPanel:(id)sender
{
  if (_panel == nil)
    {
      _panel = [[NSPanel alloc]
                  initWithContentRect:NSMakeRect(0, 0, 280, 130)
                            styleMask:(NSTitledWindowMask | NSClosableWindowMask
                                       | NSUtilityWindowMask)
                              backing:NSBackingStoreBuffered defer:NO];
      [_panel setTitle:@"Utility"];
      NSView *c = [_panel contentView];
      NSTextField *l = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 76, 240, 20)];
      [l setStringValue:@"Floating utility panel"];
      [l setBezeled:NO]; [l setBordered:NO]; [l setDrawsBackground:NO];
      [l setEditable:NO]; [l setSelectable:NO];
      [c addSubview:l];
      NSButton *ok = [[NSButton alloc] initWithFrame:NSMakeRect(170, 20, 90, 28)];
      [ok setTitle:@"OK"]; [ok setBezelStyle:NSRoundedBezelStyle];
      [ok setKeyEquivalent:@"\r"];
      [c addSubview:ok];
      [_panel setFrameOrigin:NSMakePoint(460, 420)];
    }
  [_panel makeKeyAndOrderFront:nil];
  [SpecStateDump write:[self specimenName]];
}

// ---- sheet (attached to the main window) ----
- (void)showSheet:(id)sender
{
  if (_sheet == nil)
    {
      _sheet = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 320, 120)
                                           styleMask:NSTitledWindowMask
                                             backing:NSBackingStoreBuffered defer:NO];
      NSView *c = [_sheet contentView];
      NSTextField *l = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 66, 280, 20)];
      [l setStringValue:@"This is a document sheet."];
      [l setBezeled:NO]; [l setBordered:NO]; [l setDrawsBackground:NO];
      [l setEditable:NO]; [l setSelectable:NO];
      [c addSubview:l];
      NSButton *done = [[NSButton alloc] initWithFrame:NSMakeRect(210, 18, 90, 28)];
      [done setTitle:@"Done"]; [done setBezelStyle:NSRoundedBezelStyle];
      [done setKeyEquivalent:@"\r"];
      [done setTarget:self]; [done setAction:@selector(endSheet:)];
      [c addSubview:done];
    }
  [NSApp beginSheet:_sheet modalForWindow:_main modalDelegate:self
        didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

// ---- shared system panels (each wrapped so a failure is a logged finding) ----
- (void)showColorPanel:(id)sender
{
  @try { [NSApp orderFrontColorPanel:sender]; }
  @catch (NSException *e) { NSLog(@"Chrome: NSColorPanel failed: %@", e); }
  [SpecStateDump write:[self specimenName]];
}

- (void)showFontPanel:(id)sender
{
  @try { [[NSFontManager sharedFontManager] orderFrontFontPanel:sender]; }
  @catch (NSException *e) { NSLog(@"Chrome: NSFontPanel failed: %@", e); }
  [SpecStateDump write:[self specimenName]];
}

- (void)endSheet:(id)sender { [NSApp endSheet:_sheet]; }

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)code contextInfo:(void *)ctx
{
  [sheet orderOut:nil];
}

// ---- NSDrawer (attached to the main window) ----
- (void)toggleDrawer:(id)sender
{
  @try {
    if (_drawer == nil)
      {
        _drawer = [[NSDrawer alloc] initWithContentSize:NSMakeSize(160, 200)
                                          preferredEdge:NSMaxXEdge];
        [_drawer setParentWindow:_main];
        NSView *dv = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 160, 200)];
        NSTextField *l = [[NSTextField alloc] initWithFrame:NSMakeRect(12, 160, 136, 20)];
        [l setStringValue:@"Drawer"];
        [l setBezeled:NO]; [l setBordered:NO]; [l setDrawsBackground:NO];
        [l setEditable:NO]; [l setSelectable:NO];
        [dv addSubview:l];
        [_drawer setContentView:dv];
      }
    NSInteger st = [_drawer state];
    if (st == NSDrawerOpenState || st == NSDrawerOpeningState)
      [_drawer close];
    else
      [_drawer openOnEdge:NSMaxXEdge];
  } @catch (NSException *e) {
    NSLog(@"Chrome: NSDrawer failed: %@", e);
  }
  [SpecStateDump write:[self specimenName]];
}

@end
