// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
#import "ListsController.h"
#import "SpecimenKit.h"

@implementation ListsController
{
  NSArray *_rows;       // table: array of @{name,value}
  NSArray *_tree;       // outline: array of node dicts {name, children}
  NSArray *_browserCol; // browser column 0 items
}

- (NSString *)specimenName { return @"Lists"; }

- (void)seedData
{
  _rows = @[@{@"name": @"Apple",  @"value": @"red"},
            @{@"name": @"Banana", @"value": @"yellow"},
            @{@"name": @"Cherry", @"value": @"dark red"},
            @{@"name": @"Date",   @"value": @"brown"},
            @{@"name": @"Elder",  @"value": @"black"}];
  _tree = @[@{@"name": @"Fruit", @"children": @[@{@"name": @"Apple"}, @{@"name": @"Pear"}]},
            @{@"name": @"Veg",   @"children": @[@{@"name": @"Carrot"}]}];
  _browserCol = @[@"Alpha", @"Beta", @"Gamma"];
}

// ---- NSTableView data source ----
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tv { return (NSInteger)[_rows count]; }
- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)col row:(NSInteger)row
{
  return _rows[row][[col identifier]];
}

// ---- NSOutlineView data source ----
- (NSInteger)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
  if (item == nil) return (NSInteger)[_tree count];
  return (NSInteger)[[item objectForKey:@"children"] count];
}
- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)idx ofItem:(id)item
{
  if (item == nil) return _tree[idx];
  return [item objectForKey:@"children"][idx];
}
- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
  return [[item objectForKey:@"children"] count] > 0;
}
- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)col byItem:(id)item
{
  return [item objectForKey:@"name"];
}

// ---- NSBrowser delegate ----
- (NSInteger)browser:(NSBrowser *)b numberOfRowsInColumn:(NSInteger)col
{
  return col == 0 ? (NSInteger)[_browserCol count] : 0;
}
- (void)browser:(NSBrowser *)b willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)col
{
  if (col == 0) { [cell setStringValue:_browserCol[row]]; [cell setLeaf:YES]; }
}

- (NSScrollView *)scrolled:(NSView *)doc frame:(NSRect)f
{
  NSScrollView *sv = [[NSScrollView alloc] initWithFrame:f];
  [sv setHasVerticalScroller:YES];
  [sv setBorderType:NSBezelBorder];
  [sv setDocumentView:doc];
  return sv;
}

- (void)label:(NSString *)text at:(NSRect)r into:(NSView *)content
{
  NSTextField *l = [[NSTextField alloc] initWithFrame:r];
  [l setStringValue:text];
  [l setBezeled:NO]; [l setBordered:NO]; [l setDrawsBackground:NO];
  [l setEditable:NO]; [l setSelectable:NO];
  [l setAlignment:NSCenterTextAlignment];
  [l setFont:[NSFont systemFontOfSize:10]];
  [l setTextColor:[NSColor darkGrayColor]];
  [content addSubview:l];
}

- (void)buildWindow
{
  [self seedData];

  CGFloat rowGap = 16.0;
  CGFloat listH = 150.0, browserH = 150.0, capH = 12.0;
  CGFloat browserY = METRICS_CONTENT_BOTTOM_MARGIN;
  CGFloat capY = browserY + browserH + 4;
  CGFloat listY = capY + capH + rowGap;
  CGFloat totalH = listY + listH + SPEC_TOP_MARGIN;
  CGFloat listW = 300;
  CGFloat listGap = 12;
  CGFloat totalW = SPEC_SIDE_MARGIN + listW + listGap + listW + SPEC_SIDE_MARGIN;
  CGFloat bw = totalW - 2 * SPEC_SIDE_MARGIN;  // browser spans full width
  NSView *content = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, totalW, totalH)];

  // Table view (Eau+Table.m / NSTableHeaderCell+Eau.m)
  NSTableView *table = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 300, listH)];
  for (NSArray *cd in @[@[@"name", @"Name", @170], @[@"value", @"Value", @110]]) {
    NSTableColumn *c = [[NSTableColumn alloc] initWithIdentifier:cd[0]];
    [[c headerCell] setStringValue:cd[1]];
    [c setWidth:[cd[2] floatValue]];
    [table addTableColumn:c];
  }
  [table setDataSource:self];
  [table setDelegate:self];
  [table reloadData];
  [table selectRowIndexes:[NSIndexSet indexSetWithIndex:2] byExtendingSelection:NO];
  NSScrollView *tableSV = [self scrolled:table frame:NSMakeRect(SPEC_SIDE_MARGIN, listY, listW, listH)];
  [content addSubview:tableSV];
  [self label:@"NSTableView (selected)" at:NSMakeRect(SPEC_SIDE_MARGIN, listY - 4 - capH, listW, capH) into:content];
  [[SpecRegistry shared] add:table identifier:@"NSTableView" expected:@{} eau:@"Eau+Table.m"];

  // Outline view (disclosure triangles)
  NSOutlineView *outline = [[NSOutlineView alloc] initWithFrame:NSMakeRect(0, 0, 300, listH)];
  NSTableColumn *oc = [[NSTableColumn alloc] initWithIdentifier:@"name"];
  [[oc headerCell] setStringValue:@"Tree"];
  [oc setWidth:280];
  [outline addTableColumn:oc];
  [outline setOutlineTableColumn:oc];
  [outline setDataSource:self];
  [outline setDelegate:self];
  [outline reloadData];
  for (id node in _tree) [outline expandItem:node];
  NSScrollView *outlineSV = [self scrolled:outline frame:NSMakeRect(SPEC_SIDE_MARGIN + listW + listGap, listY, listW, listH)];
  [content addSubview:outlineSV];
  [self label:@"NSOutlineView (expanded)" at:NSMakeRect(SPEC_SIDE_MARGIN + listW + listGap, listY - 4 - capH, listW, capH) into:content];
  [[SpecRegistry shared] add:outline identifier:@"NSOutlineView" expected:@{} eau:@"Eau+Table.m"];

  // Browser (Eau+Browser.m / NSBrowserCell+Eau.m)
  NSBrowser *browser = [[NSBrowser alloc] initWithFrame:NSMakeRect(SPEC_SIDE_MARGIN, browserY, bw, browserH)];
  [browser setMaxVisibleColumns:3];
  [browser setDelegate:self];
  [browser loadColumnZero];
  [content addSubview:browser];
  [self label:@"NSBrowser" at:NSMakeRect(SPEC_SIDE_MARGIN, browserY - 4 - capH, bw, capH) into:content];
  [[SpecRegistry shared] add:browser identifier:@"NSBrowser" expected:@{} eau:@"Eau+Browser.m"];

  NSWindow *win = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, totalW, totalH)
                                              styleMask:(NSTitledWindowMask | NSClosableWindowMask
                                                         | NSMiniaturizableWindowMask)
                                                backing:NSBackingStoreBuffered defer:NO];
  [win setTitle:@"Lists"];
  [win setContentView:content];
  [win setFrameOrigin:NSMakePoint(100, 280)];
  [win setInitialFirstResponder:content];
  [self trackWindow:win];
}

- (void)setupSpecimen { [self buildWindow]; }

@end
