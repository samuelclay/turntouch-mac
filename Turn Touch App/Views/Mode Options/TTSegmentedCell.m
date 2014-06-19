//
//  TTSegmentedCell.m
//  Turn Touch App
//
//  Created by Samuel Clay on 6/16/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTSegmentedCell.h"

@implementation TTSegmentedCell

@synthesize highlightedSegment;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self setHighlightedSegment:-1];
    }
    return self;
}

- (void)awakeFromNib {
    NSLog(@"awakeFromNib");
    [self setHighlightedSegment:-1];
}

#pragma mark - Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    for (int i =0 ;i < [self segmentCount]; i++) {
        [self setupLabels:i];
        [self drawSegment:i inFrame:cellFrame withView:controlView];
    }
}

- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView {
    NSBezierPath *border = [NSBezierPath bezierPath];
    NSString *label = [self labelForSegment:segment];
    NSSize labelSize = [label sizeWithAttributes:labelAttributes];
    CGFloat radius = NSHeight(frame) * 2.f/3.f;
    CGFloat totalWidth = [self totalWidthInFrame:frame withRadius:radius upToSegment:self.segmentCount];
    BOOL highlighted = segment == highlightedSegment;
    BOOL selected = [self isSelectedForSegment:segment];
    
    CGFloat offset = [self totalWidthInFrame:frame withRadius:radius upToSegment:segment];
    frame.origin.x = (NSWidth(frame)/2 - totalWidth/2) + (offset);
    frame.origin.y = NSMinY(frame) + 3;
    frame.size.width = labelSize.width + 2*radius;
    frame.size.height = NSHeight(controlView.frame) - 4;
    
    // Stroke
    [border moveToPoint:NSMakePoint(NSMinX(frame) + radius, NSMinY(frame))];
    // Right-mode segment has rounded rect on right
    if (segment < self.segmentCount-1) {
        [border lineToPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame))];
        [border lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame))];
    } else {
        [border lineToPoint:NSMakePoint(NSMaxX(frame) - radius, NSMinY(frame))];
        [border curveToPoint:NSMakePoint(NSMaxX(frame) - radius, NSMaxY(frame))
               controlPoint1:NSMakePoint(NSMaxX(frame), NSMinY(frame))
               controlPoint2:NSMakePoint(NSMaxX(frame), NSMaxY(frame))];
    }
    // Left-mode segment has rounded rect on left
    if (segment > 0) {
        [border lineToPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame))];
        [border lineToPoint:NSMakePoint(NSMinX(frame), NSMinY(frame))];
    } else {
        [border lineToPoint:NSMakePoint(NSMinX(frame) + radius, NSMaxY(frame))];
        [border curveToPoint:NSMakePoint(NSMinX(frame) + radius, NSMinY(frame))
               controlPoint1:NSMakePoint(NSMinX(frame), NSMaxY(frame))
               controlPoint2:NSMakePoint(NSMinX(frame), NSMinY(frame))];
    }
    [border closePath];
    [border setLineWidth:1];
    [NSColorFromRGB(0xD0D0D0) set];
    [border stroke];
    
    // Fill
    BOOL selectMultiple = self.trackingMode == NSSegmentSwitchTrackingSelectAny;
    if ((highlighted && !selectMultiple && !selected) ||
        (highlighted && selectMultiple)) {
        [NSColorFromRGB(0xE5E6E8) set];
    } else if (selected) {
        [NSColorFromRGB(0xFFFFFF) set];
    } else {
        [NSColorFromRGB(0xF5F6F8) set];
    }
    [border fill];
    
    CGFloat textOffset;
    if (segment == self.segmentCount - 1) {
        textOffset = -1 * radius * 1.f/6.f;
    } else if (segment > 0) {
        textOffset = 0;
    } else {
        textOffset = radius * 1.f/6.f;
    }
    NSPoint textPoint = NSMakePoint(NSMinX(frame) + radius + textOffset,
                                    NSMidY(frame) - labelSize.height/2 - 1);
    [label drawAtPoint:textPoint withAttributes:labelAttributes];

    [super setWidth:(NSMaxX(frame) - NSMinX(frame)) forSegment:segment];
    
    if (segment < (self.segmentCount-1) &&
        [self isSelectedForSegment:(segment + 1)] &&
        ![self isSelectedForSegment:segment]) {
        NSRect rightFrame = NSMakeRect(NSMaxX(frame) - 4, NSMinY(frame), 4.0, NSHeight(frame));
        [self drawShadowInFrame:rightFrame inDirection:1];
    }
    if (segment > 0 &&
        [self isSelectedForSegment:(segment - 1)] &&
        ![self isSelectedForSegment:segment]) {
        NSRect leftFrame = NSMakeRect(NSMinX(frame), NSMinY(frame), 4.0, NSHeight(frame));
        [self drawShadowInFrame:leftFrame inDirection:-1];
    }
}

