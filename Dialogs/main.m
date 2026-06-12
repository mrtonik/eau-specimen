// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import <AppKit/AppKit.h>
#import "DialogsController.h"

int main(int argc, const char **argv)
{
  @autoreleasepool {
    [NSApplication sharedApplication];
    DialogsController *c = [[DialogsController alloc] init];
    [NSApp setDelegate:c];
    [NSApp run];
  }
  return 0;
}
