// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "SpecOverlay.h"
#import "SpecRegistry.h"

@implementation SpecOverlay

+ (SpecOverlay *)attachToWindow:(NSWindow *)win
{
  NSView *content = [win contentView];
  SpecOverlay *o = [[SpecOverlay alloc] initWithFrame:[content bounds]];
  [o setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [o setHidden:YES];
  [content addSubview:o positioned:NSWindowAbove relativeTo:nil];
  return o;
}

// Click-through: never intercept events.
- (NSView *)hitTest:(NSPoint)p { return nil; }

- (void)drawRect:(NSRect)dirty
{
  for (SpecEntry *e in [[SpecRegistry shared] entries]) {
    NSView *v = e.view;
    if (!v || [v window] != [self window] || [v isHidden]) continue;
    NSRect r = [v convertRect:[v bounds] toView:self];
    if (!NSIntersectsRect(r, dirty)) continue;

    // frame outline
    [[NSColor colorWithCalibratedRed:0.9 green:0.1 blue:0.1 alpha:0.85] set];
    NSBezierPath *p = [NSBezierPath bezierPathWithRect:NSInsetRect(r, 0.5, 0.5)];
    [p setLineWidth:1.0];
    [p stroke];

    // horizontal mid line (rough baseline guide)
    [[NSColor colorWithCalibratedRed:0.1 green:0.4 blue:0.9 alpha:0.5] set];
    NSBezierPath *mid = [NSBezierPath bezierPath];
    [mid moveToPoint:NSMakePoint(r.origin.x, NSMidY(r))];
    [mid lineToPoint:NSMakePoint(NSMaxX(r), NSMidY(r))];
    [mid setLineWidth:0.5];
    [mid stroke];

    // tag label
    NSString *label = [NSString stringWithFormat:@"%ld", (long)e.tag];
    NSDictionary *attrs = @{
      NSFontAttributeName: [NSFont systemFontOfSize:8],
      NSForegroundColorAttributeName: [NSColor colorWithCalibratedRed:0.9 green:0.1 blue:0.1 alpha:1.0]
    };
    [label drawAtPoint:NSMakePoint(r.origin.x + 1, NSMaxY(r) - 10) withAttributes:attrs];
  }
}

@end
