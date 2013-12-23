//
//  TTModeMenuViewport.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMenuViewport.h"

#define MARGIN 0.0f
#define CORNER_RADIUS 8.0f

@implementation TTModeMenuViewport

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        NSRect containerFrame = frame;
        containerFrame.origin.y = 0;
        container = [[TTModeMenuContainer alloc] initWithFrame:containerFrame];
        isExpanded = NO;
        originalHeight = frame.size.height;
        originalY = frame.origin.y;
        
        [self addSubview:container];
        [self registerAsObserver];
    }
    
    return self;
}

- (void)registerAsObserver {
    [appDelegate.diamond addObserver:self
                          forKeyPath:@"activeModeDirection"
                             options:0
                             context:nil];
    [appDelegate.diamond addObserver:self
                          forKeyPath:@"selectedModeDirection"
                             options:0
                             context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    isExpanded = !isExpanded;

    [self resize:YES];
}

- (void)resize:(BOOL)animate {
    NSRect viewportRect = self.frame;

    CGFloat newHeight = originalHeight;
    if (isExpanded) {
        newHeight = originalHeight * 4;
    }
    viewportRect.size.height = newHeight;
    
//    NSLog(@"Resizing viewport: %f height", newHeight);
    NSDictionary *growBackground = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self, NSViewAnimationTargetKey,
                                    [NSValue valueWithRect:self.frame], NSViewAnimationStartFrameKey,
                                    [NSValue valueWithRect:viewportRect], NSViewAnimationEndFrameKey, nil];
    
    NSRect originalMenuRect = [self positionContainer:!isExpanded];
    NSRect newMenuRect = [self positionContainer:isExpanded];
    NSDictionary *moveMenu = [NSDictionary dictionaryWithObjectsAndKeys:
                              container, NSViewAnimationTargetKey,
                              [NSValue valueWithRect:originalMenuRect], NSViewAnimationStartFrameKey,
                              [NSValue valueWithRect:newMenuRect], NSViewAnimationEndFrameKey, nil];
    
    if (animate) {
        NSViewAnimation *animation = [[NSViewAnimation alloc]
                                      initWithViewAnimations:@[growBackground, moveMenu]];
        [animation setAnimationBlockingMode: NSAnimationNonblocking];
        [animation setAnimationCurve: NSAnimationEaseInOut];
        [animation setDuration:.35f];
        [animation startAnimation];
    } else {
        self.frame = viewportRect;
        container.frame = newMenuRect;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
    
    [self drawBackground];
    
    container.frame = [self positionContainer:isExpanded];
}

- (void)resetPosition {
    isExpanded = NO;
    [self resize:NO];
}

- (void)drawBackground {
    NSRect contentRect = NSInsetRect([self bounds], MARGIN, MARGIN);
    
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

- (NSRect)positionContainer:(BOOL)expanded {
    int itemPosition = 0;
    
    switch (appDelegate.diamond.selectedModeDirection) {
        case NORTH:
            itemPosition = originalHeight * 3;
            break;
        case EAST:
            itemPosition = originalHeight * 2;
            break;
        case WEST:
            itemPosition = originalHeight;
            break;
        case SOUTH:
            itemPosition = 0;
            break;
    }
    
    NSRect containerFrame = self.frame;
    CGFloat percentComplete;
    CGFloat y;
    if (expanded) {
        percentComplete = (NSHeight(self.frame) - originalHeight) / (originalHeight*3);
        y = itemPosition * (1 - percentComplete);
    } else {
        percentComplete = (originalHeight*4 - NSHeight(self.frame)) / (originalHeight*3);
        y = itemPosition * (percentComplete);
    }

    containerFrame.origin.y = -1 * y;
    containerFrame.size.height = originalHeight * 4;
    return containerFrame;
}

@end
