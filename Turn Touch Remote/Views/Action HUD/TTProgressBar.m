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
    NSRect rect = NSInsetRect([self bounds], 1.0, 2.0);

    if (_progress <= 40)
        [[NSColor redColor] set];
    else if (_progress <= 60)
        [[NSColor yellowColor] set];
    else
        [[NSColor greenColor] set];
    
    rect.size.width = floor(rect.size.width * (_progress / 100.0));
    [NSBezierPath fillRect:rect];
}
@end
