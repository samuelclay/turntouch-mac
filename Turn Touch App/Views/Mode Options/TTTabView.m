//
//  TTTabView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 5/14/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTTabView.h"
#import "TTSegmentedControl.h"

const NSUInteger SEGMENTED_CONTROL_HEIGHT = 26;

@implementation TTTabView

#pragma mark - Init and sizing

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setTabViewType:NSNoTabsNoBorder];
    [self setDrawsBackground:NO];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    if (segmentedControl) {
        [segmentedControl removeFromSuperview];
        segmentedControl = nil;
    }

    segmentedControl = [[TTSegmentedControl alloc] init];
    [segmentedControl setSegmentCount:self.numberOfTabViewItems];
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
    [segmentedControl setTarget:self];
    [segmentedControl setAction:@selector(ctrlSelected:)];
    for (int i=0; i < self.numberOfTabViewItems; i++) {
        [segmentedControl setLabel:[[self.tabViewItems objectAtIndex:i] label] forSegment:i];
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:segmentedControl
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:segmentedControl
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:segmentedControl
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:SEGMENTED_CONTROL_HEIGHT]];
    [self addSubview:segmentedControl];
}

- (NSSize)minimumSize {
    return NSMakeSize(1000, 0);
}

- (NSRect)contentRect {
    return NSMakeRect(0, SEGMENTED_CONTROL_HEIGHT, NSWidth(self.bounds), NSHeight(self.bounds)-SEGMENTED_CONTROL_HEIGHT);
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    // Background above center line
    NSBezierPath *topBackground = [NSBezierPath bezierPath];
    [topBackground appendBezierPathWithRect:NSMakeRect(NSMinX(self.bounds),
                                                       NSMinY(self.bounds),
                                                       NSWidth(self.bounds),
                                                       SEGMENTED_CONTROL_HEIGHT/2)];
    [NSColorFromRGB(0xF5F6F8) set];
    [topBackground fill];

    // Center line
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds) + SEGMENTED_CONTROL_HEIGHT/2 + 0.5f)];
    [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds) + SEGMENTED_CONTROL_HEIGHT/2 + 0.5f)];
    [line setLineWidth:0.5f];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
    
    [super drawRect:dirtyRect];
}

#pragma mark - Events

- (void)ctrlSelected:(NSSegmentedControl *)sender {
    [super selectTabViewItemAtIndex:[sender selectedSegment]];
}

- (void)selectTabViewItem:(NSTabViewItem *)tabViewItem {
    [super selectTabViewItem:tabViewItem];
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
}

- (void)selectTabViewItemAtIndex:(NSInteger)index {
    [super selectTabViewItemAtIndex:index];
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
}

- (void)selectTabViewItemWithIdentifier:(id)identifier {
    [super selectTabViewItemWithIdentifier:identifier];
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
}

- (void)addTabViewItem:(NSTabViewItem *)anItem {
    [super addTabViewItem:anItem];
    [self awakeFromNib];
    [self setNeedsDisplay:YES];
}

- (void)removeTabViewItem:(NSTabViewItem *)anItem {
    [super removeTabViewItem:anItem];
    [self awakeFromNib];
    [self setNeedsDisplay:YES];
}

@end
