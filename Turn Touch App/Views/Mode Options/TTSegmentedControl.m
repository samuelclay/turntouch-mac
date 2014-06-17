//
//  TTSegmentedControl.m
//  Turn Touch App
//
//  Created by Samuel Clay on 6/17/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTSegmentedControl.h"
#import "TTSegmentedCell.h"

@implementation TTSegmentedControl

- (id)init {
    if (self = [super init]) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setCell:[[TTSegmentedCell alloc] init]];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
