// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "ButtonsController.h"
#import "SpecimenKit.h"

@implementation ButtonsController

- (NSString *)specimenName { return @"Buttons"; }

// ---- small builders --------------------------------------------------------

- (NSButton *)push:(NSString *)title
{
  NSButton *b = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 90, SPEC_BUTTON_HEIGHT)];
  [b setTitle:title];
  [b setBezelStyle:NSRoundedBezelStyle];
  [b setButtonType:NSMomentaryPushInButton];
  [b sizeToFit];
  NSRect f = b.frame;
  if (f.size.width < SPEC_BUTTON_MIN_WIDTH) f.size.width = SPEC_BUTTON_MIN_WIDTH;
  f.size.height = SPEC_BUTTON_HEIGHT;
  [b setFrame:f];
  return b;
}

- (NSSwitch *)sw:(NSInteger)state enabled:(BOOL)enabled
{
  NSSwitch *s = [[NSSwitch alloc] initWithFrame:NSMakeRect(0, 0, 42, 22)];
  [s setState:state];
  [s setEnabled:enabled];
  return s;
}

- (NSButton *)check:(NSString *)title state:(NSInteger)state
{
  NSButton *b = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 120, 18)];
  [b setButtonType:NSSwitchButton];
  [b setTitle:title];
  if (state == NSMixedState) [b setAllowsMixedState:YES];
  [b setState:state];
  return b;
}

// ---- the static-states window ----------------------------------------------

