//
//  TTDiamondView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamond.h"
#import "TTDiamondView.h"

@implementation TTDiamondView

@synthesize size = _size;
@synthesize isHighlighted = _isHighlighted;

- (id)initWithFrame:(NSRect)frame
{
    return [self initWithFrame:frame direction:0];
}

- (id)initWithFrame:(NSRect)frame direction:(TTModeDirection)direction {
    return [self initWithFrame:frame direction:direction ignoreSelectedDirection:NO];
}

- (id)initWithFrame:(NSRect)frame direction:(TTModeDirection)direction
ignoreSelectedDirection:(BOOL)ignoreSelectedDirection {
    self = [super initWithFrame:frame];
    if (self) {
        self.size = NSWidth(frame);
        self.isHighlighted = NO;
        ignoreSelectedMode = ignoreSelectedDirection;

        appDelegate = [NSApp delegate];
        
        if (direction) {
            overrideDirection = direction;
        }
        [self setDirections];
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
    [self setDirections];
    
    if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    }
}

- (void)setDirections {
    if (!overrideDirection || overrideDirection == appDelegate.diamond.selectedModeDirection) {
        activeModeDirection = appDelegate.diamond.activeModeDirection;
        if (!ignoreSelectedMode) {
            selectedModeDirection = appDelegate.diamond.selectedModeDirection;
        }
    } else {
        activeModeDirection = 0;
        if (!ignoreSelectedMode) {
            selectedModeDirection = overrideDirection;
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [self drawPaths:dirtyRect];
    [self colorPaths:dirtyRect];
}

- (void)drawPaths:(NSRect)rect {
    CGFloat width = NSMaxX(rect);
    CGFloat height = NSMaxY(rect);
    CGFloat spacing = SPACING_PCT * width;
    
    northPath = [NSBezierPath bezierPath];
    [northPath moveToPoint:NSMakePoint(width / 2,
                                       height)];
    [northPath lineToPoint:NSMakePoint(width * 1/4 + spacing,
                                       height * 3/4 + spacing)];
    [northPath lineToPoint:NSMakePoint(width / 2,
                                       height/2 + spacing*2)];
    [northPath lineToPoint:NSMakePoint(width * 3/4 - spacing,
                                       height * 3/4 + spacing)];
    [northPath closePath];
    
    eastPath = [NSBezierPath bezierPath];
    [eastPath moveToPoint:NSMakePoint(width * 3/4 + spacing,
                                      height * 3/4 - spacing)];
    [eastPath lineToPoint:NSMakePoint(width * 1/2 + spacing*2,
                                      height * 1/2)];
    [eastPath lineToPoint:NSMakePoint(width * 3/4 + spacing,
                                      height * 1/4 + spacing)];
    [eastPath lineToPoint:NSMakePoint(width,
                                      height * 1/2)];
    [eastPath closePath];

    westPath = [NSBezierPath bezierPath];
    [westPath moveToPoint:NSMakePoint(width * 1/4 - spacing,
                                      height * 3/4 - spacing)];
    [westPath lineToPoint:NSMakePoint(0,
                                      height * 1/2)];
    [westPath lineToPoint:NSMakePoint(width * 1/4 - spacing,
                                      height * 1/4 + spacing)];
    [westPath lineToPoint:NSMakePoint(width * 1/2 - spacing*2,
                                      height * 1/2)];
    [westPath closePath];
    
    southPath = [NSBezierPath bezierPath];
    [southPath moveToPoint:NSMakePoint(width * 1/2,
                                       height * 1/2 - spacing*2)];
    [southPath lineToPoint:NSMakePoint(width * 1/4 + spacing,
                                       height * 1/4 - spacing)];
    [southPath lineToPoint:NSMakePoint(width * 1/2,
                                       0)];
    [southPath lineToPoint:NSMakePoint(width * 3/4 - spacing,
                                       height * 1/4 - spacing)];
    [southPath closePath];
}

- (void)colorPaths:(NSRect)rect {
    CGFloat width = NSMaxX(rect);
    CGFloat height = NSMaxY(rect);
    CGFloat spacing = SPACING_PCT * width;
    
    for (NSBezierPath *path in @[northPath, eastPath, westPath, southPath]) {
        TTModeDirection direction = 0;
        if ([path isEqual:northPath]) {
            direction = NORTH;
        } else if ([path isEqual:eastPath]) {
            direction = EAST;
        } else if ([path isEqual:westPath]) {
            direction = WEST;
        } else if ([path isEqual:southPath]) {
            direction = SOUTH;
        }
        
        if (!self.isHighlighted && !ignoreSelectedMode) {
            [NSGraphicsContext saveGraphicsState];
            NSAffineTransform *transform = [NSAffineTransform transform];
            [transform translateXBy:0 yBy:-0.25f];
            NSBezierPath *shadowPath = [path copy];
            [shadowPath transformUsingAffineTransform:transform];
            [[NSColor colorWithDeviceWhite:1.0f alpha:0.4f] setStroke];
            if (path == northPath) {
                [[NSBezierPath bezierPathWithRect:NSMakeRect(width*1/4+spacing*2, height*3/4,
                                                             width*2/4-spacing*4, -1 * height*1/4)]
                 setClip];
            } else if (path == eastPath) {
                [[NSBezierPath bezierPathWithRect:NSMakeRect(width*1/2+spacing*2, height*1/2,
                                                             width*2/4-spacing*2, -1 * height*1/4)]
                 setClip];
            } else if (path == westPath) {
                [[NSBezierPath bezierPathWithRect:NSMakeRect(0, height*1/2,
                                                             width*2/4-spacing*2, -1 * height*1/4)]
                 setClip];
            } else if (path == southPath) {
                [[NSBezierPath bezierPathWithRect:NSMakeRect(width*1/4+spacing*2, 0,
                                                             width*2/4-spacing*4, height*1/4)]
                 setClip];
            }
            [shadowPath setLineWidth:0.25f];
            [shadowPath stroke];
            [NSGraphicsContext restoreGraphicsState];
        }
        
        NSColor *modeColor = [NSColor colorWithCalibratedHue:0.55f saturation:0.5f brightness:0.2f
                                                       alpha:activeModeDirection == direction ? 0.5f :
                              selectedModeDirection == direction ? 1.0f : INACTIVE_OPACITY];
        if (!ignoreSelectedMode) {
            if (self.isHighlighted) {
                [[NSColor colorWithDeviceWhite:1.0f
                                         alpha:activeModeDirection == direction ? 0.5f :
                  selectedModeDirection == direction ? 1.0f : INACTIVE_OPACITY]
                 setFill];
            } else {
                [modeColor setFill];
            }
            [path fill];
        } else {
            path.lineWidth = 1.0f;
            [modeColor setStroke];
            [path stroke];
        }
    }
}

- (void)setHighlighted:(BOOL)newFlag {
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

@end
