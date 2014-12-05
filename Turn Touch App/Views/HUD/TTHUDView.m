//
//  TTHUDView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTHUDView.h"

@implementation TTHUDView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    
    NSBezierPath *ellipse = [NSBezierPath bezierPathWithOvalInRect:screen.frame];
    NSGradient *borderGradient =
    [[NSGradient alloc]
      initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
      endingColor:[NSColor colorWithCalibratedWhite:0.82 alpha:1.0]];
    [borderGradient drawInBezierPath:ellipse angle:-90];
}

@end
