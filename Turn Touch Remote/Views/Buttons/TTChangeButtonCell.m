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
    NSRect borderRect = NSMakeRect(0.5f, 0.5f,
                                   NSWidth(frame) - 1,
                                   NSHeight(frame) - 1);
    // Create clip boundary
    NSBezierPath *clip = [NSBezierPath bezierPath];
    [clip appendBezierPathWithRoundedRect:borderRect
                                  xRadius:borderRadius yRadius:borderRadius];
    [clip addClip];
    
    // Add gradient background
    NSGradient *gradient;
    if (mouseDown) {
        if (useAltStyle) {
            gradient = [[NSGradient alloc]
                        initWithStartingColor:NSColorFromRGB(0x3173AB)
                        endingColor:NSColorFromRGB(0x3173AB)];
        } else {
            gradient = [[NSGradient alloc]
                        initWithStartingColor:NSColorFromRGB(0xF7F7F7)
                        endingColor:NSColorFromRGB(0xE0E0E0)];
        }
    } else {
        if (useAltStyle) {
            gradient = [[NSGradient alloc]
                        initWithStartingColor:NSColorFromRGB(0x4284C1)
                        endingColor:NSColorFromRGB(0x4284C1)];
        } else {
            gradient = [[NSGradient alloc]
                        initWithStartingColor:[NSColor whiteColor]
                        endingColor:NSColorFromRGB(0xE7E7E7)];
        }
    }
    [gradient drawInRect:frame angle:90];
    
    // Add border
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line appendBezierPathWithRoundedRect:borderRect
                                  xRadius:borderRadius yRadius:borderRadius];
    [line setLineWidth:1.0];
    if (useAltStyle) {
        [NSColorFromRGB(0x206396) set];
    } else {
        [NSColorFromRGB(0xD0D0D0) set];
    }
    [line stroke];
}

- (NSRect)drawTitle:(NSAttributedString *)_title withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSMutableAttributedString *title = [[_title upperCaseAttributedStringFromAttributedString:_title]
                                        mutableCopy];
    [title beginEditing];
    [title enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, title.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSFont *font = [NSFont fontWithName:@"Effra" size:11.f];
        NSColor *color = NSColorFromRGB(0xA0A3A8);
        if (self.isHighlighted) {
            color = NSColorFromRGB(0x606368);
        }
        [title removeAttribute:NSFontAttributeName range:range];
        [title addAttribute:NSFontAttributeName value:font range:range];
        [title addAttribute:NSForegroundColorAttributeName value:color range:range];
    }];
    [title endEditing];

    NSSize textSize = [title size];
    
    [title drawAtPoint:NSMakePoint(frame.origin.x + frame.size.width/2 - textSize.width/2,
                                   frame.origin.y + frame.size.height/2.f - textSize.height/2.f - 2.f)];

    
    return frame;
}

@end
