//
//  TTDiamondView.m
//  Turn Touch Remote
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
@synthesize statusBar;
@synthesize connected;

#pragma mark - Initialization


- (id)initWithFrame:(NSRect)frame {
    return [self initWithFrame:frame interactive:NO];
}

- (id)initWithFrame:(NSRect)frame interactive:(BOOL)_interactive {
    return [self initWithFrame:frame interactive:_interactive statusBar:NO];
}

- (id)initWithFrame:(NSRect)frame interactive:(BOOL)_interactive statusBar:(BOOL)_statusBar {
    self = [super initWithFrame:frame];
    if (self) {
        self.size = NSWidth(frame);
        self.isHighlighted = NO;
        self.showOutline = NO;
        self.interactive = _interactive;
        self.statusBar = _statusBar;
        self.overrideSelectedDirection = NO_DIRECTION;
        self.overrideActiveDirection = NO_DIRECTION;
        self.ignoreSelectedMode = NO;
        self.ignoreActiveMode = NO;
        
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        
        [self registerAsObserver];
        [self createTrackingArea];
    }
    
    return self;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    self.size = NSWidth(self.frame);
//    NSLog(@"Diamond size: %f", self.size);
}

#pragma mark - KVO

- (void)dealloc {
    if (interactive) {
        [appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
        [appDelegate.modeMap removeObserver:self forKeyPath:@"hoverModeDirection"];
    }
    if (statusBar) {
        [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"connectedDevices"];
    }
    [appDelegate.modeMap removeObserver:self forKeyPath:@"activeModeDirection"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"selectedModeDirection"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"selectedMode"];
}

- (void)registerAsObserver {
    if (interactive) {
        [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                                 options:0 context:nil];
        [appDelegate.modeMap addObserver:self forKeyPath:@"hoverModeDirection"
                                 options:0 context:nil];
    }
    if (statusBar) {
        [appDelegate.bluetoothMonitor addObserver:self forKeyPath:@"connectedDevicesCount"
                                          options:0 context:nil];
    }
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
    NSLog(@"Change key: %@", keyPath);
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(hoverModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(activeModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(selectedMode))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(connectedDevicesCount))]) {
        [self setNeedsDisplay:YES];
    }
}
         
- (BOOL)isDeviceConnected {
    return appDelegate.bluetoothMonitor.connectedDevices.count > 0;
}
         
#pragma mark - Drawing

- (BOOL)wantsDefaultClipping {
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    NSRect rect = self.bounds;
    [self drawPaths:rect];
    [self colorPaths:rect];
}

