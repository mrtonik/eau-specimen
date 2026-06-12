// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "SpecRegistry.h"

@implementation SpecEntry
@end

@implementation SpecRegistry
{
  NSMutableArray<SpecEntry *> *_entries;
  NSInteger _nextTag;
}

+ (instancetype)shared
{
  static SpecRegistry *s = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{ s = [[SpecRegistry alloc] init]; });
  return s;
}

- (instancetype)init
{
  if ((self = [super init])) {
    _entries = [NSMutableArray array];
    _nextTag = 1000;
  }
  return self;
}

- (SpecEntry *)add:(NSView *)view
        identifier:(NSString *)identifier
          expected:(NSDictionary *)expected
               eau:(NSString *)eauFile
{
  SpecEntry *e = [[SpecEntry alloc] init];
  e.tag = _nextTag++;
  e.identifier = identifier ?: @"";
  e.view = view;
  e.expected = expected ?: @{};
  e.eauFile = eauFile ?: @"";
  if ([view respondsToSelector:@selector(setTag:)])
    [(NSControl *)view setTag:e.tag];
  [_entries addObject:e];
  return e;
}

- (NSArray<SpecEntry *> *)entries { return _entries; }

- (void)reset { [_entries removeAllObjects]; _nextTag = 1000; }

@end
