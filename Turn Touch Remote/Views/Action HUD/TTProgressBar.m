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
    [NSGraphicsContext saveGraphicsState];
    NSBezierPath *clipPath = [NSBezierPath bezierPath];
    [clipPath appendBezierPathWithRoundedRect:self.bounds
                                      xRadius:NSHeight(self.bounds)/2
                                      yRadius:NSHeight(self.bounds)/2];
    [clipPath addClip];
    
    CGFloat alpha = 0.6f;
    [NSColorFromRGBAlpha(0x57585F, alpha) setFill];
    NSRectFill(self.bounds);
    [NSGraphicsContext restoreGraphicsState];
    
    
    [NSGraphicsContext saveGraphicsState];
    NSBezierPath *innerClipPath = [NSBezierPath bezierPath];
    [innerClipPath appendBezierPathWithRoundedRect:NSInsetRect(self.bounds, 0.5f, 0.5f)
                                           xRadius:NSHeight(self.bounds)/2
                                           yRadius:NSHeight(self.bounds)/2];
    [innerClipPath addClip];
    
    // Progress bar itself
    NSRect rect = NSInsetRect([self bounds], 0.5, 0.5);
    [NSColorFromRGB(0xFFFFFF) set];
    rect.size.width = floor(rect.size.width * (_progress / 100.0));
    [NSBezierPath fillRect:rect];

    // Bars separating progress bar cells
    [NSColorFromRGBAlpha(0x606060, alpha) setFill];
    NSInteger slots = 12;
    for (int i=1; i < slots; i++) {
        NSRect bar = NSMakeRect(i*NSWidth(self.bounds)/slots - 0.5, 0, 0.5, NSHeight(self.bounds));
        NSRectFill(bar);
    }
    [NSGraphicsContext restoreGraphicsState];
}

@end