- (void)drawPaths:(NSRect)rect {
//    NSLog(@"Draw diamond: %@ - %@", NSStringFromRect(rect), NSStringFromRect(self.bounds));
    CGFloat width = NSMaxX(rect);
    CGFloat height = NSMaxY(rect);
    CGFloat spacing = SPACING_PCT * width;
    
    northPathTop = [NSBezierPath bezierPath];
    northPathBottom = [NSBezierPath bezierPath];
    [northPathTop setLineJoinStyle:NSMiterLineJoinStyle];
    [northPathBottom setLineJoinStyle:NSMiterLineJoinStyle];
    [northPathTop moveToPoint:NSMakePoint(width * 1/4 + 1.3*spacing,
                                          height * 3/4 + spacing)];
    [northPathTop lineToPoint:NSMakePoint(width / 2,
                                          height)];
    [northPathTop lineToPoint:NSMakePoint(width * 3/4 - 1.3*spacing,
                                          height * 3/4 + spacing)];
    [northPathBottom moveToPoint:NSMakePoint(width * 3/4 - 1.3*spacing,
                                             height * 3/4 + spacing)];
    [northPathBottom lineToPoint:NSMakePoint(width / 2,
                                             height/2 + spacing*2)];
    [northPathBottom lineToPoint:NSMakePoint(width * 1/4 + 1.3*spacing,
                                             height * 3/4 + spacing)];
    
    eastPathTop = [NSBezierPath bezierPath];
    eastPathBottom = [NSBezierPath bezierPath];
    [eastPathTop setLineJoinStyle:NSMiterLineJoinStyle];
    [eastPathBottom setLineJoinStyle:NSMiterLineJoinStyle];
    [eastPathTop moveToPoint:NSMakePoint(width * 1/2 + 1.3*spacing*2,
                                         height * 1/2)];
    [eastPathTop lineToPoint:NSMakePoint(width * 3/4 + 1.3*spacing,
                                         height * 3/4 - spacing)];
    [eastPathTop lineToPoint:NSMakePoint(width,
                                         height * 1/2)];
    [eastPathBottom moveToPoint:NSMakePoint(width,
                                            height * 1/2)];
    [eastPathBottom lineToPoint:NSMakePoint(width * 3/4 + 1.3*spacing,
                                            height * 1/4 + spacing)];
    [eastPathBottom lineToPoint:NSMakePoint(width * 1/2 + 1.3*spacing*2,
                                            height * 1/2)];

    westPathTop = [NSBezierPath bezierPath];
    westPathBottom = [NSBezierPath bezierPath];
    [westPathTop setLineJoinStyle:NSMiterLineJoinStyle];
    [westPathBottom setLineJoinStyle:NSMiterLineJoinStyle];
    [westPathTop moveToPoint:NSMakePoint(width * 1/2 - 1.3*spacing*2,
                                         height * 1/2)];
    [westPathTop lineToPoint:NSMakePoint(width * 1/4 - 1.3*spacing,
                                         height * 3/4 - spacing)];
    [westPathTop lineToPoint:NSMakePoint(0,
                                         height * 1/2)];
    [westPathBottom moveToPoint:NSMakePoint(0,
                                            height * 1/2)];
    [westPathBottom lineToPoint:NSMakePoint(width * 1/4 - 1.3*spacing,
                                            height * 1/4 + spacing)];
    [westPathBottom lineToPoint:NSMakePoint(width * 1/2 - 1.3*spacing*2,
                                            height * 1/2)];
    
    southPathTop = [NSBezierPath bezierPath];
    southPathBottom = [NSBezierPath bezierPath];
    [southPathTop setLineJoinStyle:NSMiterLineJoinStyle];
    [southPathBottom setLineJoinStyle:NSMiterLineJoinStyle];
    [southPathTop moveToPoint:NSMakePoint(width * 3/4 - 1.3*spacing,
                                          height * 1/4 - spacing)];
    [southPathTop lineToPoint:NSMakePoint(width * 1/2,
                                          height * 1/2 - spacing*2)];
    [southPathTop lineToPoint:NSMakePoint(width * 1/4 + 1.3*spacing,
                                          height * 1/4 - spacing)];
    [southPathBottom moveToPoint:NSMakePoint(width * 1/4 + 1.3*spacing,
                                             height * 1/4 - spacing)];
    [southPathBottom lineToPoint:NSMakePoint(width * 1/2,
                                             0)];
    [southPathBottom lineToPoint:NSMakePoint(width * 3/4 - 1.3*spacing,
                                             height * 1/4 - spacing)];
}

