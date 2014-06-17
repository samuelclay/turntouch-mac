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
    NSString *label = [self labelForSegment:segment];
    NSSize labelSize = [label sizeWithAttributes:labelAttributes];
    BOOL highlighted = segment == highlightedSegment;
    
    frame.origin.x = (segment * labelSize.width);
    frame.origin.y = 0;
    frame.size.width = labelSize.width;
    frame.size.height = controlView.frame.size.height;
    
    [super setWidth:labelSize.width forSegment:segment];
    
    NSBezierPath *border = [NSBezierPath bezierPath];
    
    [border moveToPoint:NSMakePoint(NSMinX(frame), NSMinY(frame) + 1)];
    [border lineToPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame) + 1)];
    [border curveToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame))
           controlPoint1:NSMakePoint(NSMaxX(frame) + NSHeight(frame)*2/3, NSMinY(frame) + 1)
           controlPoint2:NSMakePoint(NSMaxX(frame) + NSHeight(frame)*2/3, NSMaxY(frame))];
    [border lineToPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame))];
    [border closePath];
    [border setLineWidth:0.5];
    if (highlighted) {
        [NSColorFromRGB(0xFFFFFF) set];
    } else {
        [NSColorFromRGB(0xF5F6F8) set];
    }
    [border fill];
    [NSColorFromRGB(0xD0D0D0) set];
    [border stroke];

    [label drawInRect:frame withAttributes:labelAttributes];
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
    loc.x += frame.origin.x;
    loc.y += frame.origin.y;
    NSUInteger i = 0, count = [self segmentCount];
    while (i < count && frame.origin.x < controlView.frame.size.width) {
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

// TODO: fix this warning.
- (void)stopTracking:(NSPoint)lastPoint
                  at:(NSPoint)stopPoint
              inView:(NSView *)controlView
           mouseIsUp:(BOOL)flag {
    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];

    if (highlightedSegment >= 0) {
        [self setSelectedSegment:highlightedSegment];
        if ([self.target respondsToSelector:self.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.target performSelector:self.action withObject:controlView];
#pragma clang diagnostic pop
        }
    }
    
    [self setHighlightedSegment:-1];
}


@end
