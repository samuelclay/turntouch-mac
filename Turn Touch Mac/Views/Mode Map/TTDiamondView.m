//
//  TTDiamondView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMap.h"
#import "TTDiamondView.h"

@interface TTDiamondView ()

@property (nonatomic, strong) NSBezierPath *northPathTop;
@property (nonatomic, strong) NSBezierPath *eastPathTop;
@property (nonatomic, strong) NSBezierPath *westPathTop;
@property (nonatomic, strong) NSBezierPath *southPathTop;
@property (nonatomic, strong) NSBezierPath *northPathBottom;
@property (nonatomic, strong) NSBezierPath *eastPathBottom;
@property (nonatomic, strong) NSBezierPath *westPathBottom;
@property (nonatomic, strong) NSBezierPath *southPathBottom;

@end

@implementation TTDiamondView

#pragma mark - Initialization


- (id)initWithFrame:(NSRect)frame {
    return [self initWithFrame:frame diamondType:DIAMOND_TYPE_MODE];
}

- (id)initWithFrame:(NSRect)frame diamondType:(TTDiamondType)diamondType {
    self.diamondType = diamondType;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.size = NSWidth(frame);
        self.isHighlighted = NO;
        self.showOutline = NO;
        self.overrideSelectedDirection = NO_DIRECTION;
        self.overrideActiveDirection = NO_DIRECTION;
        self.ignoreSelectedMode = NO;
        self.ignoreActiveMode = NO;
        
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        
        [self registerAsObserver];

        if (diamondType == DIAMOND_TYPE_INTERACTIVE) {
            [self createTrackingArea];
        } else if (diamondType == DIAMOND_TYPE_HUD) {
            self.wantsLayer = YES;
        }
    }
    
    return self;
}

- (TTModeDirection)directionForLocation:(CGPoint)location {
    if ([self.northPathTop containsPoint:location] || [self.northPathBottom containsPoint:location]) {
        return NORTH;
    } else if ([self.eastPathTop containsPoint:location] || [self.eastPathBottom containsPoint:location]) {
        return EAST;
    } else if ([self.westPathTop containsPoint:location] || [self.westPathBottom containsPoint:location]) {
        return WEST;
    } else if ([self.southPathTop containsPoint:location] || [self.southPathBottom containsPoint:location]) {
        return SOUTH;
    } else {
        return NO_DIRECTION;
    }
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    self.size = NSWidth(frameRect);
//    NSLog(@"Diamond size: %f", self.size);
}

#pragma mark - KVO

- (void)dealloc {
    if (self.diamondType == DIAMOND_TYPE_INTERACTIVE) {
        [self.appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
        [self.appDelegate.modeMap removeObserver:self forKeyPath:@"hoverModeDirection"];
    }
    if (self.diamondType == DIAMOND_TYPE_PAIRING || self.diamondType == DIAMOND_TYPE_STATUSBAR) {
        [self.appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"pairedDevicesCount"];
        [self.appDelegate.bluetoothMonitor.buttonTimer removeObserver:self forKeyPath:@"pairingActivatedCount"];
    }
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"activeModeDirection"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"selectedModeDirection"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"selectedMode"];
}

- (void)registerAsObserver {
    if (self.diamondType == DIAMOND_TYPE_INTERACTIVE) {
        [self.appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                                 options:0 context:nil];
        [self.appDelegate.modeMap addObserver:self forKeyPath:@"hoverModeDirection"
                                 options:0 context:nil];
    }
    if (self.diamondType == DIAMOND_TYPE_PAIRING || self.diamondType == DIAMOND_TYPE_STATUSBAR) {
        [self.appDelegate.bluetoothMonitor addObserver:self forKeyPath:@"pairedDevicesCount"
                                          options:0 context:nil];
        [self.appDelegate.bluetoothMonitor.buttonTimer addObserver:self forKeyPath:@"pairingActivatedCount"
                                                      options:0 context:nil];
    }
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                                  options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
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
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(inspectingModeDirection))]) {
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
    return self.appDelegate.bluetoothMonitor.pairedDevicesCount.integerValue > 0;
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
    if (self.diamondType != DIAMOND_TYPE_HUD) {
        [self colorPaths:rect];
    }
}

