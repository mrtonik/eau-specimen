// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "SpecAppDelegate.h"
#import "SpecOverlay.h"
#import "SpecStateDump.h"
#import "SpecLog.h"

@implementation SpecAppDelegate
{
  NSMutableArray *_windows;
  NSMutableArray *_overlays;
  BOOL _overlayOn;
}

- (NSString *)specimenName { return [[NSProcessInfo processInfo] processName]; }

- (void)setupSpecimen { /* subclass overrides */ }

- (void)addExtraTopMenus:(NSMenu *)mainMenu { /* subclass overrides */ }

- (NSArray *)trackedWindows { return _windows; }

// ---- bold-font fix (mirror of the Clock gotcha fix) ----
- (void)installBoldFontFix
{
  NSFont *sys = [NSFont systemFontOfSize:0];
  NSFont *bold = [[NSFontManager sharedFontManager] convertFont:sys
                                                  toHaveTrait:NSBoldFontMask];
  if (bold && [bold fontName]) {
    [[NSUserDefaults standardUserDefaults]
        registerDefaults:@{ @"NSBoldFont": [bold fontName] }];
    SpecLog(@"Spec: registered NSBoldFont=%@", [bold fontName]);
  }
}

// ---- minimal menu ----
- (void)buildMenu
{
  NSMenu *main = [[NSMenu alloc] initWithTitle:@"Main"];
  [main setAutoenablesItems:NO];

  NSMenuItem *appItem = [[NSMenuItem alloc] initWithTitle:[self specimenName]
                                                   action:NULL keyEquivalent:@""];
  NSMenu *appMenu = [[NSMenu alloc] initWithTitle:[self specimenName]];
  [appMenu setAutoenablesItems:NO];
  [appMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
  [appItem setSubmenu:appMenu];
  [main addItem:appItem];

  [self addExtraTopMenus:main];

  NSMenuItem *dbgItem = [[NSMenuItem alloc] initWithTitle:@"Debug" action:NULL keyEquivalent:@""];
  NSMenu *dbg = [[NSMenu alloc] initWithTitle:@"Debug"];
  [dbg setAutoenablesItems:NO];
  id<NSMenuItem> dump = [dbg addItemWithTitle:@"Dump State"
                                    action:@selector(dumpState:) keyEquivalent:@"d"];
  [dump setTarget:self];
  id<NSMenuItem> ov = [dbg addItemWithTitle:@"Toggle Overlay"
                                  action:@selector(toggleOverlay:) keyEquivalent:@"D"];
  [ov setKeyEquivalentModifierMask:NSCommandKeyMask | NSShiftKeyMask];
  [ov setTarget:self];
  [dbgItem setSubmenu:dbg];
  [main addItem:dbgItem];

  [NSApp setMainMenu:main];
}

- (void)trackWindow:(NSWindow *)win
{
  if (!_windows) { _windows = [NSMutableArray array]; _overlays = [NSMutableArray array]; }
  [_windows addObject:win];
  [_overlays addObject:[SpecOverlay attachToWindow:win]];
  [win makeKeyAndOrderFront:nil];
  // Deterministic rest state: don't let the first text field auto-grab focus
  // (which would draw a focus ring / selection into the static golden). The
  // window itself becomes first responder; interactive tests focus widgets
  // explicitly via XTEST.
  [win makeFirstResponder:win];
}

// ---- lifecycle ----
- (void)applicationWillFinishLaunching:(NSNotification *)n
{
  [self installBoldFontFix];
  [self buildMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)n
{
  [self setupSpecimen];

  if (getenv("SPECIMEN_OVERLAY")) {
    _overlayOn = YES;
    for (SpecOverlay *o in _overlays) [o setHidden:NO];
  }

  // Dump after the run loop settles so geometry/first-responder are final.
  [self performSelector:@selector(dumpState:) withObject:nil afterDelay:0.4];

  // Optional periodic re-dump so tests can read fresh state after driving a
  // transient state (hover/press/focus) via XTEST, without invoking a menu
  // (which would disturb focus and risk the auto-enable responder walk).
  const char *iv = getenv("SPECIMEN_DUMP_INTERVAL");
  if (iv) {
    double secs = atof(iv);
    if (secs > 0.05) {
      // Add to common modes (not just default) so the dump keeps firing while a
      // field is being edited or a control is tracking the mouse — exactly when
      // interactive-state tests need a fresh snapshot.
      NSTimer *tmr = [NSTimer timerWithTimeInterval:secs
                                             target:self
                                           selector:@selector(dumpState:)
                                           userInfo:nil
                                            repeats:YES];
      [[NSRunLoop currentRunLoop] addTimer:tmr forMode:NSRunLoopCommonModes];
    }
  }
}

// ---- actions ----
- (void)dumpState:(id)sender
{
  [SpecStateDump write:[self specimenName]];
}

- (void)toggleOverlay:(id)sender
{
  _overlayOn = !_overlayOn;
  for (SpecOverlay *o in _overlays) {
    [o setHidden:!_overlayOn];
    [o setNeedsDisplay:YES];
  }
}

@end
