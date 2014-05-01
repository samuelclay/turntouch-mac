//
//  TTModeMenuContainer.m
//  Turn Touch App
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeMenuContainer.h"
#import "TTBackgroundView.h"
#import "TTModeMenuItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation TTModeMenuContainer

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
//        self.autoresizingMask = NSViewMaxXMargin | NSViewMaxYMargin | NSViewHeightSizable;
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [self drawBorder];
    
}

- (void)drawBorder {
    // Top border
    BOOL open = appDelegate.modeMap.openedModeChangeMenu;
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX(self.bounds) + (open ? 0 : 12), NSMaxY(self.bounds))];
    [line lineToPoint:NSMakePoint(NSMaxX(self.bounds) - (open ? 0 : 12), NSMaxY(self.bounds))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
    
    // Bottom border
    if (open) {
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(NSMinX(self.bounds) + 12, NSMinY(self.bounds))];
        [line lineToPoint:NSMakePoint(NSMaxX(self.bounds) - 12, NSMinY(self.bounds))];
        [line setLineWidth:1.0];
        [NSColorFromRGB(0xD0D0D0) set];
        [line stroke];
    }
}

- (void)setContent:(NSArray *)content {
    NSRect frame = self.frame;
    frame.size.height = ceil([content count] / 2) * MENU_ITEM_HEIGHT;
    self.frame = frame;
}

@end
