//
//  TTModeMenuViewport.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMenuViewport.h"
#import <QuartzCore/CoreAnimation.h>

#define MARGIN 0.0f
#define CORNER_RADIUS 8.0f

@implementation TTModeMenuViewport

@synthesize isExpanded;

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
        
        appDelegate.modeMenuViewport = self;
    }
    
    return self;
}

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self
                          forKeyPath:@"activeModeDirection"
                             options:0
                             context:nil];
    [appDelegate.modeMap addObserver:self
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

- (void)toggleExpanded {
    isExpanded = !isExpanded;
    
    [self resize:YES];
}

- (void)collapse {
    if (!isExpanded) return;
    isExpanded = NO;
    
    [self resize:YES];
}

- (void)expand {
    if (isExpanded) return;
    isExpanded = YES;
    
    [self resize:YES];
}

- (void)resize:(BOOL)animate {
    NSRect viewportRect = self.frame;

    CGFloat newHeight = originalHeight;
    if (isExpanded) {
        newHeight = originalHeight * 4;
    }
//    viewportRect.origin.y = 0;
    viewportRect.size.height = newHeight;

    if (animation) {
        [animation stopAnimation];
        animation = nil;
    }
    
    if (animate) {
        NSTimeInterval duration = 0.44f;
        NSEvent *currentEvent = [NSApp currentEvent];
        NSUInteger clearFlags = ([currentEvent modifierFlags] &
                                 NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        if (shiftPressed) {
            duration *= 10;
        }

        NSDictionary *growBackground = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self, NSViewAnimationTargetKey,
                                        [NSValue valueWithRect:self.frame], NSViewAnimationStartFrameKey,
                                        [NSValue valueWithRect:viewportRect], NSViewAnimationEndFrameKey, nil];
        animation = [[NSViewAnimation alloc]
                     initWithViewAnimations:@[growBackground]];
        [animation setAnimationBlockingMode: NSAnimationNonblocking];
        [animation setAnimationCurve: NSAnimationEaseInOut];
        [animation setDuration:duration];
        [animation startAnimation];

        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [context setDuration:0];
            [container.northItem.changeButton setHidden:NO];
            [container.eastItem.changeButton setHidden:NO];
            [container.westItem.changeButton setHidden:NO];
            [container.southItem.changeButton setHidden:NO];
            [[container.northItem.changeButton animator] setAlphaValue:isExpanded ? 0 : 1];
            [[container.eastItem.changeButton animator] setAlphaValue:isExpanded ? 0 : 1];
            [[container.westItem.changeButton animator] setAlphaValue:isExpanded ? 0 : 1];
            [[container.southItem.changeButton animator] setAlphaValue:isExpanded ? 0 : 1];
        } completionHandler:^{
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                [context setDuration:duration];
                [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [[container.northItem.changeButton animator] setAlphaValue:isExpanded ? 1 : 0];
                [[container.eastItem.changeButton animator] setAlphaValue:isExpanded ? 1 : 0];
                [[container.westItem.changeButton animator] setAlphaValue:isExpanded ? 1 : 0];
                [[container.southItem.changeButton animator] setAlphaValue:isExpanded ? 1 : 0];
            } completionHandler:^{
                [container.northItem.changeButton setHidden:!isExpanded];
                [container.eastItem.changeButton setHidden:!isExpanded];
                [container.westItem.changeButton setHidden:!isExpanded];
                [container.southItem.changeButton setHidden:!isExpanded];
            }];
        }];

    } else {
        NSRect newMenuRect = [self positionContainer:isExpanded];
        
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
    if (![appDelegate isMenuViewportExpanded]) {
        [container.northItem.changeButton setHidden:YES];
        [container.eastItem.changeButton setHidden:YES];
        [container.westItem.changeButton setHidden:YES];
        [container.southItem.changeButton setHidden:YES];
    }

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
    
    switch (appDelegate.modeMap.selectedModeDirection) {
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
