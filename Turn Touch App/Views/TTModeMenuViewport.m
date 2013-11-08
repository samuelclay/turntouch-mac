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
        container = [[TTModeMenuContainer alloc] initWithFrame:frame];
        isExpanded = NO;
        originalHeight = frame.size.height;
        
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
    NSRect frame = self.frame;
    
    CGFloat newHeight = originalHeight;
    if (!isExpanded) {
        newHeight = originalHeight * 4;
    }
    frame.size.height = newHeight;

    NSDictionary *growBackground = [NSDictionary dictionaryWithObjectsAndKeys: self, NSViewAnimationTargetKey,
                                    [NSValue valueWithRect:self.frame], NSViewAnimationStartFrameKey,
                                    [NSValue valueWithRect:frame], NSViewAnimationEndFrameKey, nil];
    NSRect originalMenuRect = [self positionContainer:isExpanded];
    NSRect newMenuRect = [self positionContainer:!isExpanded];
    NSDictionary *moveMenu = [NSDictionary dictionaryWithObjectsAndKeys: container, NSViewAnimationTargetKey,
                              [NSValue valueWithRect:originalMenuRect], NSViewAnimationStartFrameKey,
                              [NSValue valueWithRect:newMenuRect], NSViewAnimationEndFrameKey, nil];
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:@[growBackground, moveMenu]];
    [animation setAnimationBlockingMode: NSAnimationNonblocking];
    [animation setAnimationCurve: NSAnimationEaseInOut];
    [animation setDuration: .35f];
    [animation startAnimation];
    
    isExpanded = !isExpanded;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
    
    [self drawBackground];
    
    container.frame = [self positionContainer:isExpanded];
}

- (void)drawBackground {
    NSRect contentRect = NSInsetRect([self bounds], MARGIN, MARGIN);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)];
    
    NSPoint topLeftCorner = NSMakePoint(NSMinX(contentRect), NSMinY(contentRect));
    [path curveToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMinY(contentRect))
         controlPoint1:topLeftCorner controlPoint2:topLeftCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMinY(contentRect))];
    
    NSPoint topRightCorner = NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)
         controlPoint1:topRightCorner controlPoint2:topRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect))];
    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect))];
    
    [path closePath];
    
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:[NSColor whiteColor]
                             endingColor:NSColorFromRGB(0xE7E7E7)];
    [aGradient drawInBezierPath:path angle:90];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
    [clip appendBezierPath:path];
    [clip addClip];
    
    [NSGraphicsContext restoreGraphicsState];
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX([path bounds]), NSMaxY([path bounds]))];
    [line lineToPoint:NSMakePoint(NSMaxX([path bounds]), NSMaxY([path bounds]))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
}

- (NSRect)positionContainer:(BOOL)expanded {
    int itemPosition = 0;
    
    switch (appDelegate.diamond.selectedModeDirection) {
        case NORTH:
            itemPosition = 0;
            break;
        case EAST:
            itemPosition = originalHeight;
            break;
        case WEST:
            itemPosition = originalHeight * 2;
            break;
        case SOUTH:
            itemPosition = originalHeight * 3;
            break;
    }
    
    NSRect containerFrame = self.frame;
    CGFloat percentComplete;
    CGFloat y;
    if (expanded) {
        percentComplete = (NSHeight(self.frame) - originalHeight) / (originalHeight*3);
        y = -1 * itemPosition * (1 - percentComplete);
    } else {
        percentComplete = (originalHeight*4 - NSHeight(self.frame)) / (originalHeight*3);
        y = -1 * itemPosition * (percentComplete);
    }

    containerFrame.origin.y = y;
    containerFrame.size.height = originalHeight * 4;
    return containerFrame;
}

- (BOOL)isFlipped {
    return YES;
}

@end
