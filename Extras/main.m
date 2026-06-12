// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import <AppKit/AppKit.h>
#import "ExtrasController.h"

int main(int argc, const char **argv)
{
  @autoreleasepool {
    [NSApplication sharedApplication];
    ExtrasController *c = [[ExtrasController alloc] init];
    [NSApp setDelegate:c];
    [NSApp run];
  }
  return 0;
}
