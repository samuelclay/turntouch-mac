//
//  TTChangeButtonCell.m
//  Turn Touch App
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTChangeButtonCell.h"

#define BORDER_RADIUS 5.0f

@implementation TTChangeButtonCell

@synthesize mouseDown;

- (id)init {
    if (self = [super init]) {
        mouseDown = NO;
    }
    
    return self;
}

- (NSInteger)highlightsBy {
    return NSContentsCellMask;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    NSRect borderRect = NSMakeRect(0.5f, 0.5f,
                                   NSWidth(frame) - 1,
                                   NSHeight(frame) - 1);
    // Create clip boundary
    NSBezierPath *clip = [NSBezierPath bezierPath];
    [clip appendBezierPathWithRoundedRect:borderRect
                                  xRadius:BORDER_RADIUS yRadius:BORDER_RADIUS];
    [clip addClip];
    
    // Add gradient background
    NSGradient *gradient;
    if (!mouseDown) {
        gradient = [[NSGradient alloc]
                    initWithStartingColor:[NSColor whiteColor]
                    endingColor:NSColorFromRGB(0xE7E7E7)];
    } else {
        gradient = [[NSGradient alloc]
                    initWithStartingColor:NSColorFromRGB(0xF7F7F7)
                    endingColor:NSColorFromRGB(0xE0E0E0)];
    }
    [gradient drawInRect:frame angle:90];
    
    // Add border
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line appendBezierPathWithRoundedRect:borderRect
                                  xRadius:BORDER_RADIUS yRadius:BORDER_RADIUS];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSSize textSize = [title size];
    [title drawAtPoint:NSMakePoint(frame.origin.x + frame.size.width/2 - textSize.width/2,
                                   frame.origin.y + frame.size.height/2 - textSize.height/2 + 1)];
    return frame;
}

@end