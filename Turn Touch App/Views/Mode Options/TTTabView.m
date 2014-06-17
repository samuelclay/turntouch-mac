//
//  TTTabView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 5/14/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTTabView.h"
#import "TTSegmentedCell.h"

const NSUInteger SEGMENTED_CONTROL_HEIGHT = 24;

@implementation TTTabView

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        segmentedControl = [[NSSegmentedControl alloc] init];
        [segmentedControl setTranslatesAutoresizingMaskIntoConstraints:NO];
        [segmentedControl setCell:[[TTSegmentedCell alloc] init]];
        [segmentedControl setSegmentCount:self.numberOfTabViewItems];
        [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
        [segmentedControl setTarget:self];
        [segmentedControl setAction:@selector(ctrlSelected:)];
        for (int i=0; i < self.numberOfTabViewItems; i++) {
            [segmentedControl setLabel:[[self.tabViewItems objectAtIndex:i] label] forSegment:i];
        }
        [segmentedControl setSegmentStyle:NSSegmentStyleTexturedSquare];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:segmentedControl
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0 constant:0.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:segmentedControl
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:segmentedControl
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0 constant:0.0]];
        [self addSubview:segmentedControl];
        
        [self setTabViewType:NSNoTabsNoBorder];
        [self setDrawsBackground:NO];
        
        [segmentedControl setFrame:NSMakeRect(20, 0, self.frame.size.width, SEGMENTED_CONTROL_HEIGHT)];
    }
    
    return self;
}

- (NSSize)minimumSize {
    return NSMakeSize(1000, SEGMENTED_CONTROL_HEIGHT);
}

- (NSRect)contentRect {
    return NSMakeRect(0, SEGMENTED_CONTROL_HEIGHT, self.frame.size.width, self.frame.size.height-SEGMENTED_CONTROL_HEIGHT);
}

#pragma mark - Drawing

-(void)ctrlSelected:(NSSegmentedControl *)sender {
    [super selectTabViewItemAtIndex:[sender selectedSegment]];
}

-(void)selectTabViewItem:(NSTabViewItem *)tabViewItem {
    [super selectTabViewItem:tabViewItem];
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
}

-(void)selectTabViewItemAtIndex:(NSInteger)index {
    [super selectTabViewItemAtIndex:index];
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
}

-(void)selectTabViewItemWithIdentifier:(id)identifier {
    [super selectTabViewItemWithIdentifier:identifier];
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
}

-(void)addTabViewItem:(NSTabViewItem *)anItem {
    [super addTabViewItem:anItem];
    [self awakeFromNib];
    [self setNeedsDisplay:YES];
}

-(void)removeTabViewItem:(NSTabViewItem *)anItem {
    [super removeTabViewItem:anItem];
    [self awakeFromNib];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSBezierPath *line = [NSBezierPath bezierPath];
    
    [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds) + SEGMENTED_CONTROL_HEIGHT/2)];
    [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds) + SEGMENTED_CONTROL_HEIGHT/2)];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
}

@end
