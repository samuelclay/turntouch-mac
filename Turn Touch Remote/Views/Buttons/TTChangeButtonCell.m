//
//  TTChangeButtonCell.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTChangeButtonCell.h"
#import "NSAttributedString+Extra.h"

#define DEFAULT_BORDER_RADIUS 5.0f

@implementation TTChangeButtonCell

@synthesize mouseDown;
@synthesize borderRadius;
@synthesize useAltStyle;
@synthesize rightBorderRadius;

- (id)init {
    if (self = [super init]) {
        mouseDown = NO;
        borderRadius = DEFAULT_BORDER_RADIUS;
        useAltStyle = NO;
    }
    
    return self;
}

- (NSCellStyleMask)highlightsBy {
    if (useAltStyle) {
        return NSNoCellMask;
    }
    return NSContentsCellMask;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    // Create clip boundary
    NSBezierPath *clip;
    if (rightBorderRadius) {
        // .292 = 1 - 1/sqrt(2)
        clip = [NSBezierPath bezierPath];
        [clip moveToPoint:NSMakePoint(NSMinX(frame), NSMinY(frame))];
        [clip lineToPoint:NSMakePoint(NSMaxX(frame) - rightBorderRadius, NSMinY(frame))];
        [clip curveToPoint:NSMakePoint(NSMaxX(frame) - rightBorderRadius, NSMaxY(frame))
             controlPoint1:NSMakePoint(NSMaxX(frame) + rightBorderRadius*.292, NSMinY(frame))
             controlPoint2:NSMakePoint(NSMaxX(frame) + rightBorderRadius*.292, NSMaxY(frame))];
        [clip lineToPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame))];
        [clip closePath];
        [clip addClip];
    } else {
        clip = [NSBezierPath bezierPath];
        [clip appendBezierPathWithRoundedRect:frame
                                      xRadius:borderRadius yRadius:borderRadius];
        [clip addClip];
    }
    
    // Add gradient background
    NSGradient *gradient;
    if (mouseDown) {
        if (useAltStyle) {
            gradient = [[NSGradient alloc]
                        initWithStartingColor:NSColorFromRGB(0x3173AB)
                        endingColor:NSColorFromRGB(0x3173AB)];
        } else {
            gradient = [[NSGradient alloc]
                        initWithStartingColor:NSColorFromRGB(0xE0E0E0)
                        endingColor:NSColorFromRGB(0xF7F7F7)];
        }
    } else {
        if (useAltStyle) {
            gradient = [[NSGradient alloc]
                        initWithStartingColor:NSColorFromRGB(0x4284C1)
                        endingColor:NSColorFromRGB(0x4284C1)];
        } else {
            gradient = [[NSGradient alloc]
                        initWithStartingColor:NSColorFromRGB(0xE7E7E7)
                        endingColor:[NSColor whiteColor]];
        }
    }
    [gradient drawInRect:frame angle:90];
    
    // Add border
    NSBezierPath *line = [clip copy];
    [line setLineWidth:1.0];
    if (useAltStyle) {
        [NSColorFromRGB(0x206396) set];
    } else {
        [NSColorFromRGB(0xC2CBCE) set];
    }
    [line stroke];
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSFont *font = [NSFont fontWithName:@"Effra" size:12.f];
    NSColor *color = NSColorFromRGB(0xA0A3A8);
    if (self.isHighlighted) {
        color = NSColorFromRGB(0x606368);
    }
    NSDictionary *titleAttributes = @{NSFontAttributeName:font,
                                      NSForegroundColorAttributeName: color};
    NSSize placeholderSize = [@"Aj" boundingRectWithSize:frame.size
                                                 options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading
                                              attributes:titleAttributes].size;
    NSSize textSize = [title.string boundingRectWithSize:frame.size
                                                 options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading
                                              attributes:titleAttributes].size;
    
    [title.string drawAtPoint:NSMakePoint(NSMidX(frame) - textSize.width/2,
                                   NSHeight(controlView.frame)/2 - placeholderSize.height/2 - 2.f) withAttributes:titleAttributes];

    
    return frame;
}

@end