- (void)buildStaticWindow
{
  SpecGrid *g = [SpecGrid gridWithColumns:4 cellSize:NSMakeSize(140, 56)];

  // Row 1: push-button states
  NSButton *normal = [self push:@"Normal"];
  [g add:normal caption:@"Normal" expected:@{@"enabled":@YES} eau:@"Eau+Button.m"];

  NSButton *disabled = [self push:@"Disabled"];
  [disabled setEnabled:NO];
  [g add:disabled caption:@"Disabled" expected:@{@"enabled":@NO} eau:@"NSButtonCell+Eau.m"];

  NSButton *def = [self push:@"Default"];
  [g add:def caption:@"Default" expected:@{@"isDefault":@YES} eau:@"NSButtonCell+Eau.m"];

  NSButton *pressed = [self push:@"Pressed"];
  [[pressed cell] setHighlighted:YES];
  [g add:pressed caption:@"Pressed" expected:@{@"highlighted":@YES} eau:@"Eau+Button.m"];

  // Row 2: variants
  NSButton *small = [self push:@"Small"];
  NSRect sf = small.frame; sf.size.height = SPEC_BUTTON_SMALL_HEIGHT; [small setFrame:sf];
  [g add:small caption:@"Small" expected:@{} eau:@"Eau+Button.m"];

  NSButton *imgText = [self push:@"Item"];
  [imgText setImage:[NSApp applicationIconImage]];
  [imgText setImagePosition:NSImageLeft];
  [imgText sizeToFit];
  NSRect itf = imgText.frame; itf.size.height = SPEC_BUTTON_HEIGHT; [imgText setFrame:itf];
  [g add:imgText caption:@"Image+Text" expected:@{} eau:@"NSButtonCell+Eau.m"];

  NSButton *imgOnly = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 28, 24)];
  [imgOnly setBezelStyle:NSRoundedBezelStyle];
  [imgOnly setImage:[NSApp applicationIconImage]];
  [imgOnly setImagePosition:NSImageOnly];
  [g add:imgOnly caption:@"Image only" expected:@{} eau:@"NSButtonCell+Eau.m"];

  NSButton *square = [self push:@"Square"];
  [square setBezelStyle:NSRegularSquareBezelStyle];
  [g add:square caption:@"Square bezel" expected:@{} eau:@"Eau+Button.m"];

  // Row 3: checkboxes
  [g add:[self check:@"Off" state:NSOffState] caption:@"Check off"
       expected:@{@"state":@0} eau:@"NSButtonCell+Eau.m"];
  [g add:[self check:@"On" state:NSOnState] caption:@"Check on"
       expected:@{@"state":@1} eau:@"NSButtonCell+Eau.m"];
  [g add:[self check:@"Mixed" state:NSMixedState] caption:@"Check mixed"
       expected:@{@"state":@(-1)} eau:@"NSButtonCell+Eau.m"];
  NSButton *cd = [self check:@"Disabled" state:NSOnState];
  [cd setEnabled:NO];
  [g add:cd caption:@"Check disabled" expected:@{@"enabled":@NO} eau:@"NSButtonCell+Eau.m"];

  // Row 4: radio group (NSMatrix)
  NSButtonCell *proto = [[NSButtonCell alloc] init];
  [proto setButtonType:NSRadioButton];
  [proto setTitle:@"Radio"];
  NSMatrix *radio = [[NSMatrix alloc] initWithFrame:NSMakeRect(0, 0, 80, 56)
                                               mode:NSRadioModeMatrix
                                          prototype:proto
                                       numberOfRows:3 numberOfColumns:1];
  [[[radio cells] objectAtIndex:0] setTitle:@"One"];
  [[[radio cells] objectAtIndex:1] setTitle:@"Two"];
  [[[radio cells] objectAtIndex:2] setTitle:@"Three"];
  [radio selectCellAtRow:1 column:0];
  [g add:radio caption:@"Radio group" expected:@{} eau:@"NSButtonCell+Eau.m"];

  // Row 5: NSSwitch (NEW Eau theming — Eau+Switch.m)
  [g add:[self sw:0 enabled:YES] caption:@"Switch off"
       expected:@{@"state":@0} eau:@"Eau+Switch.m"];
  [g add:[self sw:1 enabled:YES] caption:@"Switch on"
       expected:@{@"state":@1} eau:@"Eau+Switch.m"];
  NSSwitch *sd = [self sw:1 enabled:NO];
  [g add:sd caption:@"Switch disabled" expected:@{@"enabled":@NO} eau:@"Eau+Switch.m"];

  // Hidden state: a button that should draw nothing (caption still shows).
  NSButton *hid = [self push:@"Invisible"];
  [hid setHidden:YES];
  [g add:hid caption:@"Hidden" expected:@{@"hidden":@YES} eau:@"NSView (hidden)"];

  // A2: every NSBezelStyle (find crashes / odd rendering under Eau+Button.m)
  struct { NSBezelStyle s; const char *name; const char *title; } bz[] = {
    {NSThickSquareBezelStyle,     "Thick",      "Thick"},
    {NSThickerSquareBezelStyle,   "Thicker",    "Thicker"},
    {NSShadowlessSquareBezelStyle,"Shadowless", "Shadowless"},
    {NSTexturedSquareBezelStyle,  "TexturedSq", "Textured"},
    {NSSmallSquareBezelStyle,     "SmallSq",    "Small"},
    {NSTexturedRoundedBezelStyle, "TexRound",   "TexRound"},
    {NSRoundRectBezelStyle,       "RoundRect",  "RoundRect"},
    {NSRecessedBezelStyle,        "Recessed",   "Recessed"},
    {NSCircularBezelStyle,        "Circular",   "C"},
    {NSHelpButtonBezelStyle,      "Help",       ""},
    {NSDisclosureBezelStyle,      "Disclosure", ""},
    {NSRoundedDisclosureBezelStyle,"RoundDisc", ""},
  };
  for (int i = 0; i < (int)(sizeof(bz) / sizeof(bz[0])); i++) {
    NSButton *bb = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 84, 24)];
    [bb setBezelStyle:bz[i].s];
    if (bz[i].s == NSDisclosureBezelStyle || bz[i].s == NSRoundedDisclosureBezelStyle)
      [bb setButtonType:NSPushOnPushOffButton];
    NSString *title = [NSString stringWithUTF8String:bz[i].title];
    if ([title length]) [bb setTitle:title];
    [g add:bb caption:[NSString stringWithUTF8String:bz[i].name]
         expected:@{} eau:@"Eau+Button.m"];
  }

  NSView *content = [g build];
  NSRect cr = NSMakeRect(0, 0, g.contentSize.width, g.contentSize.height);
  NSWindow *win = [[NSWindow alloc] initWithContentRect:cr
                                              styleMask:(NSTitledWindowMask | NSClosableWindowMask
                                                         | NSMiniaturizableWindowMask)
                                                backing:NSBackingStoreBuffered defer:NO];
  [win setTitle:@"Buttons"];
  [win setContentView:content];
  [win setFrameOrigin:NSMakePoint(120, 360)];

  // Mark the default button (exercises Eau's setDefaultButtonCell: hook).
  [win setDefaultButtonCell:[def cell]];
  // Deterministic golden: no button steals the focus ring at rest.
  [win setInitialFirstResponder:content];

  [self trackWindow:win];
}

- (void)setupSpecimen
{
  [self buildStaticWindow];
}

@end
