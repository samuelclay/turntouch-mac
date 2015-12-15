//
//  TTSliderCell.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/14/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTSliderCell.h"

@interface TTSliderCell () {
    NSRect _currentKnobRect;
    NSRect _barRect;
    
    BOOL _flipped;
}

@end

@implementation TTSliderCell

- (void)drawTickMarks {
    [super drawTickMarks];
}

- (void)drawKnob:(NSRect)knobRect
{
    NSLog(@"drawKnob: %@", NSStringFromRect(knobRect));
    [self drawBarInside:_barRect flipped:_flipped];
    [self.controlView lockFocus];
    //// Color Declarations
    NSColor *borderColor = NSColorFromRGB(0xCFCECE);
    NSColor *knobColor = NSColorFromRGB(0xFFFFFF);
    if (isPressed || self.isHighlighted) {
        knobColor = NSColorFromRGB(0xF1F0F0);
        borderColor = NSColorFromRGB(0xDFDEDE);
    }
    //// Gradient Declarations
    NSGradient* linearGradient3 = [[NSGradient alloc] initWithStartingColor:knobColor endingColor:knobColor];
    
    //// Frames
    NSRect sliderFrame = knobRect;
    CGFloat posY = 1.00;
    if (self.numberOfTickMarks == 0) {
        posY = 1.00;
    } else if (self.tickMarkPosition == NSTickMarkBelow) {
        posY = 1.25;
    }
    
    //// Subframes
    NSRect track = NSMakeRect(NSMinX(sliderFrame) + 0.5,
                              NSMinY(sliderFrame) + floor((NSHeight(sliderFrame) * 0.75) + 0.5),
                              floor(NSWidth(sliderFrame) * 1.00000 + 0.5) + 0.5, 24);
    NSRect trackFrame = NSMakeRect(NSMinX(track) + floor(NSWidth(track) * 0.00000 + 0.5),
                                   NSMinY(track) + NSHeight(track) * 0.25,
                                   floor(NSWidth(track) * 1.00000 + 0.5), 24);
    NSRect urta = NSMakeRect(NSMinX(trackFrame) + 1.0,
                             NSMinY(trackFrame) - 3,
                             16, 16);
    
    
    //// Oval 4 Drawing
    NSRect oval4Rect = NSMakeRect(NSMinX(urta) + 0.5,
                                  NSMinY(urta) - NSHeight(urta)*posY + 0.5,
                                  16,
                                  NSHeight(urta));
    NSBezierPath* oval4Path = [NSBezierPath bezierPathWithOvalInRect: oval4Rect];
    [NSGraphicsContext saveGraphicsState];
    [oval4Path addClip];
    [linearGradient3 drawFromPoint: NSMakePoint(NSMidX(oval4Rect) + 0 * NSWidth(oval4Rect) / 11, NSMidY(oval4Rect) + -5.73 * NSHeight(oval4Rect) / 11)
                           toPoint: NSMakePoint(NSMidX(oval4Rect) + 0 * NSWidth(oval4Rect) / 11, NSMidY(oval4Rect) + 5.73 * NSHeight(oval4Rect) / 11)
                           options: NSGradientDrawsBeforeStartingLocation | NSGradientDrawsAfterEndingLocation];
    [NSGraphicsContext restoreGraphicsState];
    [borderColor setStroke];
    [oval4Path setLineWidth: 1];
    [oval4Path stroke];
//    
//    
//    //// Oval 5 Drawing
//    NSBezierPath* oval5Path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(NSMinX(urta) + 4.5, NSMinY(urta) + floor(NSHeight(urta) * 0.37500) + 0.5, 3, floor(NSHeight(urta) * 0.62500) - floor(NSHeight(urta) * 0.37500))];
//    [color16 setFill];
//    [oval5Path fill];
//    [color19 setStroke];
//    [oval5Path setLineWidth: 1];
//    [oval5Path stroke];
    
    [self.controlView unlockFocus];
}

