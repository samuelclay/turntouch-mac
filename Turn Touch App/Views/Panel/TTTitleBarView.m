//
//  TTTitleBarView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 4/9/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTTitleBarView.h"

#define CORNER_RADIUS 8.0f

@implementation TTTitleBarView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        title = [NSImage imageNamed:@"Turn Touch title.png"];
        [title setSize:NSMakeSize(100, 11)];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self drawBackground];
    [self drawLabel];
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [self drawBackground];
    [self drawLabel];
}

- (void)drawLabel {
    NSPoint titlePoint = NSMakePoint(NSMidX(self.bounds)-(title.size.width/2),
                                     NSMidY(self.bounds)-(title.size.height/2));
    [title drawInRect:NSMakeRect(titlePoint.x, titlePoint.y,
                                 title.size.width, title.size.height)];
}



- (void)drawBackground {
    NSRect contentRect = NSInsetRect([self bounds], 0, 0);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect) - CORNER_RADIUS)];
    
    NSPoint topLeftCorner = NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect));
    [path curveToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMaxY(contentRect))
         controlPoint1:topLeftCorner controlPoint2:topLeftCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMaxY(contentRect))];
    
    NSPoint topRightCorner = NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect) - CORNER_RADIUS)
         controlPoint1:topRightCorner controlPoint2:topRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect))];
    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect))];
    
    [path closePath];
    
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:[NSColor whiteColor]
                             endingColor:NSColorFromRGB(0xE7E7E7)];
    [aGradient drawInBezierPath:path angle:-90];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
    [clip appendBezierPath:path];
    [clip addClip];
    
    [NSGraphicsContext restoreGraphicsState];
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX([path bounds]), NSMinY([path bounds]))];
    [line lineToPoint:NSMakePoint(NSMaxX([path bounds]), NSMinY([path bounds]))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
}

@end