- (void)colorPaths:(NSRect)rect {
    TTModeDirection activeModeDirection = ignoreActiveMode ? overrideActiveDirection : appDelegate.modeMap.activeModeDirection;
    TTModeDirection selectedModeDirection = ignoreSelectedMode ? overrideSelectedDirection : appDelegate.modeMap.selectedModeDirection;
    TTModeDirection inspectingModeDirection = appDelegate.modeMap.inspectingModeDirection;
    TTModeDirection hoverModeDirection = appDelegate.modeMap.hoverModeDirection;

    for (NSBezierPath *path in @[northPathTop, northPathBottom,
                                 eastPathTop, eastPathBottom,
                                 westPathTop, westPathBottom,
                                 southPathTop, southPathBottom]) {
        TTModeDirection direction = NO_DIRECTION;
        BOOL bottomHalf = [@[northPathBottom, eastPathBottom, westPathBottom, southPathBottom] containsObject:path];
        if ([path isEqual:northPathTop] || [path isEqual:northPathBottom]) {
            direction = NORTH;
        } else if ([path isEqual:eastPathTop] || [path isEqual:eastPathBottom]) {
            direction = EAST;
        } else if ([path isEqual:westPathTop] || [path isEqual:westPathBottom]) {
            direction = WEST;
        } else if ([path isEqual:southPathTop] || [path isEqual:southPathBottom]) {
            direction = SOUTH;
        }

        BOOL isHoveringDirection    = hoverModeDirection == direction;
        BOOL isInspectingDirection  = inspectingModeDirection == direction;
        BOOL isSelectedDirection    = selectedModeDirection == direction;
        BOOL isActiveDirection      = activeModeDirection == direction;
        
        // Fill in the color as a stroke or fill
        NSColor *modeColor;
        if (interactive) {
            if (isActiveDirection) {
                modeColor = NSColorFromRGB(0x505AC0);
            } else if (isHoveringDirection && !isInspectingDirection) {
                modeColor = NSColorFromRGB(0x505AC0);
            } else if (isInspectingDirection) {
                modeColor = NSColorFromRGB(0x303AA0);
            } else {
                modeColor = NSColorFromRGB(0xD3D7D9);
                if (bottomHalf) {
                    modeColor = NSColorFromRGB(0xA3A7A9);
                }
            }
        } else if (statusBar) {
            if (self.isHighlighted) {
                if (isActiveDirection) {
                    CGFloat alpha = isSelectedDirection ? 0.8 : 1.0;
                    modeColor = NSColorFromRGBAlpha(0xFFFFFF, alpha);
                } else if (isSelectedDirection) {
                    CGFloat alpha = isActiveDirection ? 0.8 : isSelectedDirection ? 1.0 : 0.4;
                    modeColor = NSColorFromRGBAlpha(0xFFFFFF, alpha);
                } else {
                    CGFloat alpha = 0.5f;
                    modeColor = NSColorFromRGBAlpha(0xFFFFFF, alpha);
                }
            } else if (![self isDeviceConnected]) {
                if (isActiveDirection) {
                    CGFloat alpha = isSelectedDirection ? 0.8 : 1.0;
                    modeColor = NSColorFromRGBAlpha(0xA0A0A0, alpha);
                } else if (isSelectedDirection) {
                    CGFloat alpha = isActiveDirection ? 0.8 : isSelectedDirection ? 1.0 : 0.4;
                    modeColor = NSColorFromRGBAlpha(0xA0A0A0, alpha);
                } else {
                    CGFloat alpha = 0.5f;
                    modeColor = NSColorFromRGBAlpha(0xA0A0A0, alpha);
                }
            } else {
                if (isActiveDirection) {
                    CGFloat alpha = 0.8f;
                    modeColor = NSColorFromRGBAlpha(0x303033, alpha);
                } else if (isSelectedDirection) {
                    modeColor = NSColorFromRGB(0x1555D8);
                } else {
                    CGFloat alpha = 0.5f;
                    modeColor = NSColorFromRGBAlpha(0x515559, alpha);
                }
            }
        } else {
            if (isActiveDirection) {
                CGFloat alpha = 0.5f;
                modeColor = NSColorFromRGBAlpha(0x303033, alpha);
            } else if (isSelectedDirection) {
                if (appDelegate.modeMap.selectedModeDirection == direction) {
                    CGFloat alpha = 0.8f;
                    modeColor = NSColorFromRGBAlpha(0x1555D8, alpha);
                } else {
                    CGFloat alpha = 0.7f;
                    modeColor = NSColorFromRGBAlpha(0x303033, alpha);
                }
            } else {
                CGFloat alpha = 0.2f;
                modeColor = NSColorFromRGBAlpha(0x606063, alpha);
            }
        }
        
        if (path == northPathTop) [path appendBezierPath:northPathBottom];
        if (path == eastPathTop) [path appendBezierPath:eastPathBottom];
        if (path == westPathTop) [path appendBezierPath:westPathBottom];
        if (path == southPathTop) [path appendBezierPath:southPathBottom];

        if (!showOutline) {
            [modeColor setFill];
            if (!bottomHalf) {
                [path fill];
            }
        } else {
            path.lineWidth = isInspectingDirection ? 3.0f : 1.0f;
            [modeColor setStroke];
            [path stroke];
        }
        
        if (interactive) {
            if (isInspectingDirection || isHoveringDirection) {
                [NSColorFromRGB(0xFFFFFF) set];
            } else {
                [NSColorFromRGB(0xFAFBFD) set];
            }
            if (!bottomHalf) {
                [path fill];
            }
        }
    }
}

