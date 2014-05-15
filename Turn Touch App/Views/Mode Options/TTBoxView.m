//
//  TTBoxView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 5/14/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTBoxView.h"

@implementation TTBoxView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)setFrame:(NSRect)frameRect {
    NSLog(@"Layout box view: %@ / %@", NSStringFromRect(self.frame), NSStringFromRect(self.bounds));
    // Extend frame out
//    frameRect.size.width += 18;
//    frameRect.origin.x += 3;
    
    // Extend content out
//    NSRect bounds = self.bounds;
//    bounds.size.width -= 8;
//    self.bounds = bounds;
    
    [super setFrame:frameRect];
}

@end
