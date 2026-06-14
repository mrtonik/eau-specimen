// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "TextInputController.h"
#import "SpecimenKit.h"

@implementation TextInputController

- (NSString *)specimenName { return @"TextInput"; }

- (NSTextField *)field:(NSString *)value
{
  NSTextField *f = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 130, 22)];
  [f setStringValue:value];
  return f;
}

- (void)buildWindow
{
  SpecGrid *g = [SpecGrid gridWithColumns:4 cellSize:NSMakeSize(150, 44)];

  [g add:[self field:@"Hello"] caption:@"NSTextField"
       expected:@{@"stringValue":@"Hello"} eau:@"NSTextFieldCell+Eau.m"];

  [g add:[self field:@""] caption:@"NSTextField (empty)"
       expected:@{@"stringValue":@""} eau:@"NSTextFieldCell+Eau.m"];

  NSTextField *fd = [self field:@"Nope"];
  [fd setEnabled:NO];
  [g add:fd caption:@"NSTextField (disabled)"
       expected:@{@"enabled":@NO} eau:@"NSTextFieldCell+Eau.m"];

  NSTextField *fr = [self field:@"Round"];
  [[fr cell] setBezelStyle:NSTextFieldRoundedBezel];
  [g add:fr caption:@"NSTextField (rounded)"
       expected:@{} eau:@"NSTextFieldCell+Eau.m"];

  NSTextField *label = [self field:@"Static label"];
  [label setBezeled:NO]; [label setBordered:NO];
  [label setEditable:NO]; [label setSelectable:NO]; [label setDrawsBackground:NO];
  [g add:label caption:@"NSTextField (label)"
       expected:@{@"enabled":@YES} eau:@"NSTextFieldCell+Eau.m"];

  NSSecureTextField *sec = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 130, 22)];
  [sec setStringValue:@"secret"];
  [g add:sec caption:@"NSSecureTextField"
       expected:@{} eau:@"NSTextFieldCell+Eau.m"];

  NSSearchField *search = [[NSSearchField alloc] initWithFrame:NSMakeRect(0, 0, 130, 22)];
  [search setStringValue:@"query"];
  [g add:search caption:@"NSSearchField"
       expected:@{} eau:@"NSSearchFieldCell+Eau.m"];

  NSComboBox *combo = [[NSComboBox alloc] initWithFrame:NSMakeRect(0, 0, 130, 22)];
  [combo addItemsWithObjectValues:@[@"Alpha", @"Beta", @"Gamma"]];
  [combo setStringValue:@"Alpha"];
  [g add:combo caption:@"NSComboBox"
       expected:@{} eau:@"NSComboBoxCell (base)"];

  NSView *gridContent = [g build];
  CGFloat gw = g.contentSize.width, gh = g.contentSize.height;

  // A3: an NSTextView (scrolled) below the grid. Static (non-editable) — the
  // field-editing crash is a known separate issue; we only test rendering here.
  CGFloat tvH = 64, gap = 14, capH = 14;
  CGFloat totalH = gh + gap + tvH + capH + 12;
  NSView *content = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, gw, totalH)];
  [gridContent setFrameOrigin:NSMakePoint(0, totalH - gh)];
  [content addSubview:gridContent];

  NSScrollView *sv = [[NSScrollView alloc] initWithFrame:NSMakeRect(24, 12 + capH, gw - 48, tvH)];
  [sv setHasVerticalScroller:YES];
  [sv setBorderType:NSBezelBorder];
  NSTextView *tv = [[NSTextView alloc]
                       initWithFrame:NSMakeRect(0, 0, gw - 48 - 16, tvH)];
  [tv setString:@"NSTextView — multi-line text.\nSecond line for wrapping/scroll."];
  [tv setEditable:NO];
  [sv setDocumentView:tv];
  [content addSubview:sv];
  NSTextField *tvCap = [[NSTextField alloc] initWithFrame:NSMakeRect(24, 12, gw - 48, capH)];
  [tvCap setStringValue:@"Text view"];
  [tvCap setBezeled:NO]; [tvCap setBordered:NO]; [tvCap setDrawsBackground:NO];
  [tvCap setEditable:NO]; [tvCap setSelectable:NO];
  [tvCap setAlignment:NSCenterTextAlignment];
  [tvCap setFont:[NSFont systemFontOfSize:10]];
  [tvCap setTextColor:[NSColor darkGrayColor]];
  [content addSubview:tvCap];
  [[SpecRegistry shared] add:tv identifier:@"NSTextView" expected:@{} eau:@"NSTextView (base)"];

  NSRect cr = NSMakeRect(0, 0, gw, totalH);
  NSWindow *win = [[NSWindow alloc] initWithContentRect:cr
                                              styleMask:(NSTitledWindowMask | NSClosableWindowMask
                                                         | NSMiniaturizableWindowMask)
                                                backing:NSBackingStoreBuffered defer:NO];
  [win setTitle:@"TextInput"];
  [win setContentView:content];
  [win setFrameOrigin:NSMakePoint(140, 360)];
  // No initial first responder: deterministic static golden (no focus ring at rest).
  [win setInitialFirstResponder:nil];
  [self trackWindow:win];
}

- (void)setupSpecimen { [self buildWindow]; }

@end