- (void)setHighlighted:(BOOL)newFlag {
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark - Events

- (void)updateTrackingAreas {
    [self createTrackingArea];
}

- (void)createTrackingArea {
    if (!interactive) return;
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways |
                NSTrackingMouseMoved | NSTrackingActiveInKeyWindow);
    NSTrackingArea *trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options:opts
                                                                   owner:self
                                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (!interactive) {
        [super mouseUp:theEvent];
        return;
    }
    
    NSPoint location = [theEvent locationInWindow];
    NSPoint center = [self convertPoint:location fromView:nil];
    
    if ([northPathTop containsPoint:center] || [northPathBottom containsPoint:center]) {
        [appDelegate.modeMap toggleInspectingModeDirection:NORTH];
    } else if ([eastPathTop containsPoint:center] || [eastPathBottom containsPoint:center]) {
        [appDelegate.modeMap toggleInspectingModeDirection:EAST];
    } else if ([westPathTop containsPoint:center] || [westPathBottom containsPoint:center]) {
        [appDelegate.modeMap toggleInspectingModeDirection:WEST];
    } else if ([southPathTop containsPoint:center] || [southPathBottom containsPoint:center]) {
        [appDelegate.modeMap toggleInspectingModeDirection:SOUTH];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent {
    if (!interactive) {
        [super mouseMoved:theEvent];
        return;
    }
    
    [self mouseMovement:theEvent hovering:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [appDelegate.modeMap toggleHoverModeDirection:NO_DIRECTION hovering:NO];
}

- (void)mouseMovement:(NSEvent *)theEvent hovering:(BOOL)hovering {
    NSPoint location = [theEvent locationInWindow];
    NSPoint center = [self convertPoint:location fromView:nil];
//    NSLog(@"Movement: %@ in %@", NSStringFromPoint(center), NSStringFromRect(self.bounds));
    if ([northPathTop containsPoint:center] || [northPathBottom containsPoint:center]) {
        [appDelegate.modeMap toggleHoverModeDirection:NORTH hovering:hovering];
    } else if ([eastPathTop containsPoint:center] || [eastPathBottom containsPoint:center]) {
        [appDelegate.modeMap toggleHoverModeDirection:EAST hovering:hovering];
    } else if ([westPathTop containsPoint:center] || [westPathBottom containsPoint:center]) {
        [appDelegate.modeMap toggleHoverModeDirection:WEST hovering:hovering];
    } else if ([southPathTop containsPoint:center] || [southPathBottom containsPoint:center]) {
        [appDelegate.modeMap toggleHoverModeDirection:SOUTH hovering:hovering];
    } else if (appDelegate.modeMap.hoverModeDirection != NO_DIRECTION) {
        [appDelegate.modeMap toggleHoverModeDirection:NO_DIRECTION hovering:NO];
    }
}

@end
