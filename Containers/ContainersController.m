// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "ContainersController.h"
#import "SpecimenKit.h"

@implementation ContainersController

- (NSString *)specimenName { return @"Containers"; }

// Place a widget at an absolute rect in `content`, add a caption under it, and
// register it. content is non-flipped (origin bottom-left).
- (void)place:(NSView *)v
           at:(NSRect)r
      caption:(NSString *)caption
           id:(NSString *)idn
          eau:(NSString *)eau
     expected:(NSDictionary *)exp
         into:(NSView *)content
{
  [v setFrame:r];
  [content addSubview:v];

  NSTextField *l = [[NSTextField alloc] initWithFrame:NSMakeRect(r.origin.x, r.origin.y - 15, r.size.width, 12)];
  [l setStringValue:caption];
  [l setBezeled:NO]; [l setBordered:NO]; [l setDrawsBackground:NO];
  [l setEditable:NO]; [l setSelectable:NO];
  [l setAlignment:NSCenterTextAlignment];
  [l setFont:[NSFont systemFontOfSize:10]];
  [l setTextColor:[NSColor darkGrayColor]];
  [content addSubview:l];

  [[SpecRegistry shared] add:v identifier:idn expected:exp eau:eau];
}

- (NSBox *)box:(NSString *)title border:(NSBorderType)bt
{
  NSBox *b = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, 150, 70)];
  [b setBorderType:bt];
  if (title) { [b setTitle:title]; [b setTitlePosition:NSAtTop]; }
  else { [b setTitlePosition:NSNoTitle]; }
  return b;
}

- (NSImageView *)imageFrame:(NSImageFrameStyle)style
{
  NSImageView *iv = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 60, 60)];
  [iv setImage:[NSApp applicationIconImage]];
  [iv setImageFrameStyle:style];
  [iv setImageScaling:NSImageScaleProportionallyUpOrDown];
  return iv;
}

- (void)buildWindow
{
  NSView *content = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 700, 430)];

  // ---- Row 1: NSBox border types (NSBox+Eau.m) ----
  [self place:[self box:@"Groove" border:NSGrooveBorder] at:NSMakeRect(24, 330, 150, 70)
      caption:@"Box groove" id:@"Box groove" eau:@"NSBox+Eau.m" expected:@{} into:content];
  [self place:[self box:@"Line" border:NSLineBorder] at:NSMakeRect(200, 330, 150, 70)
      caption:@"Box line" id:@"Box line" eau:@"NSBox+Eau.m" expected:@{} into:content];
  [self place:[self box:@"Bezel" border:NSBezelBorder] at:NSMakeRect(376, 330, 150, 70)
      caption:@"Box bezel" id:@"Box bezel" eau:@"NSBox+Eau.m" expected:@{} into:content];
  [self place:[self box:nil border:NSNoBorder] at:NSMakeRect(552, 330, 124, 70)
      caption:@"Box none" id:@"Box none" eau:@"NSBox+Eau.m" expected:@{} into:content];

  // ---- Row 2: NSTabView (Eau+TabView.m) ----
  NSTabView *tv = [[NSTabView alloc] initWithFrame:NSMakeRect(0, 0, 320, 130)];
  for (NSString *name in @[@"First", @"Second", @"Third"]) {
    NSTabViewItem *it = [[NSTabViewItem alloc] initWithIdentifier:name];
    [it setLabel:name];
    [tv addTabViewItem:it];
  }
  [self place:tv at:NSMakeRect(24, 150, 320, 130)
      caption:@"Tab view" id:@"Tab view" eau:@"Eau+TabView.m" expected:@{} into:content];

  // a scroll view with an oversized document so both scrollers show (Eau+Scroller.m)
  NSScrollView *sv = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 200, 130)];
  [sv setHasVerticalScroller:YES];
  [sv setHasHorizontalScroller:YES];
  [sv setBorderType:NSBezelBorder];
  NSView *doc = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, 400)];
  [sv setDocumentView:doc];
  [self place:sv at:NSMakeRect(376, 150, 200, 130)
      caption:@"Scroll view" id:@"Scroll view" eau:@"Eau+Scroller.m" expected:@{} into:content];

  // ---- Row 3: NSImageView frame styles (NEW theming — drawBorderForImageFrameStyle) ----
  struct { const char *cap; NSImageFrameStyle s; } frames[] = {
    {"None",  NSImageFrameNone},
    {"Photo", NSImageFramePhoto},
    {"Bezel", NSImageFrameGrayBezel},
    {"Groove", NSImageFrameGroove},
    {"Button", NSImageFrameButton},
  };
  CGFloat x = 24;
  for (int i = 0; i < 5; i++) {
    NSString *cap = [NSString stringWithFormat:@"Img %s", frames[i].cap];
    // base GSTheme draws these acceptably; Eau-specific styling is optional polish
    [self place:[self imageFrame:frames[i].s] at:NSMakeRect(x, 40, 60, 60)
        caption:cap id:cap eau:@"Eau+Drawings.m" expected:@{} into:content];
    x += 100;
  }

  NSWindow *win = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 700, 430)
                                              styleMask:(NSTitledWindowMask | NSClosableWindowMask
                                                         | NSMiniaturizableWindowMask)
                                                backing:NSBackingStoreBuffered defer:NO];
  [win setTitle:@"Containers"];
  [win setContentView:content];
  [win setFrameOrigin:NSMakePoint(100, 280)];
  [win setInitialFirstResponder:content];
  [self trackWindow:win];
}

- (void)setupSpecimen { [self buildWindow]; }

@end
