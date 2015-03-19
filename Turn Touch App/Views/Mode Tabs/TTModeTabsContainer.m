//
//  TTModeTabsContainer.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeTabsContainer.h"
#import "TTModeTab.h"

@implementation TTModeTabsContainer

@synthesize northItem;
@synthesize eastItem;
@synthesize westItem;
@synthesize southItem;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        northItem = [[TTModeTab alloc] initWithFrame:CGRectZero direction:NORTH];
        [self addSubview:northItem];
        
        eastItem = [[TTModeTab alloc] initWithFrame:CGRectZero direction:EAST];
        [self addSubview:eastItem];
        
        westItem = [[TTModeTab alloc] initWithFrame:CGRectZero direction:WEST];
        [self addSubview:westItem];

        southItem = [[TTModeTab alloc] initWithFrame:CGRectZero direction:SOUTH];
        [self addSubview:southItem];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
    [self drawBackground];
    NSRect itemFrame = self.frame;
    CGFloat itemWidth = NSWidth(self.frame) / 4;
    itemFrame.origin.y = 0;
    itemFrame.size.width = itemWidth;
    
    itemFrame.origin.x = itemWidth * 0;
    [northItem setFrame:itemFrame];
    
    itemFrame.origin.x = itemWidth * 1;
    [eastItem setFrame:itemFrame];
    
    itemFrame.origin.x = itemWidth * 2;
    [westItem setFrame:itemFrame];
    
    itemFrame.origin.x = itemWidth * 3;
    [southItem setFrame:itemFrame];
}

- (void)drawBackground {
    NSRect contentRect = NSInsetRect([self bounds], 0, 0);
    
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:[NSColor whiteColor]
                             endingColor:NSColorFromRGB(0xE7E7E7)];
    [aGradient drawInRect:contentRect angle:-90];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
    [clip appendBezierPathWithRect:contentRect];
    [clip addClip];
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
