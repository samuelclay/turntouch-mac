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

@synthesize diamondType;
@synthesize size = _size;
@synthesize isHighlighted = _isHighlighted;
@synthesize overrideSelectedDirection;
@synthesize overrideActiveDirection;
@synthesize ignoreSelectedMode;
@synthesize ignoreActiveMode;
@synthesize showOutline;
@synthesize connected;

#pragma mark - Initialization


- (id)initWithFrame:(NSRect)frame {
    return [self initWithFrame:frame diamondType:DIAMOND_TYPE_MODE];
}

- (id)initWithFrame:(NSRect)frame diamondType:(TTDiamondType)_diamondType {
    diamondType = _diamondType;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.size = NSWidth(frame);
        self.isHighlighted = NO;
        self.showOutline = NO;
        self.overrideSelectedDirection = NO_DIRECTION;
        self.overrideActiveDirection = NO_DIRECTION;
        self.ignoreSelectedMode = NO;
        self.ignoreActiveMode = NO;
        
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        
        [self registerAsObserver];

        if (diamondType == DIAMOND_TYPE_INTERACTIVE) {
            [self createTrackingArea];
        } else if (diamondType == DIAMOND_TYPE_HUD) {
            self.wantsLayer = YES;
        }
    }
    
    return self;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    self.size = NSWidth(frameRect);
//    NSLog(@"Diamond size: %f", self.size);
}

#pragma mark - KVO

- (void)dealloc {
    if (diamondType == DIAMOND_TYPE_INTERACTIVE) {
        [appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
        [appDelegate.modeMap removeObserver:self forKeyPath:@"hoverModeDirection"];
    }
    if (diamondType == DIAMOND_TYPE_PAIRING || diamondType == DIAMOND_TYPE_STATUSBAR) {
        [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"pairedDevicesCount"];
        [appDelegate.bluetoothMonitor.buttonTimer removeObserver:self forKeyPath:@"pairingActivatedCount"];
    }
    [appDelegate.modeMap removeObserver:self forKeyPath:@"activeModeDirection"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"selectedModeDirection"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"selectedMode"];
}

- (void)registerAsObserver {
    if (diamondType == DIAMOND_TYPE_INTERACTIVE) {
        [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                                 options:0 context:nil];
        [appDelegate.modeMap addObserver:self forKeyPath:@"hoverModeDirection"
                                 options:0 context:nil];
    }
    if (diamondType == DIAMOND_TYPE_PAIRING || diamondType == DIAMOND_TYPE_STATUSBAR) {
        [appDelegate.bluetoothMonitor addObserver:self forKeyPath:@"pairedDevicesCount"
                                          options:0 context:nil];
        [appDelegate.bluetoothMonitor.buttonTimer addObserver:self forKeyPath:@"pairingActivatedCount"
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
    // NSLog(@" ---> observe change: %@ / %d", keyPath, appDelegate.modeMap.activeModeDirection);
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
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(pairedDevicesCount))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(pairingActivatedCount))]) {
        [self setNeedsDisplay:YES];
    }
}
         
- (BOOL)isDeviceConnected {
    return appDelegate.bluetoothMonitor.pairedDevicesCount.integerValue > 0;
}
         
#pragma mark - Drawing

