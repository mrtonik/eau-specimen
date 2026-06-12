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
  NSView *content = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 700, 420)];

  // Table view (Eau+Table.m / NSTableHeaderCell+Eau.m)
  NSTableView *table = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 300, 150)];
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
  NSScrollView *tableSV = [self scrolled:table frame:NSMakeRect(24, 236, 300, 150)];
  [content addSubview:tableSV];
  [self label:@"Table view (row selected)" at:NSMakeRect(24, 220, 300, 12) into:content];
  [[SpecRegistry shared] add:table identifier:@"Table" expected:@{} eau:@"Eau+Table.m"];

  // Outline view (disclosure triangles)
  NSOutlineView *outline = [[NSOutlineView alloc] initWithFrame:NSMakeRect(0, 0, 300, 150)];
  NSTableColumn *oc = [[NSTableColumn alloc] initWithIdentifier:@"name"];
  [[oc headerCell] setStringValue:@"Tree"];
  [oc setWidth:280];
  [outline addTableColumn:oc];
  [outline setOutlineTableColumn:oc];
  [outline setDataSource:self];
  [outline setDelegate:self];
  [outline reloadData];
  for (id node in _tree) [outline expandItem:node];
  NSScrollView *outlineSV = [self scrolled:outline frame:NSMakeRect(360, 236, 300, 150)];
  [content addSubview:outlineSV];
  [self label:@"Outline view (expanded)" at:NSMakeRect(360, 220, 300, 12) into:content];
  [[SpecRegistry shared] add:outline identifier:@"Outline" expected:@{} eau:@"Eau+Table.m"];

  // Browser (Eau+Browser.m / NSBrowserCell+Eau.m)
  NSBrowser *browser = [[NSBrowser alloc] initWithFrame:NSMakeRect(24, 40, 636, 150)];
  [browser setMaxVisibleColumns:3];
  [browser setDelegate:self];
  [browser loadColumnZero];
  [content addSubview:browser];
  [self label:@"Browser" at:NSMakeRect(24, 24, 636, 12) into:content];
  [[SpecRegistry shared] add:browser identifier:@"Browser" expected:@{} eau:@"Eau+Browser.m"];

  NSWindow *win = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 700, 420)
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
