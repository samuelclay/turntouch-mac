//
//  TTProgressBar.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 10/24/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTProgressBar.h"

@implementation TTProgressBar

@synthesize progress = _progress;

- (void)setProgress:(double)progress {
    if (_progress != progress) {
        _progress = progress;
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    // Background of progress bar
    CGFloat alpha = 0.6f;
    [NSColorFromRGBAlpha(0x606060, alpha) setFill];
    NSRectFill(self.bounds);
    
    
    // Progress bar itself
    NSRect rect = NSInsetRect([self bounds], 0.5, 0.5);
    [NSColorFromRGB(0xFFFFFF) set];
//    if (_progress <= 40)
//        [[NSColor redColor] set];
//    else if (_progress <= 60)
//        [[NSColor yellowColor] set];
//    else
//        [[NSColor greenColor] set];
    
    rect.size.width = floor(rect.size.width * (_progress / 100.0));
    [NSBezierPath fillRect:rect];

    // Bars separating progress bar cells
    [NSColorFromRGBAlpha(0x606060, alpha) setFill];
    NSInteger slots = 16;
    
    for (int i=1; i < slots; i++) {
        NSRect bar = NSMakeRect(i*NSWidth(self.bounds)/slots - 0.25, 0, 0.5, NSHeight(self.bounds));
        NSRectFill(bar);
    }
}

@end
