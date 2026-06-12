// SPDX-License-Identifier: BSD-2-Clause
// Copyright (C) 2026 Michael Hupp
//
// SpecMetrics.h — Eau HIG metric constants mirrored for the specimen apps.
//
// These mirror /Developer/Library/Sources/gershwin-eau-theme/AppearanceMetrics.h
// (which is private to the theme source and not installed). Both the specimen
// layout code and the Python test suite (uibridge/metrics.py) assert against
// these numbers — keep the two copies in sync.
//
#ifndef SPEC_METRICS_H
#define SPEC_METRICS_H

#import <AppKit/AppKit.h>

// Window / content margins
static const CGFloat SPEC_SIDE_MARGIN   = 24.0;  // window side -> controls
static const CGFloat SPEC_TOP_MARGIN    = 16.0;  // title bar -> first control (HIG 14-16)
static const CGFloat SPEC_BOTTOM_MARGIN = 20.0;  // window bottom -> controls

// Buttons
static const CGFloat SPEC_BUTTON_HEIGHT       = 20.0;  // normal push button
static const CGFloat SPEC_BUTTON_SMALL_HEIGHT = 17.0;  // small push button
static const CGFloat SPEC_BUTTON_MIN_WIDTH    = 69.0;

// Checkboxes / radios
static const CGFloat SPEC_RADIO_SIZE       = 18.0;
static const CGFloat SPEC_RADIO_SMALL_SIZE = 14.0;
static const CGFloat SPEC_RADIO_LINE_SPACING = 20.0;

// Text fields
static const CGFloat SPEC_FIELD_HEIGHT     = 22.0;
static const CGFloat SPEC_FIELD_SELECT_H   = 16.0;
static const CGFloat SPEC_FOCUS_RING_TOP   = 2.0;
static const CGFloat SPEC_FOCUS_RING_SIDES = 3.0;

// Tabs / scrollbars / dialog icon
static const CGFloat SPEC_TAB_HEIGHT       = 30.0;
static const CGFloat SPEC_TAB_SMALL_HEIGHT = 25.0;
static const CGFloat SPEC_SCROLLBAR_WIDTH  = 11.0;
static const CGFloat SPEC_DIALOG_ICON_SIDE = 64.0;

// Titlebar
static const CGFloat SPEC_TITLEBAR_HEIGHT  = 22.0;
static const CGFloat SPEC_TITLEBAR_RADIUS  = 4.0;
static const CGFloat SPEC_ORB_SIZE         = 15.0;

// Spacing grid
static const CGFloat SPEC_SPACE_8  = 8.0;
static const CGFloat SPEC_SPACE_12 = 12.0;
static const CGFloat SPEC_SPACE_16 = 16.0;
static const CGFloat SPEC_SPACE_20 = 20.0;
static const CGFloat SPEC_SPACE_24 = 24.0;

#endif