- (BOOL)wantsDefaultClipping {
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
//    NSLog(@"Diamond draw rect: %@", NSStringFromRect(dirtyRect));
    [super drawRect:dirtyRect];

    NSRect rect = self.bounds;
    [self drawPaths:rect];
    if (diamondType != DIAMOND_TYPE_HUD) {
        [self colorPaths:rect];
    }
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
    // TODO: This entire view needs to be split into a mode diamond and action diamond, since only
    //       the action diamond is interactive.
    TTModeDirection activeModeDirection = (ignoreActiveMode || diamondType == DIAMOND_TYPE_INTERACTIVE) ? overrideActiveDirection : appDelegate.modeMap.activeModeDirection;
    TTModeDirection selectedModeDirection = ignoreSelectedMode ? overrideSelectedDirection : appDelegate.modeMap.selectedModeDirection;
    TTModeDirection inspectingModeDirection = appDelegate.modeMap.inspectingModeDirection;
    TTModeDirection hoverModeDirection = appDelegate.modeMap.hoverModeDirection;

    for (NSBezierPath *path in @[northPathTop, northPathBottom,
                                 eastPathTop, eastPathBottom,
                                 westPathTop, westPathBottom,
                                 southPathTop, southPathBottom]) {
        TTModeDirection direction = NO_DIRECTION;
        BOOL bottomHalf = [@[northPathBottom, eastPathBottom, westPathBottom, southPathBottom]
                           containsObject:path];
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
        
        if (diamondType != DIAMOND_TYPE_INTERACTIVE) {
            isInspectingDirection = NO;
        }
        if (diamondType == DIAMOND_TYPE_PAIRING) {
            isSelectedDirection = [appDelegate.bluetoothMonitor.buttonTimer isDirectionPaired:direction];
        }
        
        // Fill in the color as a stroke or fill
        NSColor *modeColor;
        if (diamondType == DIAMOND_TYPE_HUD) {
            CGFloat alpha = 0.9f;
            modeColor = NSColorFromRGBAlpha(0xFFFFFF, alpha);
        } else if (diamondType == DIAMOND_TYPE_INTERACTIVE) {
            if (isActiveDirection) {
                modeColor = NSColorFromRGB(0x505AC0);
            } else if (isHoveringDirection && !isInspectingDirection) {
                modeColor = NSColorFromRGB(0xD3D7D9);
            } else if (isInspectingDirection) {
                modeColor = NSColorFromRGB(0x303AA0);
            } else {
                modeColor = NSColorFromRGB(0xD3D7D9);
                if (bottomHalf) {
                    modeColor = NSColorFromRGB(0xC3C7C9);
                }
            }
        } else if (diamondType == DIAMOND_TYPE_STATUSBAR) {
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
        } else if (diamondType == DIAMOND_TYPE_MODE || diamondType == DIAMOND_TYPE_PAIRING) {
            if (isActiveDirection) {
                CGFloat alpha = 0.5f;
                modeColor = NSColorFromRGBAlpha(0x303033, alpha);
            } else if (isSelectedDirection) {
                if (diamondType == DIAMOND_TYPE_PAIRING || appDelegate.modeMap.selectedModeDirection == direction) {
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
        
        NSBezierPath *combinedPath = [NSBezierPath alloc];
        [combinedPath appendBezierPath:path];
        if (path == northPathTop) [combinedPath appendBezierPath:northPathBottom];
        if (path == eastPathTop) [combinedPath appendBezierPath:eastPathBottom];
        if (path == westPathTop) [combinedPath appendBezierPath:westPathBottom];
        if (path == southPathTop) [combinedPath appendBezierPath:southPathBottom];

        if (!showOutline) {
            [modeColor setFill];
            if (!bottomHalf) {
                [combinedPath fill];
            }
        } else {
            combinedPath.lineWidth = isInspectingDirection ? 3.0f : 1.0f;
            [modeColor setStroke];
            [combinedPath stroke];
        }
        
        if (diamondType == DIAMOND_TYPE_INTERACTIVE) {
            if (isActiveDirection) {
                [NSColorFromRGB(0xFFFFFF) set];
            } else if (isInspectingDirection || isHoveringDirection) {
                [NSColorFromRGB(0xFFFFFF) set];
            } else {
                [NSColorFromRGB(0xFAFBFD) set];
            }
            if (!bottomHalf) {
                [combinedPath fill];
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
    [super updateTrackingAreas];
    [self createTrackingArea];
}

- (void)createTrackingArea {
    if (diamondType != DIAMOND_TYPE_INTERACTIVE) return;
    
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways |
                NSTrackingMouseMoved | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect);
    NSTrackingArea *trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options:opts
                                                                   owner:self
                                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (diamondType != DIAMOND_TYPE_INTERACTIVE) {
        [super mouseDown:theEvent];
        return;
    }

    NSPoint location = [theEvent locationInWindow];
    NSPoint center = [self convertPoint:location fromView:nil];
    
    if ([northPathTop containsPoint:center] || [northPathBottom containsPoint:center]) {
        overrideActiveDirection = NORTH;
    } else if ([eastPathTop containsPoint:center] || [eastPathBottom containsPoint:center]) {
        overrideActiveDirection = EAST;
    } else if ([westPathTop containsPoint:center] || [westPathBottom containsPoint:center]) {
        overrideActiveDirection = WEST;
    } else if ([southPathTop containsPoint:center] || [southPathBottom containsPoint:center]) {
        overrideActiveDirection = SOUTH;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (diamondType != DIAMOND_TYPE_INTERACTIVE) {
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

    overrideActiveDirection = NO_DIRECTION;
    
    [self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    
    [[NSCursor pointingHandCursor] set];
}
- (void)mouseMoved:(NSEvent *)theEvent {
    if (diamondType != DIAMOND_TYPE_INTERACTIVE) {
        [super mouseMoved:theEvent];
        return;
    }
    
    [self mouseMovement:theEvent hovering:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    if (diamondType != DIAMOND_TYPE_INTERACTIVE) {
        [super mouseExited:theEvent];
        return;
    }
    [[NSCursor arrowCursor] set];
    [appDelegate.modeMap toggleHoverModeDirection:NO_DIRECTION hovering:NO];
}

- (void)mouseMovement:(NSEvent *)theEvent hovering:(BOOL)hovering {
    if (diamondType != DIAMOND_TYPE_INTERACTIVE) return;
    
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
