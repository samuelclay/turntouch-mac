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
        
        itemFrame.origin.y = frame.size.height * 3;
        northItem = [[TTModeMenuItem alloc] initWithFrame:itemFrame direction:NORTH];
        [self addSubview:northItem];
        
        itemFrame.origin.y = frame.size.height * 2;
        eastItem = [[TTModeMenuItem alloc] initWithFrame:itemFrame direction:EAST];
        [self addSubview:eastItem];
        
        itemFrame.origin.y = frame.size.height;
        westItem = [[TTModeMenuItem alloc] initWithFrame:itemFrame direction:WEST];
        [self addSubview:westItem];

        itemFrame.origin.y = 0;
        southItem = [[TTModeMenuItem alloc] initWithFrame:itemFrame direction:SOUTH];
        [self addSubview:southItem];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
}

@end