- (void)drawPaths:(NSRect)rect {
//    NSLog(@"Draw diamond: %@ - %@", NSStringFromRect(rect), NSStringFromRect(self.bounds));
    CGFloat width = NSMaxX(rect);
    CGFloat height = NSMaxY(rect);
    CGFloat spacing = SPACING_PCT * width;
    
    self.northPathTop = [NSBezierPath bezierPath];
    self.northPathBottom = [NSBezierPath bezierPath];
    [self.northPathTop setLineJoinStyle:NSMiterLineJoinStyle];
    [self.northPathBottom setLineJoinStyle:NSMiterLineJoinStyle];
    [self.northPathTop moveToPoint:NSMakePoint(width * 1/4 + 1.3*spacing,
                                          height * 3/4 + spacing)];
    [self.northPathTop lineToPoint:NSMakePoint(width / 2,
                                          height)];
    [self.northPathTop lineToPoint:NSMakePoint(width * 3/4 - 1.3*spacing,
                                          height * 3/4 + spacing)];
    [self.northPathBottom moveToPoint:NSMakePoint(width * 3/4 - 1.3*spacing,
                                             height * 3/4 + spacing)];
    [self.northPathBottom lineToPoint:NSMakePoint(width / 2,
                                             height/2 + spacing*2)];
    [self.northPathBottom lineToPoint:NSMakePoint(width * 1/4 + 1.3*spacing,
                                             height * 3/4 + spacing)];
    
    self.eastPathTop = [NSBezierPath bezierPath];
    self.eastPathBottom = [NSBezierPath bezierPath];
    [self.eastPathTop setLineJoinStyle:NSMiterLineJoinStyle];
    [self.eastPathBottom setLineJoinStyle:NSMiterLineJoinStyle];
    [self.eastPathTop moveToPoint:NSMakePoint(width * 1/2 + 1.3*spacing*2,
                                         height * 1/2)];
    [self.eastPathTop lineToPoint:NSMakePoint(width * 3/4 + 1.3*spacing,
                                         height * 3/4 - spacing)];
    [self.eastPathTop lineToPoint:NSMakePoint(width,
                                         height * 1/2)];
    [self.eastPathBottom moveToPoint:NSMakePoint(width,
                                            height * 1/2)];
    [self.eastPathBottom lineToPoint:NSMakePoint(width * 3/4 + 1.3*spacing,
                                            height * 1/4 + spacing)];
    [self.eastPathBottom lineToPoint:NSMakePoint(width * 1/2 + 1.3*spacing*2,
                                            height * 1/2)];

    self.westPathTop = [NSBezierPath bezierPath];
    self.westPathBottom = [NSBezierPath bezierPath];
    [self.westPathTop setLineJoinStyle:NSMiterLineJoinStyle];
    [self.westPathBottom setLineJoinStyle:NSMiterLineJoinStyle];
    [self.westPathTop moveToPoint:NSMakePoint(width * 1/2 - 1.3*spacing*2,
                                         height * 1/2)];
    [self.westPathTop lineToPoint:NSMakePoint(width * 1/4 - 1.3*spacing,
                                         height * 3/4 - spacing)];
    [self.westPathTop lineToPoint:NSMakePoint(0,
                                         height * 1/2)];
    [self.westPathBottom moveToPoint:NSMakePoint(0,
                                            height * 1/2)];
    [self.westPathBottom lineToPoint:NSMakePoint(width * 1/4 - 1.3*spacing,
                                            height * 1/4 + spacing)];
    [self.westPathBottom lineToPoint:NSMakePoint(width * 1/2 - 1.3*spacing*2,
                                            height * 1/2)];
    
    self.southPathTop = [NSBezierPath bezierPath];
    self.southPathBottom = [NSBezierPath bezierPath];
    [self.southPathTop setLineJoinStyle:NSMiterLineJoinStyle];
    [self.southPathBottom setLineJoinStyle:NSMiterLineJoinStyle];
    [self.southPathTop moveToPoint:NSMakePoint(width * 3/4 - 1.3*spacing,
                                          height * 1/4 - spacing)];
    [self.southPathTop lineToPoint:NSMakePoint(width * 1/2,
                                          height * 1/2 - spacing*2)];
    [self.southPathTop lineToPoint:NSMakePoint(width * 1/4 + 1.3*spacing,
                                          height * 1/4 - spacing)];
    [self.southPathBottom moveToPoint:NSMakePoint(width * 1/4 + 1.3*spacing,
                                             height * 1/4 - spacing)];
    [self.southPathBottom lineToPoint:NSMakePoint(width * 1/2,
                                             0)];
    [self.southPathBottom lineToPoint:NSMakePoint(width * 3/4 - 1.3*spacing,
                                             height * 1/4 - spacing)];
}

