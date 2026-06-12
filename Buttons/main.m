// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import <AppKit/AppKit.h>
#import "ButtonsController.h"

int main(int argc, const char **argv)
{
  @autoreleasepool {
    [NSApplication sharedApplication];
    ButtonsController *c = [[ButtonsController alloc] init];
    [NSApp setDelegate:c];
    [NSApp run];
  }
  return 0;
}
