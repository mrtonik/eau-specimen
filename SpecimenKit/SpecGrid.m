// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "SpecGrid.h"
#import "SpecMetrics.h"
#import "SpecRegistry.h"

@implementation SpecGrid
{
  NSInteger _cols;
  NSSize    _cell;
  NSMutableArray *_widgets;   // NSView
  NSMutableArray *_captions;  // NSString
  NSMutableArray *_expected;  // NSDictionary
  NSMutableArray *_eau;       // NSString
}

static const CGFloat kCaptionH = 14.0;
static const CGFloat kGapX = 12.0;
static const CGFloat kGapY = 16.0;

+ (instancetype)gridWithColumns:(NSInteger)cols cellSize:(NSSize)cellSize
{
  SpecGrid *g = [[SpecGrid alloc] init];
  g->_cols = MAX(1, cols);
  g->_cell = cellSize;
  g->_widgets  = [NSMutableArray array];
  g->_captions = [NSMutableArray array];
  g->_expected = [NSMutableArray array];
  g->_eau      = [NSMutableArray array];
  return g;
}

- (void)add:(NSView *)widget
    caption:(NSString *)caption
   expected:(NSDictionary *)expected
        eau:(NSString *)eauFile
{
  [_widgets addObject:widget];
  [_captions addObject:(caption ?: @"")];
  [_expected addObject:(expected ?: @{})];
  [_eau addObject:(eauFile ?: @"")];
}

- (NSTextField *)captionLabel:(NSString *)text frame:(NSRect)f
{
  NSTextField *l = [[NSTextField alloc] initWithFrame:f];
  [l setStringValue:text];
  [l setBezeled:NO];
  [l setBordered:NO];
  [l setDrawsBackground:NO];
  [l setEditable:NO];
  [l setSelectable:NO];
  [l setAlignment:NSCenterTextAlignment];
  [l setFont:[NSFont systemFontOfSize:10]];
  [l setTextColor:[NSColor darkGrayColor]];
  return l;
}

- (NSView *)build
{
  NSInteger n = (NSInteger)[_widgets count];
  NSInteger rows = (n + _cols - 1) / _cols;
  if (rows < 1) rows = 1;

  CGFloat totalW = 2 * SPEC_SIDE_MARGIN + _cols * _cell.width + (_cols - 1) * kGapX;
  CGFloat totalH = SPEC_TOP_MARGIN + rows * _cell.height + (rows - 1) * kGapY + SPEC_BOTTOM_MARGIN;
  _contentSize = NSMakeSize(totalW, totalH);

  NSView *content = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, totalW, totalH)];

  for (NSInteger i = 0; i < n; i++) {
    NSInteger col = i % _cols;
    NSInteger row = i / _cols;  // 0 = top
    CGFloat cellLeft = SPEC_SIDE_MARGIN + col * (_cell.width + kGapX);
    // top-origin y of this cell, then flip to bottom-left
    CGFloat cellTopY = SPEC_TOP_MARGIN + row * (_cell.height + kGapY);
    CGFloat cellBottomY = totalH - (cellTopY + _cell.height);

    NSView *w = _widgets[i];
    NSSize ws = w.frame.size;
    CGFloat wx = cellLeft + (_cell.width - ws.width) / 2.0;
    CGFloat areaH = _cell.height - kCaptionH;
    CGFloat wy = cellBottomY + kCaptionH + (areaH - ws.height) / 2.0;
    [w setFrameOrigin:NSMakePoint(floor(wx), floor(wy))];
    [content addSubview:w];

    NSTextField *cap = [self captionLabel:_captions[i]
                                    frame:NSMakeRect(cellLeft, cellBottomY, _cell.width, kCaptionH)];
    [content addSubview:cap];

    [[SpecRegistry shared] add:w
                     identifier:_captions[i]
                       expected:_expected[i]
                            eau:_eau[i]];
  }
  return content;
}

@end
