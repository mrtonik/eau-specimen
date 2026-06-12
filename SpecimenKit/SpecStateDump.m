// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "SpecStateDump.h"
#import "SpecRegistry.h"
#import "SpecLog.h"

static NSDictionary *RectDict(NSRect r)
{
  return @{ @"x": @(r.origin.x), @"y": @(r.origin.y),
            @"w": @(r.size.width), @"h": @(r.size.height) };
}

@implementation SpecStateDump

+ (BOOL)view:(NSView *)view isFirstResponderOf:(NSWindow *)win
{
  id fr = [win firstResponder];
  if (fr == view) return YES;
  // While editing, the field editor (an NSText) is first responder; its delegate
  // is the field being edited.
  if ([fr isKindOfClass:[NSText class]] && [(NSText *)fr delegate] == (id)view)
    return YES;
  return NO;
}

+ (NSDictionary *)entryDict:(SpecEntry *)e
{
  NSView *v = e.view;
  NSMutableDictionary *d = [NSMutableDictionary dictionary];
  d[@"tag"] = @(e.tag);
  d[@"identifier"] = e.identifier;
  d[@"eau"] = e.eauFile;
  d[@"expected"] = e.expected;
  if (e.note) d[@"note"] = e.note;

  if (!v) { d[@"alive"] = @NO; return d; }
  d[@"alive"] = @YES;
  d[@"class"] = NSStringFromClass([v class]);

  NSWindow *win = [v window];
  d[@"window"] = [win title] ?: @"";
  d[@"windowKey"] = @([win isKeyWindow]);

  // frame in window base coords + absolute screen coords
  NSRect wf = [v convertRect:[v bounds] toView:nil];
  d[@"windowFrame"] = RectDict(wf);
  if (win) {
    NSPoint so = [win convertBaseToScreen:wf.origin];
    NSRect sf = NSMakeRect(so.x, so.y, wf.size.width, wf.size.height);
    d[@"screenFrame"] = RectDict(sf);
  }

  d[@"hidden"] = @([v isHidden]);
  d[@"alpha"] = @([v alphaValue]);
  if ([v respondsToSelector:@selector(isEnabled)])
    d[@"enabled"] = @([(NSControl *)v isEnabled]);
  if ([v respondsToSelector:@selector(state)])
    d[@"state"] = @([(NSButton *)v state]);   // -1 mixed / 0 off / 1 on
  if ([v respondsToSelector:@selector(stringValue)]) {
    NSString *sv = [(NSControl *)v stringValue];
    if (sv) d[@"stringValue"] = sv;
  }
  if ([v respondsToSelector:@selector(title)]) {
    NSString *t = [(NSButton *)v title];
    if (t) d[@"title"] = t;
  }

  // cell-level detail
  if ([v respondsToSelector:@selector(cell)]) {
    NSCell *c = [(NSControl *)v cell];
    if (c) {
      d[@"cellClass"] = NSStringFromClass([c class]);
      if ([c respondsToSelector:@selector(isHighlighted)])
        d[@"highlighted"] = @([c isHighlighted]);
      NSFont *f = [c font];
      if (f) { d[@"fontName"] = [f fontName]; d[@"fontSize"] = @([f pointSize]); }
    }
  }

  d[@"firstResponder"] = @([self view:v isFirstResponderOf:win]);

  BOOL isDefault = NO;
  if ([v isKindOfClass:[NSButton class]]) {
    if ([[(NSButton *)v keyEquivalent] isEqualToString:@"\r"]) isDefault = YES;
    if ([win respondsToSelector:@selector(defaultButtonCell)] &&
        [win defaultButtonCell] == [(NSButton *)v cell]) isDefault = YES;
  }
  d[@"isDefault"] = @(isDefault);

  return d;
}

+ (NSDictionary *)snapshot:(NSString *)specimenName
{
  NSMutableArray *widgets = [NSMutableArray array];
  for (SpecEntry *e in [[SpecRegistry shared] entries])
    [widgets addObject:[self entryDict:e]];
  return @{ @"specimen": specimenName ?: @"",
            @"ts": @([[NSDate date] timeIntervalSince1970]),
            @"widgets": widgets };
}

+ (NSString *)write:(NSString *)specimenName
{
  NSString *dir = nil;
  const char *env = getenv("SPECIMEN_DUMP_DIR");
  if (env) dir = [NSString stringWithUTF8String:env];
  if (!dir) dir = NSTemporaryDirectory();

  NSString *path = [dir stringByAppendingPathComponent:
                        [NSString stringWithFormat:@"%@.state.json", specimenName]];
  NSError *err = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:[self snapshot:specimenName]
                                                options:NSJSONWritingPrettyPrinted
                                                  error:&err];
  if (!data) { NSLog(@"SpecStateDump: serialize failed: %@", err); return nil; }
  if (![data writeToFile:path atomically:YES]) {
    NSLog(@"SpecStateDump: write failed: %@", path);
    return nil;
  }
  SpecLog(@"SpecStateDump: wrote %@ (%lu widgets)", path,
          (unsigned long)[[[SpecRegistry shared] entries] count]);
  return path;
}

@end
