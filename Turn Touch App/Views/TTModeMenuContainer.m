//
//  TTModeMenuContainer.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMenuContainer.h"

@implementation TTModeMenuContainer

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    [[NSColor redColor] setFill];
    NSRectFill(dirtyRect);
}

@end
