//
//  TTPanelArrowView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 5/1/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTPanelArrowView.h"

@implementation TTPanelArrowView

@synthesize arrowX;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect statusRect = [appDelegate.panelController statusRectForWindow:[self window]];
    NSRect panelRect = [[self window] frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);

    //    NSLog(@"Drawing background: %@", NSStringFromRect(dirtyRect));
    NSRect contentRect = NSInsetRect(self.frame, LINE_THICKNESS, LINE_THICKNESS);
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(panelX - ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path lineToPoint:NSMakePoint(panelX, NSMaxY(contentRect))];
    [path lineToPoint:NSMakePoint(panelX + ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path closePath];
    
    [[NSColor colorWithDeviceWhite:1 alpha:1.0] setFill];
    [path fill];
    
    [path setLineWidth:LINE_THICKNESS * 2];
    [[NSColor whiteColor] setStroke];
    [path stroke];
    
}

@end
