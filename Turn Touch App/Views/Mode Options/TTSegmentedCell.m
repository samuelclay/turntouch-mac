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

#pragma mark - Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [self setupLabels];
    
    for (int i =0 ;i < [self segmentCount]; i++) {
        [self drawSegment:i inFrame:cellFrame withView:controlView];
    }
}

- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView {
    NSBezierPath *border = [NSBezierPath bezierPath];
    NSString *label = [self labelForSegment:segment];
    NSSize labelSize = [label sizeWithAttributes:labelAttributes];
    CGFloat radius = NSHeight(frame) * 2/3;
    CGFloat totalWidth = [self totalWidthInFrame:frame withRadius:radius upToSegment:self.segmentCount];
    BOOL highlighted = segment == highlightedSegment;
    BOOL selected = segment == self.selectedSegment;
    
    CGFloat offset = [self totalWidthInFrame:frame withRadius:radius upToSegment:segment];
    frame.origin.x = (NSWidth(frame)/2 - totalWidth/2) + (offset);
    frame.origin.y = 0;
    frame.size.width = labelSize.width + 2*radius;
    frame.size.height = controlView.frame.size.height;
    
    // Stroke
    [border moveToPoint:NSMakePoint(NSMinX(frame) + radius, NSMinY(frame) + 1)];
    // Right-mode segment has rounded rect on right
    if (segment < self.segmentCount-1) {
        [border lineToPoint:NSMakePoint(NSMaxX(frame) - radius/2, NSMinY(frame) + 1)];
        [border lineToPoint:NSMakePoint(NSMaxX(frame) - radius/2, NSMaxY(frame) - 1)];
    } else {
        [border lineToPoint:NSMakePoint(NSMaxX(frame) - radius, NSMinY(frame) + 1)];
        [border curveToPoint:NSMakePoint(NSMaxX(frame) - radius, NSMaxY(frame) - 1)
               controlPoint1:NSMakePoint(NSMaxX(frame), NSMinY(frame) + 1)
               controlPoint2:NSMakePoint(NSMaxX(frame), NSMaxY(frame) - 1)];
    }
    // Left-mode segment has rounded rect on left
    if (segment > 0) {
        [border lineToPoint:NSMakePoint(NSMinX(frame) + radius/2, NSMaxY(frame) - 1)];
        [border lineToPoint:NSMakePoint(NSMinX(frame) + radius/2, NSMinY(frame) + 1)];
    } else {
        [border lineToPoint:NSMakePoint(NSMinX(frame) + radius, NSMaxY(frame) - 1)];
        [border curveToPoint:NSMakePoint(NSMinX(frame) + radius, NSMinY(frame) + 1)
               controlPoint1:NSMakePoint(NSMinX(frame), NSMaxY(frame) - 1)
               controlPoint2:NSMakePoint(NSMinX(frame), NSMinY(frame) + 1)];
    }
    [border closePath];
    [border setLineWidth:1];
    [NSColorFromRGB(0xD0D0D0) set];
    [border stroke];
    
    // Fill
    if (selected) {
        [NSColorFromRGB(0xFFFFFF) set];
    } else if (highlighted) {
        [NSColorFromRGB(0xE5E6E8) set];
    } else {
        [NSColorFromRGB(0xF5F6F8) set];
    }
    [border fill];

    [label drawInRect:frame withAttributes:labelAttributes];

    [super setWidth:(labelSize.width + 2*radius) forSegment:segment];
}

- (CGFloat)totalWidthInFrame:(NSRect)frame withRadius:(CGFloat)radius upToSegment:(NSInteger)maxSegment {
    CGFloat totalWidth = 0;

    for (int s=0; s < maxSegment; s++) {
        totalWidth += [[self labelForSegment:s] sizeWithAttributes:labelAttributes].width;
        totalWidth += radius;
    }
    
    // Add back one of the cut-off sides
    if (maxSegment == self.segmentCount) {
        totalWidth += radius;
    }

    return totalWidth;
}

- (void)setupLabels {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x303AA0);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];

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
    NSUInteger i = 0, count = [self segmentCount];
    while (i < count) {
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
        [self setSelectedSegment:highlightedSegment];
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
