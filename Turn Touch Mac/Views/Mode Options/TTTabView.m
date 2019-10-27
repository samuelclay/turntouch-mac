//
//  TTTabView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/14/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTTabView.h"
#import "TTSegmentedControl.h"

const NSUInteger SEGMENTED_CONTROL_HEIGHT = 26;

@interface TTTabView ()

@property (nonatomic, strong) NSSegmentedControl *segmentedControl;

@end

@implementation TTTabView

#pragma mark - Init and sizing

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setTabViewType:NSNoTabsNoBorder];
    [self setDrawsBackground:NO];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    if (self.segmentedControl) {
        [self.segmentedControl removeFromSuperview];
        self.segmentedControl = nil;
    }

    self.segmentedControl = [[TTSegmentedControl alloc] init];
    [self.segmentedControl setSegmentCount:self.numberOfTabViewItems];
    [self.segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
    [self.segmentedControl setTarget:self];
    [self.segmentedControl setAction:@selector(ctrlSelected:)];
    for (int i=0; i < self.numberOfTabViewItems; i++) {
        [self.segmentedControl setLabel:[[self.tabViewItems objectAtIndex:i] label] forSegment:i];
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:SEGMENTED_CONTROL_HEIGHT]];
    [self addSubview:self.segmentedControl];
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
    [NSColorFromRGB(0xC2CBCE) set];
    [line stroke];
    
    [super drawRect:dirtyRect];
}

#pragma mark - Events

- (void)ctrlSelected:(NSSegmentedControl *)sender {
    [super selectTabViewItemAtIndex:[sender selectedSegment]];
}

- (void)selectTabViewItem:(NSTabViewItem *)tabViewItem {
    [super selectTabViewItem:tabViewItem];
    [self.segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
}

- (void)selectTabViewItemAtIndex:(NSInteger)index {
    [super selectTabViewItemAtIndex:index];
    [self.segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
}

- (void)selectTabViewItemWithIdentifier:(id)identifier {
    [super selectTabViewItemWithIdentifier:identifier];
    [self.segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
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
