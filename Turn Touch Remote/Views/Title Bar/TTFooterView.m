//
//  TTFooter.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/17/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTFooterView.h"

#define MARGIN 0.0f
#define CORNER_RADIUS 8.0f

@implementation TTFooterView

@synthesize backgroundColor;

- (instancetype)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        backgroundColor = NSColorFromRGB(0xFFFFFF);
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [self drawBackground];
}

- (void)drawBackground {
    NSRect contentRect = NSInsetRect([self bounds], MARGIN, MARGIN);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)];
    
    NSPoint bottomLeftCorner = NSMakePoint(NSMinX(contentRect), NSMinY(contentRect));
    [path curveToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMinY(contentRect))
         controlPoint1:bottomLeftCorner controlPoint2:bottomLeftCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMinY(contentRect))];
    
    NSPoint bottomRightCorner = NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)
         controlPoint1:bottomRightCorner controlPoint2:bottomRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect))];
    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect))];
    
    [path closePath];
    
    [backgroundColor setFill];
    [path fill];
    
//    NSGradient* aGradient = [[NSGradient alloc]
//                             initWithStartingColor:backgroundColor
//                             endingColor:backgroundColor];
//    [aGradient drawInBezierPath:path angle:-90];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
    [clip appendBezierPath:path];
    [clip addClip];
    
    [NSGraphicsContext restoreGraphicsState];
    
    //    NSBezierPath *line = [NSBezierPath bezierPath];
    //    [line moveToPoint:NSMakePoint(NSMinX([path bounds]), NSMaxY([path bounds]))];
    //    [line lineToPoint:NSMakePoint(NSMaxX([path bounds]), NSMaxY([path bounds]))];
    //    [line setLineWidth:1.0];
    //    [NSColorFromRGB(0xC2CBCE) set];
    //    [line stroke];
}

@end