- (void)drawShadowInFrame:(NSRect)frame inDirection:(NSInteger)direction {
    [NSGraphicsContext saveGraphicsState];
    
    NSRect nsRect = frame;
    CGRect rect = *(CGRect*)&nsRect;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextClipToRect(context, *(CGRect*)&nsRect);
//    CGContextClipToMask(context, rect, [self maskForRectBottom:nsRect]);
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        0.315, 0.371, 0.450, direction > 0 ? 0.0 : 0.1,  // Right color
        0.315, 0.371, 0.450, direction > 0 ? 0.1 : 0.0  // Left color
    };
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    
    CGPoint myStartPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint myEndPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    
    CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);
    
//    CGContextSetRGBFillColor(context, 0.315, 0.371, 0.450, 0.2);
//    CGContextFillRect(context, nsRect);
    
    CGColorSpaceRelease(colorSpace);
    
    [NSGraphicsContext restoreGraphicsState];
}

- (CGFloat)totalWidthInFrame:(NSRect)frame withRadius:(CGFloat)radius upToSegment:(NSInteger)maxSegment {
    CGFloat totalWidth = 0;

    for (int s=0; s < maxSegment; s++) {
        totalWidth += [[self labelForSegment:s] sizeWithAttributes:labelAttributes].width;
        totalWidth += 2 * radius;
    }
    
    return totalWidth;
}

- (void)setupLabels:(NSInteger)segment {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x606A80);
    if ([self isSelectedForSegment:segment]) {
        textColor = NSColorFromRGB(0x303AA0);
    }
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSLeftTextAlignment];

    labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Futura" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };
}

- (void)_updateHighlightedSegment:(NSPoint)currentPoint
                           inView:(NSView *)controlView {
    [self setHighlightedSegment:-1];
    NSPoint loc = currentPoint;
    NSRect frame = controlView.frame;
    CGFloat radius = NSHeight(frame) * 2/3;
    CGFloat totalWidth = [self totalWidthInFrame:frame withRadius:radius upToSegment:self.segmentCount];
    loc.x += frame.origin.x;
    loc.y += frame.origin.y;
    frame.origin.x += (NSWidth(frame)/2 - totalWidth/2);
    NSUInteger i = 0;
    while (i < self.segmentCount) {
        frame.size.width = [self widthForSegment:i];
        if (NSMouseInRect(loc, frame, NO)) {
            [self setHighlightedSegment:i];
            break;
        }
        frame.origin.x += frame.size.width;
        i++;
    }
    
    [controlView setNeedsDisplay:YES];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint
                 inView:(NSView *)controlView {
    [self _updateHighlightedSegment:startPoint inView:controlView];
    return [super startTrackingAt:startPoint inView:controlView];
}

- (BOOL)continueTracking:(NSPoint)lastPoint
                      at:(NSPoint)currentPoint
                  inView:(NSView *)controlView {
    [self _updateHighlightedSegment:currentPoint inView:controlView];
    return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (void)stopTracking:(NSPoint)lastPoint
                  at:(NSPoint)stopPoint
              inView:(NSView *)controlView
           mouseIsUp:(BOOL)flag {
    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];

    if (highlightedSegment >= 0) {
        [self setSelected:[self isSelectedForSegment:highlightedSegment] forSegment:highlightedSegment];
        if ([self.target respondsToSelector:self.action]) {
            IMP imp = [self.target methodForSelector:self.action];
            void (*func)(id, SEL) = (void *)imp;
            func(self.target, self.action);
            // Verbose above, but without warnings from line below
//            [self.target performSelector:self.action withObject:controlView];
        }
    }
    
    [self setHighlightedSegment:-1];
}


@end
