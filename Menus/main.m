// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import <AppKit/AppKit.h>
#import "MenusController.h"

int main(int argc, const char **argv)
{
  @autoreleasepool {
    [NSApplication sharedApplication];
    MenusController *c = [[MenusController alloc] init];
    [NSApp setDelegate:c];
    [NSApp run];
  }
  return 0;
}
