// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "DialogsController.h"
#import "SpecimenKit.h"

@implementation DialogsController
{
  NSButton *_showButton;
  NSTextField *_result;
}

- (NSString *)specimenName { return @"Dialogs"; }

// Opens a 3-button modal alert (OK default, Cancel, Maybe). runModal blocks the
// main thread; the test triggers this via XTEST and inspects/dismisses through
// UIBridge (which works during a modal).
- (void)showAlert:(id)sender
{
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setMessageText:@"Test Alert"];
  [alert setInformativeText:@"Choose a button. OK is the default; Cancel responds to Escape."];
  [alert addButtonWithTitle:@"OK"];      // NSAlertFirstButtonReturn  (1000)
  [alert addButtonWithTitle:@"Cancel"];  // NSAlertSecondButtonReturn (1001)
  [alert addButtonWithTitle:@"Maybe"];   // NSAlertThirdButtonReturn  (1002)

  NSInteger r = [alert runModal];
  NSString *which = (r == NSAlertFirstButtonReturn) ? @"OK"
                  : (r == NSAlertSecondButtonReturn) ? @"Cancel"
                  : (r == NSAlertThirdButtonReturn) ? @"Maybe"
                  : [NSString stringWithFormat:@"%ld", (long)r];
  [_result setStringValue:[@"Result: " stringByAppendingString:which]];
  [SpecStateDump write:[self specimenName]];   // reflect once the modal ends
}

- (void)setupSpecimen
{
  NSRect cr = NSMakeRect(0, 0, 500, 130);
  NSView *content = [[NSView alloc] initWithFrame:cr];

  _showButton = [[NSButton alloc] initWithFrame:NSMakeRect(200, 80, 100, 24)];
  [_showButton setTitle:@"Show Alert"];
  [_showButton setBezelStyle:NSRoundedBezelStyle];
  [_showButton setTarget:self];
  [_showButton setAction:@selector(showAlert:)];
  [content addSubview:_showButton];
  [[SpecRegistry shared] add:_showButton identifier:@"ShowAlert" expected:@{} eau:@"NSAlert+Eau.m"];

  _result = [[NSTextField alloc] initWithFrame:NSMakeRect(40, 36, 420, 22)];
  [_result setStringValue:@"Result: (none)"];
  [_result setBezeled:NO]; [_result setBordered:NO]; [_result setDrawsBackground:NO];
  [_result setEditable:NO]; [_result setSelectable:NO];
  [_result setAlignment:NSCenterTextAlignment];
  [content addSubview:_result];
  [[SpecRegistry shared] add:_result identifier:@"Result"
                   expected:@{@"stringValue":@"Result: (none)"} eau:@"NSAlert+Eau.m"];

  NSWindow *win = [[NSWindow alloc] initWithContentRect:cr
                                              styleMask:(NSTitledWindowMask | NSClosableWindowMask
                                                         | NSMiniaturizableWindowMask)
                                                backing:NSBackingStoreBuffered defer:NO];
  [win setTitle:@"Dialogs"];
  [win setContentView:content];
  [win setFrameOrigin:NSMakePoint(160, 360)];
  [win setInitialFirstResponder:content];
  [self trackWindow:win];
}

@end
