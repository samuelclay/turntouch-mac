//
//  TTDiamond.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamond.h"

@implementation TTDiamond

#define SPACING 0.25f
#define INACTIVE_OPACITY 0.2f

@synthesize size = _size;
@synthesize isHighlighted = _isHighlighted;
@synthesize activeMode = _activeMode;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.size = CGRectGetWidth(frame);
        self.activeMode = WEST;
        self.isHighlighted = NO;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    CGFloat width = NSMaxX(dirtyRect);
    CGFloat height = NSMaxY(dirtyRect);
    
    NSBezierPath *north = [NSBezierPath bezierPath];
    [north moveToPoint:NSMakePoint(width / 2,
                                   height)];
    [north lineToPoint:NSMakePoint(width * 1/4 + SPACING,
                                   height * 3/4 + SPACING)];
    [north lineToPoint:NSMakePoint(width / 2,
                                   height/2 + SPACING*2)];
    [north lineToPoint:NSMakePoint(width * 3/4 - SPACING,
                                   height * 3/4 + SPACING)];
    [north closePath];
    
    if (!self.isHighlighted) {
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:-0.5f];
        NSBezierPath *shadowPath = [north copy];
        [shadowPath transformUsingAffineTransform:transform];
        [[NSColor colorWithDeviceWhite:1.0f alpha:0.4f] setStroke];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(width*1/4+SPACING*2, height*3/4, width*2/4-SPACING*4, -1 * height*1/4)] setClip];
        [shadowPath setLineWidth:0.5f];
        [shadowPath stroke];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    if (self.isHighlighted) {
        [[NSColor colorWithDeviceWhite:1.0f
                                 alpha:self.activeMode == NORTH ? 1.0f : INACTIVE_OPACITY]
         setFill];
    } else {
        [[NSColor colorWithCalibratedHue:0.55f saturation:0.5f brightness:0.2f
                                   alpha:self.activeMode == NORTH ? 1.0f : INACTIVE_OPACITY]
         setFill];
    }
    [north fill];
    
    
    // West
    
    NSBezierPath *west = [NSBezierPath bezierPath];
    [west moveToPoint:NSMakePoint(width * 1/4 - SPACING,
                                   height * 3/4 - SPACING)];
    [west lineToPoint:NSMakePoint(0,
                                   height * 1/2)];
    [west lineToPoint:NSMakePoint(width * 1/4 - SPACING,
                                   height * 1/4 + SPACING)];
    [west lineToPoint:NSMakePoint(width * 1/2 - SPACING*2,
                                   height * 1/2)];
    [west closePath];
    
    if (!self.isHighlighted) {
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:-0.5f];
        NSBezierPath *shadowPath = [west copy];
        [shadowPath transformUsingAffineTransform:transform];
        [[NSColor colorWithDeviceWhite:1.0f alpha:0.4f] setStroke];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, height*1/2, width*2/4-SPACING*2, -1 * height*1/4)] setClip];
        [shadowPath setLineWidth:0.5f];
        [shadowPath stroke];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    if (self.isHighlighted) {
        [[NSColor colorWithDeviceWhite:1.0f
                                 alpha:self.activeMode == WEST ? 1.0f : INACTIVE_OPACITY]
         setFill];
    } else {
        [[NSColor colorWithCalibratedHue:0.3f saturation:0.5f brightness:0.2f
                                   alpha:self.activeMode == WEST ? 1.0f : INACTIVE_OPACITY]
         setFill];
    }
    [west fill];
    
    
    // South
    
    NSBezierPath *south = [NSBezierPath bezierPath];
    [south moveToPoint:NSMakePoint(width * 1/2,
                                   height * 1/2 - SPACING*2)];
    [south lineToPoint:NSMakePoint(width * 1/4 + SPACING,
                                   height * 1/4 - SPACING)];
    [south lineToPoint:NSMakePoint(width * 1/2,
                                   0)];
    [south lineToPoint:NSMakePoint(width * 3/4 - SPACING,
                                   height * 1/4 - SPACING)];
    [south closePath];
    
    if (!self.isHighlighted) {
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:-0.5f];
        NSBezierPath *shadowPath = [south copy];
        [shadowPath transformUsingAffineTransform:transform];
        [[NSColor colorWithDeviceWhite:1.0f alpha:.4f] setStroke];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(width*1/4+SPACING*2, 0, width*2/4-SPACING*4, height*1/4)] setClip];
        [shadowPath setLineWidth:0.5f];
        [shadowPath stroke];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    if (self.isHighlighted) {
        [[NSColor colorWithDeviceWhite:1.0f
                                 alpha:self.activeMode == SOUTH ? 1.0f : INACTIVE_OPACITY]
         setFill];
    } else {
        [[NSColor colorWithCalibratedHue:0.9f saturation:0.5f brightness:0.2f
                                   alpha:self.activeMode == SOUTH ? 1.0f : INACTIVE_OPACITY]
         setFill];
    }
    [south fill];
    
    
    // East
    
    NSBezierPath *east = [NSBezierPath bezierPath];
    [east moveToPoint:NSMakePoint(width * 3/4 + SPACING,
                                  height * 3/4 - SPACING)];
    [east lineToPoint:NSMakePoint(width * 1/2 + SPACING*2,
                                  height * 1/2)];
    [east lineToPoint:NSMakePoint(width * 3/4 + SPACING,
                                  height * 1/4 + SPACING)];
    [east lineToPoint:NSMakePoint(width,
                                  height * 1/2)];
    [east closePath];
    
    if (!self.isHighlighted) {
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:-0.5f];
        NSBezierPath *shadowPath = [east copy];
        [shadowPath transformUsingAffineTransform:transform];
        [[NSColor colorWithDeviceWhite:1.0f alpha:0.4f] setStroke];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(width*1/2+SPACING*2, height*1/2, width*2/4-SPACING*2, -1 * height*1/4)] setClip];
        [shadowPath setLineWidth:0.5f];
        [shadowPath stroke];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    if (self.isHighlighted) {
        [[NSColor colorWithDeviceWhite:1.0f
                                 alpha:self.activeMode == EAST ? 1.0f : INACTIVE_OPACITY]
         setFill];
    } else {
        [[NSColor colorWithCalibratedHue:0.3f saturation:0.5f brightness:0.2f
                                   alpha:self.activeMode == EAST ? 1.0f : INACTIVE_OPACITY]
         setFill];
    }
    [east fill];
}

- (void)setHighlighted:(BOOL)newFlag {
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

@end
