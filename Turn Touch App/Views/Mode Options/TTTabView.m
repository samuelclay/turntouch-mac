//
//  TTTabView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 5/14/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTTabView.h"

@implementation TTTabView

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
    
    // Drawing code here.
}

- (void)setFrame:(NSRect)frameRect {
    NSLog(@"Layout tab view: %@", NSStringFromRect(self.frame));
    frameRect.origin.x -= 8;
    frameRect.size.width += 16;
    [super setFrame:frameRect];
}

@end
