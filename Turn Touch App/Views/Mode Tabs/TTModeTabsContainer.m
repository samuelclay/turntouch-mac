//
//  TTModeTabsContainer.m
//  Turn Touch App
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
        NSRect itemFrame = frame;
        CGFloat itemWidth = frame.size.width / 4;
        itemFrame.origin.y = 0;
        itemFrame.size.width = itemWidth;
        
        itemFrame.origin.x = itemWidth * 0;
        northItem = [[TTModeTab alloc] initWithFrame:itemFrame direction:NORTH];
        [self addSubview:northItem];
        
        itemFrame.origin.x = itemWidth * 1;
        eastItem = [[TTModeTab alloc] initWithFrame:itemFrame direction:EAST];
        [self addSubview:eastItem];
        
        itemFrame.origin.x = itemWidth * 2;
        westItem = [[TTModeTab alloc] initWithFrame:itemFrame direction:WEST];
        [self addSubview:westItem];

        itemFrame.origin.x = itemWidth * 3;
        southItem = [[TTModeTab alloc] initWithFrame:itemFrame direction:SOUTH];
        [self addSubview:southItem];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    [self drawBackground];
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
