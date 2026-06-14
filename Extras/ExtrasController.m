// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "ExtrasController.h"
#import "SpecimenKit.h"

// Gap-widgets (§7) rendered as-is to surface crashes / un-themed rendering under
// Eau. Per §11 (reference-only) we do NOT theme them here — just exercise them.
@implementation ExtrasController

- (NSString *)specimenName { return @"Extras"; }

- (void)place:(NSView *)v at:(NSRect)r caption:(NSString *)cap id:(NSString *)idn
          eau:(NSString *)eau into:(NSView *)content
{
  [v setFrame:r];
  [content addSubview:v];
  NSTextField *l = [[NSTextField alloc] initWithFrame:NSMakeRect(r.origin.x, r.origin.y - 16, r.size.width, 12)];
  [l setStringValue:cap];
  [l setBezeled:NO]; [l setBordered:NO]; [l setDrawsBackground:NO];
  [l setEditable:NO]; [l setSelectable:NO];
  [l setFont:[NSFont systemFontOfSize:10]]; [l setTextColor:[NSColor darkGrayColor]];
  [content addSubview:l];
  [[SpecRegistry shared] add:v identifier:idn expected:@{@"todoTheme":@YES} eau:eau];
}

- (void)setupSpecimen
{
  CGFloat rowGap = 16.0;
  CGFloat formH = 60.0, pathH = 22.0, matrixH = 56.0;
  CGFloat matrixY = METRICS_CONTENT_BOTTOM_MARGIN;
  CGFloat ivY = matrixY;
  CGFloat pathY = matrixY + matrixH + rowGap;
  CGFloat formY = pathY + pathH + rowGap;
  CGFloat totalH = formY + formH + SPEC_TOP_MARGIN;
  CGFloat totalW = SPEC_SIDE_MARGIN + 560 + SPEC_SIDE_MARGIN;
  NSView *content = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, totalW, totalH)];

  // NSForm — labeled-field matrix
  NSForm *form = [[NSForm alloc] initWithFrame:NSMakeRect(0, 0, 250, 60)];
  [form addEntry:@"Name"];
  [form addEntry:@"Email"];
  [self place:form at:NSMakeRect(24, formY, 250, 60) caption:@"NSForm"
           id:@"Form" eau:@"NSForm (base)" into:content];

  // NSTokenField — EXCLUDED. Instantiating it throws NSInvalidArgumentException
  // ("NSTokenFieldCell does not recognize defaultCompletionDelay") in this
  // GNUstep — the cell is incomplete, so the widget is unusable (not an Eau bug).
  // Documented finding; omitted so the rest of the specimen can run.

  // NSPathControl — breadcrumb path
  NSPathControl *path = [[NSPathControl alloc] initWithFrame:NSMakeRect(0, 0, 560, 22)];
  [path setURL:[NSURL fileURLWithPath:@"/System/Library/Themes"]];
  [self place:path at:NSMakeRect(SPEC_SIDE_MARGIN, pathY, 560, 22) caption:@"NSPathControl"
           id:@"Path" eau:@"NSPathControl (base)" into:content];

  // NSImageView with a bezel frame (NSImageCell)
  NSImageView *iv = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 56, 56)];
  [iv setImage:[NSApp applicationIconImage]];
  [iv setImageFrameStyle:NSImageFrameGrayBezel];
  [self place:iv at:NSMakeRect(SPEC_SIDE_MARGIN, ivY, 56, 56) caption:@"NSImageView"
           id:@"Image" eau:@"NSImageCell (base)" into:content];

  // NSMatrix — non-radio (highlight mode) grid of button cells
  NSButtonCell *proto = [[NSButtonCell alloc] init];
  [proto setButtonType:NSPushOnPushOffButton];
  NSMatrix *matrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(0, 0, 220, 56)
                                                mode:NSHighlightModeMatrix
                                           prototype:proto
                                        numberOfRows:2 numberOfColumns:2];
  NSArray *labels = @[@"One", @"Two", @"Three", @"Four"];
  NSArray *cells = [matrix cells];
  for (NSUInteger i = 0; i < [cells count] && i < [labels count]; i++)
    [[cells objectAtIndex:i] setTitle:labels[i]];
  [self place:matrix at:NSMakeRect(SPEC_SIDE_MARGIN + 56 + 16, matrixY, 220, 56) caption:@"NSMatrix (highlight)"
           id:@"Matrix" eau:@"NSMatrix (base)" into:content];

  NSWindow *win = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, totalW, totalH)
                                              styleMask:(NSTitledWindowMask | NSClosableWindowMask
                                                         | NSMiniaturizableWindowMask)
                                                backing:NSBackingStoreBuffered defer:NO];
  [win setTitle:@"Extras"];
  [win setContentView:content];
  [win setFrameOrigin:NSMakePoint(80, 280)];
  [win setInitialFirstResponder:content];
  [self trackWindow:win];
}

@end
