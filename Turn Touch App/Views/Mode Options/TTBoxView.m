//
//  TTBoxView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 5/14/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTBoxView.h"

@implementation TTBoxView

- (void)awakeFromNib {
    [self setBoxType:NSBoxCustom];
    [self setBorderType:NSNoBorder];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end