- (void)drawBarInside:(NSRect)rect flipped:(BOOL)flipped
{
    NSLog(@"Draw bar: %@ / %d", NSStringFromRect(rect), flipped);
    _barRect = rect;
    _flipped = flipped;
    CGFloat value = ([self doubleValue]  - [self minValue]) / ([self maxValue] - [self minValue]);
    CGFloat finalWidth = value * ([[self controlView] frame].size.width - 8);
    CGFloat posY = 0.90;
    if (self.numberOfTickMarks == 0) {
        posY = 0.75;
    } else if (self.tickMarkPosition == NSTickMarkBelow) {
        posY = 0.75;
    }
    
    //// General Declarations
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    //// Color Declarations
    NSColor* leftBackgroundColor = NSColorFromRGB(0x4685BE);
    NSColor* rightBackgroundColor = NSColorFromRGB(0xE2E4E6);
    
    //// Gradient Declarations
    NSGradient* leftGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                leftBackgroundColor, 0.0,
                                leftBackgroundColor, 1.0, nil];
    NSGradient* rightGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                 rightBackgroundColor, 0.0,
                                 rightBackgroundColor, 1.0, nil];
    

    //// Frames
    NSRect leftRect = rect;
    leftRect.size.width = finalWidth;
    NSRect sliderFrame = rect;
    
    //// Subframes
    NSRect ltrack = NSMakeRect(NSMinX(leftRect) + floor(NSWidth(leftRect) * 0.00000 + 0.5),
                               NSMinY(leftRect) + floor((NSHeight(leftRect) - 16) * posY + 0.5),
                               MAX(1, floor(NSWidth(leftRect) * 1.00000 + 0.5) - floor(NSWidth(leftRect) * 0.00000 + 0.5)), 18);
    NSRect ltrackFrame = NSMakeRect(NSMinX(ltrack) + floor(NSWidth(ltrack) * 0.00000 + 0.5),
                                    NSMinY(ltrack) + NSHeight(ltrack) - 9,
                                    floor(NSWidth(ltrack) * 1.00000 + 0.5) - floor(NSWidth(ltrack) * 0.00000 + 0.5), 6);
    NSRect ltrackk = NSMakeRect(NSMinX(ltrackFrame) + 1,
                                NSMinY(ltrackFrame),
                                MAX(1, NSWidth(ltrackFrame) - 2), 5);
    NSRect rtrack = NSMakeRect(NSMinX(sliderFrame) + floor(NSWidth(sliderFrame) * 0.00000 + 0.5),
                               NSMinY(sliderFrame) + floor((NSHeight(sliderFrame) - 16) * posY + 0.5),
                               MAX(1, floor(NSWidth(sliderFrame) * 1.00000 + 0.5) - floor(NSWidth(sliderFrame) * 0.00000 + 0.5)), 18);
    NSRect rtrackFrame = NSMakeRect(NSMinX(rtrack) + floor(NSWidth(rtrack) * 0.00000 + 0.5),
                                    NSMinY(rtrack) + NSHeight(rtrack) - 9,
                                    floor(NSWidth(rtrack) * 1.00000 + 0.5) - floor(NSWidth(rtrack) * 0.00000 + 0.5), 6);
    NSRect rtrackk = NSMakeRect(NSMinX(rtrackFrame) + 1,
                                NSMinY(rtrackFrame),
                                MAX(1, NSWidth(rtrackFrame) - 2), 5);
    
    
    //// Rounded Rectangle Drawing
    NSBezierPath* leftRoundedRectanglePath = [NSBezierPath
                                              bezierPathWithRoundedRect:
                                              NSMakeRect(NSMinX(ltrackk) + floor(NSWidth(ltrackk) * 0.00000 + 0.5),
                                                         NSMinY(ltrackk) + floor(NSHeight(ltrackk) * 0.00000 + 0.5),
                                                         MAX(1, floor(NSWidth(ltrackk) * 1.00000 + 0.5) - floor(NSWidth(ltrackk) * 0.00000 + 0.5)),
                                                         floor(NSHeight(ltrackk) * 1.00000 + 0.5) - floor(NSHeight(ltrackk) * 0.00000 + 0.5))
                                              xRadius: 2.5 yRadius: 2.5];
    NSBezierPath* rightRoundedRectanglePath = [NSBezierPath
                                               bezierPathWithRoundedRect:
                                               NSMakeRect(NSMinX(rtrackk) + floor(NSWidth(rtrackk) * 0.00000 + 0.5),
                                                          NSMinY(rtrackk) + floor(NSHeight(rtrackk) * 0.00000 + 0.5),
                                                          floor(NSWidth(rtrackk) * 1.00000 + 0.5) - floor(NSWidth(rtrackk) * 0.00000 + 0.5),
                                                          floor(NSHeight(rtrackk) * 1.00000 + 0.5) - floor(NSHeight(rtrackk) * 0.00000 + 0.5))
                                               xRadius: 2.5 yRadius: 2.5];
    [NSGraphicsContext saveGraphicsState];
    CGContextBeginTransparencyLayer(context, NULL);
    [rightGradient drawInBezierPath:rightRoundedRectanglePath angle: 90];
    [leftGradient drawInBezierPath:leftRoundedRectanglePath angle: 90];
    CGContextEndTransparencyLayer(context);
    [NSGraphicsContext restoreGraphicsState];
}

@end