- (void)colorPaths:(NSRect)rect {
    // TODO: This entire view needs to be split into a mode diamond and action diamond, since only
    //       the action diamond is interactive.
    TTModeDirection activeModeDirection = (self.ignoreActiveMode || self.diamondType == DIAMOND_TYPE_INTERACTIVE) ? self.overrideActiveDirection : self.appDelegate.modeMap.activeModeDirection;
    TTModeDirection selectedModeDirection = self.ignoreSelectedMode ? self.overrideSelectedDirection : self.appDelegate.modeMap.selectedModeDirection;
    TTModeDirection inspectingModeDirection = self.appDelegate.modeMap.inspectingModeDirection;
    TTModeDirection hoverModeDirection = self.appDelegate.modeMap.hoverModeDirection;

    for (NSBezierPath *path in @[self.northPathTop, self.northPathBottom,
                                 self.eastPathTop, self.eastPathBottom,
                                 self.westPathTop, self.westPathBottom,
                                 self.southPathTop, self.southPathBottom]) {
        TTModeDirection direction = NO_DIRECTION;
        BOOL bottomHalf = [@[self.northPathBottom, self.eastPathBottom, self.westPathBottom, self.southPathBottom]
                           containsObject:path];
        if ([path isEqual:self.northPathTop] || [path isEqual:self.northPathBottom]) {
            direction = NORTH;
        } else if ([path isEqual:self.eastPathTop] || [path isEqual:self.eastPathBottom]) {
            direction = EAST;
        } else if ([path isEqual:self.westPathTop] || [path isEqual:self.westPathBottom]) {
            direction = WEST;
        } else if ([path isEqual:self.southPathTop] || [path isEqual:self.southPathBottom]) {
            direction = SOUTH;
        }

        BOOL isHoveringDirection    = hoverModeDirection == direction;
        BOOL isInspectingDirection  = inspectingModeDirection == direction;
        BOOL isSelectedDirection    = selectedModeDirection == direction;
        BOOL isActiveDirection      = activeModeDirection == direction;
        
        if (self.diamondType != DIAMOND_TYPE_INTERACTIVE) {
            isInspectingDirection = NO;
        }
        if (self.diamondType == DIAMOND_TYPE_PAIRING) {
            isSelectedDirection = [self.appDelegate.bluetoothMonitor.buttonTimer isDirectionPaired:direction];
        }
        
        // Fill in the color as a stroke or fill
        NSColor *modeColor;
        if (self.diamondType == DIAMOND_TYPE_HUD) {
            CGFloat alpha = 0.9f;
            modeColor = NSColorFromRGBAlpha(0xFFFFFF, alpha);
        } else if (self.diamondType == DIAMOND_TYPE_INTERACTIVE) {
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
        } else if (self.diamondType == DIAMOND_TYPE_STATUSBAR) {
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
                    modeColor = NSColorFromRGB(0x417cf1);
                } else {
                    CGFloat alpha = 0.5f;
                    modeColor = NSColorFromRGBAlpha(0xE1E5E9, alpha);
                }
            }
        } else if (self.diamondType == DIAMOND_TYPE_MODE || self.diamondType == DIAMOND_TYPE_PAIRING) {
            if (isActiveDirection) {
                CGFloat alpha = 0.5f;
                modeColor = NSColorFromRGBAlpha(0x303033, alpha);
            } else if (isSelectedDirection) {
                if (self.diamondType == DIAMOND_TYPE_PAIRING || self.appDelegate.modeMap.selectedModeDirection == direction) {
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
        if (path == self.northPathTop) [combinedPath appendBezierPath:self.northPathBottom];
        if (path == self.eastPathTop) [combinedPath appendBezierPath:self.eastPathBottom];
        if (path == self.westPathTop) [combinedPath appendBezierPath:self.westPathBottom];
        if (path == self.southPathTop) [combinedPath appendBezierPath:self.southPathBottom];

        if (!self.showOutline) {
            [modeColor setFill];
            if (!bottomHalf) {
                [combinedPath fill];
            }
        } else {
            combinedPath.lineWidth = isInspectingDirection ? 1.0f : 1.0f;
            [modeColor setStroke];
            [combinedPath stroke];
        }
        
        if (self.diamondType == DIAMOND_TYPE_INTERACTIVE) {
            if (isActiveDirection) {
                [NSColorFromRGB(0xFFFFFF) set];
            } else if (isInspectingDirection || isHoveringDirection) {
                [NSColorFromRGB(0xFFFFFF) set];
            } else {
                [NSColorFromRGB(0xFAFBFD) set];
            }
//            if (!bottomHalf) {
                [combinedPath fill];
//            }
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
    if (self.diamondType != DIAMOND_TYPE_INTERACTIVE) return;
    
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
    if (self.diamondType != DIAMOND_TYPE_INTERACTIVE) {
        [super mouseDown:theEvent];
        return;
    }

    NSPoint location = [theEvent locationInWindow];
    NSPoint center = [self convertPoint:location fromView:nil];
    TTModeDirection direction = [self directionForLocation:center];
    
    if (direction != NO_DIRECTION) {
        self.overrideActiveDirection = direction;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (self.diamondType != DIAMOND_TYPE_INTERACTIVE) {
        [super mouseUp:theEvent];
        return;
    }
    
    NSPoint location = [theEvent locationInWindow];
    NSPoint center = [self convertPoint:location fromView:nil];
    TTModeDirection direction = [self directionForLocation:center];
    
    if (self.appDelegate.modeMap.isButtonActionPerform) {
        if (direction == NO_DIRECTION) {
            return;
        } else if (theEvent.clickCount == 2) {
            [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSingleActionForDirection:) object:@(direction)];
            [self performDoubleActionForDirection:direction];
        } else {
            [self performSelector:@selector(performSingleActionForDirection:) withObject:@(direction) afterDelay:NSEvent.doubleClickInterval];
        }
        
        return;
    }
    
    if (direction != NO_DIRECTION) {
        [self.appDelegate.modeMap toggleInspectingModeDirection:direction];
    }
    
    self.overrideActiveDirection = NO_DIRECTION;
    
    [self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    
    [[NSCursor pointingHandCursor] set];
}
- (void)mouseMoved:(NSEvent *)theEvent {
    if (self.diamondType != DIAMOND_TYPE_INTERACTIVE) {
        [super mouseMoved:theEvent];
        return;
    }
    
    NSPoint location = [theEvent locationInWindow];
    NSPoint center = [self convertPoint:location fromView:nil];
    TTModeDirection direction = [self directionForLocation:center];
    
    self.overrideActiveDirection = direction;
    
    [self mouseMovement:theEvent hovering:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    if (self.diamondType != DIAMOND_TYPE_INTERACTIVE) {
        [super mouseExited:theEvent];
        return;
    }
    [[NSCursor arrowCursor] set];
    [self.appDelegate.modeMap toggleHoverModeDirection:NO_DIRECTION hovering:NO];
}

- (void)mouseMovement:(NSEvent *)theEvent hovering:(BOOL)hovering {
    if (self.diamondType != DIAMOND_TYPE_INTERACTIVE) return;
    
    NSPoint location = [theEvent locationInWindow];
    NSPoint center = [self convertPoint:location fromView:nil];
    TTModeDirection direction = [self directionForLocation:center];
    
//    NSLog(@"Movement: %@ in %@", NSStringFromPoint(center), NSStringFromRect(self.bounds));
    
    if (direction != NO_DIRECTION) {
        [self.appDelegate.modeMap toggleHoverModeDirection:direction hovering:hovering];
    } else if (self.appDelegate.modeMap.hoverModeDirection != NO_DIRECTION) {
        [self.appDelegate.modeMap toggleHoverModeDirection:NO_DIRECTION hovering:NO];
    }
}

- (void)performSingleActionForDirection:(NSNumber *)directionNumber {
    TTModeDirection direction = (TTModeDirection)directionNumber.integerValue;
    NSString *actionName = [self.appDelegate.modeMap.selectedMode actionNameInDirection:direction];
    
    self.appDelegate.modeMap.activeModeDirection = direction;
    [self.appDelegate.hudController toastActiveAction:actionName inDirection:direction];
    [self.appDelegate.modeMap runActiveButton];
    self.overrideActiveDirection = NO_DIRECTION;
    
    [self setNeedsDisplay:YES];
}

- (void)performDoubleActionForDirection:(TTModeDirection)direction {
    NSString *actionName = [self.appDelegate.modeMap.selectedMode actionNameInDirection:direction];
    
    self.appDelegate.modeMap.activeModeDirection = direction;
    [self.appDelegate.hudController toastDoubleAction:actionName inDirection:direction];
    [self.appDelegate.modeMap runDoubleButton:direction];
    self.overrideActiveDirection = NO_DIRECTION;
    
    [self setNeedsDisplay:YES];
}

@end
