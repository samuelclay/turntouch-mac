//
//  TTPageIndicatorView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTPageIndicatorView.h"

@implementation TTPageIndicatorView

@synthesize modalFTUX;

- (instancetype)init {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self createTrackingArea];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSRect frame = self.bounds;
    frame = CGRectInset(frame, 2.0, 2.0);
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect: CGRectMake(frame.origin.x, frame.origin.y - 1.5, frame.size.width, frame.size.height)];
    [[NSColor whiteColor] set];
    [path fill];
    
    path = [NSBezierPath bezierPathWithOvalInRect: frame];
    NSColor *color = self.isSelected ? [NSColor colorWithCalibratedRed: (115.0 / 255.0) green: (115.0 / 255.0) blue: (115.0 / 255.0) alpha: 1.0] :
    [NSColor colorWithCalibratedRed: (217.0 / 255.0) green: (217.0 / 255.0) blue: (217.0 / 255.0) alpha: 1.0];
    
    if(self.isHighlighted)
        color = [NSColor colorWithCalibratedRed: (150.0 / 255.0) green: (150.0 / 255.0) blue: (150.0 / 255.0) alpha: 1.0];
    
    [color set];
    [path fill];
    
    frame = CGRectInset(frame, 0.5, 0.5);
    [[NSColor colorWithCalibratedRed: (25.0 / 255.0) green: (25.0 / 255.0) blue: (25.0 / 255.0) alpha: 0.15] set];
    [NSBezierPath setDefaultLineWidth: 1.0];
    [[NSBezierPath bezierPathWithOvalInRect: frame] stroke];
}

- (BOOL)isHighlighted {
    return highlighted && !self.isSelected;
}

- (BOOL)isSelected {
    return selected || appDelegate.panelController.backgroundView.modalFTUX == modalFTUX;
}


- (void)createTrackingArea {
    if (trackingArea) {
        [self removeTrackingArea:trackingArea];
        trackingArea = nil;
    }
    
    NSTrackingAreaOptions opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect);
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options:opts
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

#pragma mark - Actions

- (void)mouseEntered:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];
    highlighted = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];
    highlighted = NO;
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    highlighted = NO;
    selected = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    selected = NO;
    highlighted = NO;

    BOOL inside = NSPointInRect(clickPoint, self.bounds);
    if (!inside) {
        return;
    }
    [appDelegate.panelController.backgroundView switchPanelModalFTUX:modalFTUX];
    [self setNeedsDisplay:YES];
}

@end
