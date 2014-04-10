//
//  TTDiamondView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMap.h"
#import "TTDiamondView.h"

@implementation TTDiamondView

@synthesize size = _size;
@synthesize isHighlighted = _isHighlighted;
@synthesize overrideSelectedDirection;
@synthesize overrideActiveDirection;
@synthesize ignoreSelectedMode;
@synthesize ignoreActiveMode;
@synthesize showOutline;
@synthesize interactive;

#pragma mark - Initialization

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.size = NSWidth(frame);
        self.isHighlighted = NO;
        self.showOutline = NO;
        self.interactive = NO;
        self.overrideSelectedDirection = NO_DIRECTION;
        self.overrideActiveDirection = NO_DIRECTION;
        self.ignoreSelectedMode = NO;
        self.ignoreActiveMode = NO;
        
        appDelegate = [NSApp delegate];
        
        [self registerAsObserver];
    }
    
    return self;
}

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (BOOL)wantsDefaultClipping {
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = self.bounds;

    [self drawPaths:rect];
    [self colorPaths:rect];
}

- (void)drawPaths:(NSRect)rect {
//    NSLog(@"DrawPaths: %@ - %@", NSStringFromRect(rect), NSStringFromRect(self.bounds));
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
    TTModeDirection activeModeDirection = ignoreActiveMode ? overrideActiveDirection : appDelegate.modeMap.activeModeDirection;
    TTModeDirection selectedModeDirection = ignoreSelectedMode ? overrideSelectedDirection : appDelegate.modeMap.selectedModeDirection;
    
    for (NSBezierPath *path in @[northPath, eastPath, westPath, southPath]) {
        TTModeDirection direction = NO_DIRECTION;
        if ([path isEqual:northPath]) {
            direction = NORTH;
        } else if ([path isEqual:eastPath]) {
            direction = EAST;
        } else if ([path isEqual:westPath]) {
            direction = WEST;
        } else if ([path isEqual:southPath]) {
            direction = SOUTH;
        }
        
        if (!showOutline) {
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
        
        NSColor *modeColor;
        if (selectedModeDirection == direction &&
            appDelegate.modeMap.selectedModeDirection == direction) {
            modeColor = NSColorFromRGB(0x4585BE);
        } else {
            modeColor = [NSColor colorWithCalibratedHue:0.55f saturation:0.5f brightness:0.2f
                                                  alpha:activeModeDirection == direction ? 0.5f :
                         selectedModeDirection == direction ? 0.7f : INACTIVE_OPACITY];
        }
        if (!interactive) {
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
            TTModeDirection inspectingDirection = appDelegate.modeMap.inspectingModeDirection;
            path.lineWidth = inspectingDirection == direction ? 3.0f : 1.0f;
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

#pragma mark - Events

- (void)mouseUp:(NSEvent *)theEvent {
    if (!interactive) {
        [super mouseUp:theEvent];
        return;
    }
    
    NSPoint location = [theEvent locationInWindow];
    NSPoint center = [self convertPoint:location fromView:nil];
    
    if ([northPath containsPoint:center]) {
        [appDelegate.modeMap toggleInspectingModeDirection:NORTH];
    } else if ([eastPath containsPoint:center]) {
        [appDelegate.modeMap toggleInspectingModeDirection:EAST];
    } else if ([westPath containsPoint:center]) {
        [appDelegate.modeMap toggleInspectingModeDirection:WEST];
    } else if ([southPath containsPoint:center]) {
        [appDelegate.modeMap toggleInspectingModeDirection:SOUTH];
    }
}

@end
