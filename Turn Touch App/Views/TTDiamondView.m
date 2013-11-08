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

#define SPACING_PCT 0.01f
#define INACTIVE_OPACITY 0.2f

@synthesize size = _size;
@synthesize isHighlighted = _isHighlighted;
@synthesize ignoreSelectedMode = _ignoreSelectedMode;

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
        self.size = CGRectGetWidth(frame);
        self.isHighlighted = NO;
        self.ignoreSelectedMode = ignoreSelectedDirection;
        
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
        if (!_ignoreSelectedMode) {
            selectedModeDirection = appDelegate.diamond.selectedModeDirection;
        }
    } else {
        activeModeDirection = 0;
        if (!_ignoreSelectedMode) {
            selectedModeDirection = overrideDirection;
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    CGFloat width = NSMaxX(dirtyRect);
    CGFloat height = NSMaxY(dirtyRect);
    CGFloat spacing = SPACING_PCT * width;
    // North
    
    NSBezierPath *north = [NSBezierPath bezierPath];
    [north moveToPoint:NSMakePoint(width / 2,
                                   height)];
    [north lineToPoint:NSMakePoint(width * 1/4 + spacing,
                                   height * 3/4 + spacing)];
    [north lineToPoint:NSMakePoint(width / 2,
                                   height/2 + spacing*2)];
    [north lineToPoint:NSMakePoint(width * 3/4 - spacing,
                                   height * 3/4 + spacing)];
    [north closePath];
    
    if (!self.isHighlighted && !_ignoreSelectedMode) {
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:-0.5f];
        NSBezierPath *shadowPath = [north copy];
        [shadowPath transformUsingAffineTransform:transform];
        [[NSColor colorWithDeviceWhite:1.0f alpha:0.4f] setStroke];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(width*1/4+spacing*2, height*3/4,
                                                     width*2/4-spacing*4, -1 * height*1/4)]
         setClip];
        [shadowPath setLineWidth:0.5f];
        [shadowPath stroke];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    NSColor *northModeColor = [NSColor colorWithCalibratedHue:0.55f saturation:0.5f brightness:0.2f
                                                        alpha:activeModeDirection == NORTH ? 0.5f :
                               selectedModeDirection == NORTH ? 1.0f : INACTIVE_OPACITY];
    if (!_ignoreSelectedMode) {
        if (self.isHighlighted) {
            [[NSColor colorWithDeviceWhite:1.0f
                                     alpha:activeModeDirection == NORTH ? 0.5f :
                                           selectedModeDirection == NORTH ? 1.0f : INACTIVE_OPACITY]
             setFill];
        } else {
            [northModeColor setFill];
        }
        [north fill];
    } else {
        north.lineWidth = 1.0f;
        [northModeColor setStroke];
        [north stroke];
    }
    
    // East
    
    NSBezierPath *east = [NSBezierPath bezierPath];
    [east moveToPoint:NSMakePoint(width * 3/4 + spacing,
                                  height * 3/4 - spacing)];
    [east lineToPoint:NSMakePoint(width * 1/2 + spacing*2,
                                  height * 1/2)];
    [east lineToPoint:NSMakePoint(width * 3/4 + spacing,
                                  height * 1/4 + spacing)];
    [east lineToPoint:NSMakePoint(width,
                                  height * 1/2)];
    [east closePath];
    
    if (!self.isHighlighted && !_ignoreSelectedMode) {
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:-0.5f];
        NSBezierPath *shadowPath = [east copy];
        [shadowPath transformUsingAffineTransform:transform];
        [[NSColor colorWithDeviceWhite:1.0f alpha:0.4f] setStroke];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(width*1/2+spacing*2, height*1/2,
                                                     width*2/4-spacing*2, -1 * height*1/4)]
         setClip];
        [shadowPath setLineWidth:0.5f];
        [shadowPath stroke];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    NSColor *eastModeColor = [NSColor colorWithCalibratedHue:0.55f saturation:0.5f brightness:0.2f
                                                        alpha:activeModeDirection == EAST ? 0.5f :
                               selectedModeDirection == EAST ? 1.0f : INACTIVE_OPACITY];
    if (!_ignoreSelectedMode) {
        if (self.isHighlighted) {
            [[NSColor colorWithDeviceWhite:1.0f
                                     alpha:activeModeDirection == EAST ? 0.5f :
              selectedModeDirection == EAST ? 1.0f : INACTIVE_OPACITY]
             setFill];
        } else {
            [eastModeColor setFill];
        }
        [east fill];
    } else {
        east.lineWidth = 1.0f;
        [eastModeColor setStroke];
        [east stroke];
    }
    
    // West
    
    NSBezierPath *west = [NSBezierPath bezierPath];
    [west moveToPoint:NSMakePoint(width * 1/4 - spacing,
                                  height * 3/4 - spacing)];
    [west lineToPoint:NSMakePoint(0,
                                  height * 1/2)];
    [west lineToPoint:NSMakePoint(width * 1/4 - spacing,
                                  height * 1/4 + spacing)];
    [west lineToPoint:NSMakePoint(width * 1/2 - spacing*2,
                                  height * 1/2)];
    [west closePath];
    
    if (!self.isHighlighted && !_ignoreSelectedMode) {
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:-0.5f];
        NSBezierPath *shadowPath = [west copy];
        [shadowPath transformUsingAffineTransform:transform];
        [[NSColor colorWithDeviceWhite:1.0f alpha:0.4f] setStroke];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, height*1/2,
                                                     width*2/4-spacing*2, -1 * height*1/4)]
         setClip];
        [shadowPath setLineWidth:0.5f];
        [shadowPath stroke];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    NSColor *westModeColor = [NSColor colorWithCalibratedHue:0.55f saturation:0.5f brightness:0.2f
                                                        alpha:activeModeDirection == WEST ? 0.5f :
                               selectedModeDirection == WEST ? 1.0f : INACTIVE_OPACITY];
    if (!_ignoreSelectedMode) {
        if (self.isHighlighted) {
            [[NSColor colorWithDeviceWhite:1.0f
                                     alpha:activeModeDirection == WEST ? 0.5f :
              selectedModeDirection == WEST ? 1.0f : INACTIVE_OPACITY]
             setFill];
        } else {
            [westModeColor setFill];
        }
        [west fill];
    } else {
        west.lineWidth = 1.0f;
        [westModeColor setStroke];
        [west stroke];
    }
    
    // South
    
    NSBezierPath *south = [NSBezierPath bezierPath];
    [south moveToPoint:NSMakePoint(width * 1/2,
                                   height * 1/2 - spacing*2)];
    [south lineToPoint:NSMakePoint(width * 1/4 + spacing,
                                   height * 1/4 - spacing)];
    [south lineToPoint:NSMakePoint(width * 1/2,
                                   0)];
    [south lineToPoint:NSMakePoint(width * 3/4 - spacing,
                                   height * 1/4 - spacing)];
    [south closePath];
    
    if (!self.isHighlighted && !_ignoreSelectedMode) {
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:-0.5f];
        NSBezierPath *shadowPath = [south copy];
        [shadowPath transformUsingAffineTransform:transform];
        [[NSColor colorWithDeviceWhite:1.0f alpha:.4f] setStroke];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(width*1/4+spacing*2, 0,
                                                     width*2/4-spacing*4, height*1/4)]
         setClip];
        [shadowPath setLineWidth:0.5f];
        [shadowPath stroke];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    NSColor *southModeColor = [NSColor colorWithCalibratedHue:0.55f saturation:0.5f brightness:0.2f
                                                        alpha:activeModeDirection == SOUTH ? 0.5f :
                               selectedModeDirection == SOUTH ? 1.0f : INACTIVE_OPACITY];
    if (!_ignoreSelectedMode) {
        if (self.isHighlighted) {
            [[NSColor colorWithDeviceWhite:1.0f
                                     alpha:activeModeDirection == SOUTH ? 0.5f :
              selectedModeDirection == SOUTH ? 1.0f : INACTIVE_OPACITY]
             setFill];
        } else {
            [southModeColor setFill];
        }
        [south fill];
    } else {
        south.lineWidth = 1.0f;
        [southModeColor setStroke];
        [south stroke];
    }
}

- (void)setHighlighted:(BOOL)newFlag {
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

@end
