// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "RangeController.h"
#import "SpecimenKit.h"

@implementation RangeController

- (NSString *)specimenName { return @"Range"; }

// ---- builders --------------------------------------------------------------

- (NSSlider *)slider:(double)v ticks:(NSInteger)ticks vertical:(BOOL)vert
{
  NSRect f = vert ? NSMakeRect(0, 0, 20, 54) : NSMakeRect(0, 0, 120, ticks ? 24 : 20);
  NSSlider *s = [[NSSlider alloc] initWithFrame:f];
  [s setMinValue:0.0];
  [s setMaxValue:1.0];
  [s setDoubleValue:v];
  if (ticks) [s setNumberOfTickMarks:ticks];
  // GNUstep infers vertical orientation from the frame aspect (h > w).
  return s;
}

- (NSProgressIndicator *)progressBar:(double)pct
{
  NSProgressIndicator *p = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 120, 16)];
  [p setStyle:NSProgressIndicatorBarStyle];
  [p setIndeterminate:NO];
  [p setMinValue:0.0];
  [p setMaxValue:100.0];
  [p setDoubleValue:pct];
  return p;
}

// ---- the static-states window ----------------------------------------------

- (void)buildWindow
{
  SpecGrid *g = [SpecGrid gridWithColumns:4 cellSize:NSMakeSize(150, 64)];

  // Sliders
  [g add:[self slider:0.0 ticks:0 vertical:NO] caption:@"NSSlider (min)"
       expected:@{} eau:@"Eau+Slider.m"];
  [g add:[self slider:0.5 ticks:0 vertical:NO] caption:@"NSSlider (mid)"
       expected:@{} eau:@"Eau+Slider.m"];
  [g add:[self slider:1.0 ticks:0 vertical:NO] caption:@"NSSlider (max)"
       expected:@{} eau:@"Eau+Slider.m"];
  [g add:[self slider:0.5 ticks:6 vertical:NO] caption:@"NSSlider (ticks)"
       expected:@{} eau:@"Eau+Slider.m"];

  [g add:[self slider:0.6 ticks:0 vertical:YES] caption:@"NSSlider (vert)"
       expected:@{} eau:@"Eau+Slider.m"];
  NSSlider *sd = [self slider:0.4 ticks:0 vertical:NO];
  [sd setEnabled:NO];
  [g add:sd caption:@"NSSlider (disabled)" expected:@{@"enabled":@NO} eau:@"Eau+Slider.m"];

  // Stepper
  NSStepper *st = [[NSStepper alloc] initWithFrame:NSMakeRect(0, 0, 19, 27)];
  [st setMinValue:0]; [st setMaxValue:10]; [st setIntValue:3];
  [g add:st caption:@"NSStepper" expected:@{} eau:@"Eau+Stepper.m"];
  NSStepper *st2 = [[NSStepper alloc] initWithFrame:NSMakeRect(0, 0, 19, 27)];
  [st2 setEnabled:NO];
  [g add:st2 caption:@"NSStepper (disabled)" expected:@{@"enabled":@NO} eau:@"Eau+Stepper.m"];

  // Progress (determinate = deterministic)
  [g add:[self progressBar:40.0] caption:@"NSProgressIndicator (40%)"
       expected:@{} eau:@"Eau+ProgressIndicator.m"];
  [g add:[self progressBar:80.0] caption:@"NSProgressIndicator (80%)"
       expected:@{} eau:@"Eau+ProgressIndicator.m"];

  // Spinner (indeterminate = ANIMATED → masked in goldens)
  NSProgressIndicator *spin = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
  [spin setStyle:NSProgressIndicatorSpinningStyle];
  [spin setIndeterminate:YES];
  [spin startAnimation:nil];
  [g add:spin caption:@"NSProgressIndicator (spinner)" expected:@{@"animated":@YES} eau:@"Eau+ProgressIndicator.m"];

  // Color well
  NSColorWell *cw = [[NSColorWell alloc] initWithFrame:NSMakeRect(0, 0, 44, 24)];
  [cw setColor:[NSColor colorWithCalibratedRed:0.2 green:0.5 blue:0.9 alpha:1.0]];
  [g add:cw caption:@"NSColorWell" expected:@{} eau:@"Eau+ColorWell.m"];

  // Segmented
  NSSegmentedControl *seg = [[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0, 0, 140, 24)];
  [seg setSegmentCount:3];
  [seg setLabel:@"One" forSegment:0];
  [seg setLabel:@"Two" forSegment:1];
  [seg setLabel:@"Three" forSegment:2];
  [seg setSelectedSegment:1];
  [g add:seg caption:@"NSSegmentedControl" expected:@{} eau:@"Eau+Segmented.m"];

  // A4: circular slider (does Eau+Slider.m handle the circular type?)
  NSSlider *circ = [[NSSlider alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
  [[circ cell] setSliderType:NSCircularSlider];
  [circ setMinValue:0]; [circ setMaxValue:1]; [circ setDoubleValue:0.3];
  [g add:circ caption:@"NSSlider (circular)" expected:@{} eau:@"Eau+Slider.m"];

  // Level indicator (NEW Eau theming — Eau+LevelIndicator.m fixes base GSTheme garbage)
  NSLevelIndicator *li = [[NSLevelIndicator alloc] initWithFrame:NSMakeRect(0, 0, 120, 18)];
  [li setMinValue:0]; [li setMaxValue:10]; [li setDoubleValue:6];
  [g add:li caption:@"NSLevelIndicator" expected:@{} eau:@"Eau+LevelIndicator.m"];

  // Date picker (NEW Eau theming — base draws bare text; masked until themed).
  // Fixed date for golden determinism.
  NSDatePicker *dp = [[NSDatePicker alloc] initWithFrame:NSMakeRect(0, 0, 140, 24)];
  [dp setDatePickerElements:(NSYearMonthDayDatePickerElementFlag)];
  [dp setDateValue:[NSDate dateWithTimeIntervalSince1970:0]];
  [g add:dp caption:@"NSDatePicker" expected:@{@"todoTheme":@YES} eau:@"Eau+DatePicker.m"];

  NSView *gridContent = [g build];
  CGFloat gw = g.contentSize.width, gh = g.contentSize.height;

  // A4: graphical (clock+calendar) NSDatePicker below the grid. Pinned date so
  // the clock/calendar are deterministic. RISKY widget — find crashes / live clock.
  CGFloat dpW = 200, dpH = 150, gap = 14, capH = 14;
  CGFloat totalH = gh + gap + dpH + capH + 12;
  NSView *content = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, gw, totalH)];
  [gridContent setFrameOrigin:NSMakePoint(0, totalH - gh)];
  [content addSubview:gridContent];

  NSDatePicker *gdp = [[NSDatePicker alloc] initWithFrame:NSMakeRect(24, 12 + capH, dpW, dpH)];
  [gdp setDatePickerStyle:NSClockAndCalendarDatePickerStyle];
  [gdp setDatePickerElements:(NSYearMonthDayDatePickerElementFlag
                              | NSHourMinuteSecondDatePickerElementFlag)];
  [gdp setDateValue:[NSDate dateWithTimeIntervalSince1970:1000000.0]];
  [content addSubview:gdp];
  NSTextField *dpCap = [[NSTextField alloc] initWithFrame:NSMakeRect(24, 12, dpW, capH)];
  [dpCap setStringValue:@"Date picker (graphical)"];
  [dpCap setBezeled:NO]; [dpCap setBordered:NO]; [dpCap setDrawsBackground:NO];
  [dpCap setEditable:NO]; [dpCap setSelectable:NO];
  [dpCap setFont:[NSFont systemFontOfSize:10]];
  [dpCap setTextColor:[NSColor darkGrayColor]];
  [content addSubview:dpCap];
  [[SpecRegistry shared] add:gdp identifier:@"NSDatePicker (graphical)"
                   expected:@{@"todoTheme":@YES} eau:@"NSDatePicker (base)"];

  NSRect cr = NSMakeRect(0, 0, gw, totalH);
  NSWindow *win = [[NSWindow alloc] initWithContentRect:cr
                                              styleMask:(NSTitledWindowMask | NSClosableWindowMask
                                                         | NSMiniaturizableWindowMask)
                                                backing:NSBackingStoreBuffered defer:NO];
  [win setTitle:@"Range"];
  [win setContentView:content];
  [win setFrameOrigin:NSMakePoint(120, 320)];
  [win setInitialFirstResponder:content];
  [self trackWindow:win];
}

- (void)setupSpecimen { [self buildWindow]; }

@end
