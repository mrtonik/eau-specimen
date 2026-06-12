// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import <AppKit/AppKit.h>
#import "TextInputController.h"

int main(int argc, const char **argv)
{
  @autoreleasepool {
    [NSApplication sharedApplication];
    TextInputController *c = [[TextInputController alloc] init];
    [NSApp setDelegate:c];
    [NSApp run];
  }
  return 0;
}
