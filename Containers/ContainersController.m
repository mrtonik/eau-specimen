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

  NSTextField *l = [[NSTextField alloc] initWithFrame:NSMakeRect(r.origin.x, r.origin.y - 16, r.size.width, 12)];
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
  CGFloat rowGap = 16.0;
  CGFloat boxH = 70.0;
  CGFloat boxY = METRICS_CONTENT_BOTTOM_MARGIN + 60 + 16 + 130 + rowGap;  // row3(60+16) + row2(130) + gap
  CGFloat tabY = METRICS_CONTENT_BOTTOM_MARGIN + 60 + 16;                  // row3(60) + gap
  CGFloat imgY = METRICS_CONTENT_BOTTOM_MARGIN;                            // bottom row

  CGFloat totalH = boxY + boxH + SPEC_TOP_MARGIN;
  CGFloat totalW = 700.0;
  CGFloat rightEdge = totalW - SPEC_SIDE_MARGIN;
  NSView *content = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, totalW, totalH)];

  // ---- Row 1: NSBox border types (NSBox+Eau.m) ----
  [self place:[self box:@"Groove" border:NSGrooveBorder] at:NSMakeRect(24, boxY, 150, boxH)
      caption:@"NSBox (groove)" id:@"NSBox (groove)" eau:@"NSBox+Eau.m" expected:@{} into:content];
  [self place:[self box:@"Line" border:NSLineBorder] at:NSMakeRect(200, boxY, 150, boxH)
      caption:@"NSBox (line)" id:@"NSBox (line)" eau:@"NSBox+Eau.m" expected:@{} into:content];
  [self place:[self box:@"Bezel" border:NSBezelBorder] at:NSMakeRect(376, boxY, 150, boxH)
      caption:@"NSBox (bezel)" id:@"NSBox (bezel)" eau:@"NSBox+Eau.m" expected:@{} into:content];
  [self place:[self box:nil border:NSNoBorder] at:NSMakeRect(552, boxY, 124, boxH)
      caption:@"NSBox (none)" id:@"NSBox (none)" eau:@"NSBox+Eau.m" expected:@{} into:content];

  // ---- Row 2: NSTabView + NSScrollView (span full width) ----
  CGFloat tabW = 320;
  CGFloat svX = SPEC_SIDE_MARGIN + tabW + 16;
  CGFloat svW = rightEdge - svX;
  NSTabView *tv = [[NSTabView alloc] initWithFrame:NSMakeRect(0, 0, tabW, 130)];
  for (NSString *name in @[@"First", @"Second", @"Third"]) {
    NSTabViewItem *it = [[NSTabViewItem alloc] initWithIdentifier:name];
    [it setLabel:name];
    [tv addTabViewItem:it];
  }
  [self place:tv at:NSMakeRect(SPEC_SIDE_MARGIN, tabY, tabW, 130)
      caption:@"NSTabView" id:@"NSTabView" eau:@"Eau+TabView.m" expected:@{} into:content];

  // a scroll view with an oversized document so both scrollers show (Eau+Scroller.m)
  NSScrollView *sv = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, svW, 130)];
  [sv setHasVerticalScroller:YES];
  [sv setHasHorizontalScroller:YES];
  [sv setBorderType:NSBezelBorder];
  NSView *doc = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, 400)];
  [sv setDocumentView:doc];
  [self place:sv at:NSMakeRect(svX, tabY, svW, 130)
      caption:@"NSScrollView" id:@"NSScrollView" eau:@"Eau+Scroller.m" expected:@{} into:content];

  // ---- Row 3: NSImageView frame styles (centered, evenly spread) ----
  struct { const char *cap; NSImageFrameStyle s; } frames[] = {
    {"None",  NSImageFrameNone},
    {"Photo", NSImageFramePhoto},
    {"Bezel", NSImageFrameGrayBezel},
    {"Groove", NSImageFrameGroove},
    {"Button", NSImageFrameButton},
  };
  CGFloat imgSpan = 5 * 60;  // total image width
  CGFloat imgGap = (rightEdge - SPEC_SIDE_MARGIN - imgSpan) / 4.0;
  if (imgGap < 16) imgGap = 16;
  CGFloat x = SPEC_SIDE_MARGIN;
  for (int i = 0; i < 5; i++) {
    NSString *cap = [NSString stringWithFormat:@"NSImageView (%s)", frames[i].cap];
    [self place:[self imageFrame:frames[i].s] at:NSMakeRect(x, imgY, 60, 60)
        caption:cap id:cap eau:@"Eau+Drawings.m" expected:@{} into:content];
    x += 60 + imgGap;
  }

  NSWindow *win = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, totalW, totalH)
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
