//
//  TTModeMenuContainer.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMenuContainer.h"
#import "TTModeMenuItem.h"

@implementation TTModeMenuContainer

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
        northItem = [[TTModeMenuItem alloc] initWithFrame:itemFrame direction:NORTH];
        [self addSubview:northItem];
        
        itemFrame.origin.x = itemWidth * 1;
        eastItem = [[TTModeMenuItem alloc] initWithFrame:itemFrame direction:EAST];
        [self addSubview:eastItem];
        
        itemFrame.origin.x = itemWidth * 2;
        westItem = [[TTModeMenuItem alloc] initWithFrame:itemFrame direction:WEST];
        [self addSubview:westItem];

        itemFrame.origin.x = itemWidth * 3;
        southItem = [[TTModeMenuItem alloc] initWithFrame:itemFrame direction:SOUTH];
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
