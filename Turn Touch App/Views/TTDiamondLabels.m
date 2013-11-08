//
//  TTDiamondLabels.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/7/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamondLabels.h"

@implementation TTDiamondLabels

- (id)initWithFrame:(NSRect)frame diamondRect:(NSRect)theDiamondRect {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        diamondRect = theDiamondRect;
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
    if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	return;
    CGFloat lineSize = 8.0f;
    CGFloat offsetX = NSMinX(diamondRect);
    CGFloat offsetY = NSMaxY(self.frame) - NSMaxY(diamondRect);
    CGFloat width = NSWidth(diamondRect);
    CGFloat height = NSHeight(diamondRect);
    
    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSBezierPath *line = [NSBezierPath bezierPath];
        
        if (direction == NORTH) {
            [line moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + height - lineSize)];
            [line lineToPoint:NSMakePoint(offsetX + width / 2, offsetY + height + lineSize)];
        } else if (direction == EAST) {
            [line moveToPoint:NSMakePoint(offsetX + width - lineSize*2, offsetY + height * 1/2)];
            [line lineToPoint:NSMakePoint(offsetX + width + lineSize, offsetY + height * 1/2)];
        } else if (direction == WEST) {
            [line moveToPoint:NSMakePoint(offsetX + lineSize*2, offsetY + height * 1/2)];
            [line lineToPoint:NSMakePoint(offsetX - lineSize, offsetY + height * 1/2)];
        } else if (direction == SOUTH) {
            [line moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + lineSize)];
            [line lineToPoint:NSMakePoint(offsetX + width / 2, offsetY - lineSize)];
        }
        
        [line setLineWidth:12.0];
        [[NSColor whiteColor] set];
//        [line stroke];
    }

    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSBezierPath *line = [NSBezierPath bezierPath];
        
        if (direction == NORTH) {
            [line moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + height - lineSize/2)];
            [line lineToPoint:NSMakePoint(offsetX + width / 2, offsetY + height + lineSize*2)];
        } else if (direction == EAST) {
            [line moveToPoint:NSMakePoint(offsetX + width - lineSize, offsetY + height * 1/2)];
            [line lineToPoint:NSMakePoint(offsetX + width + lineSize*1.5, offsetY + height * 1/2)];
        } else if (direction == WEST) {
            [line moveToPoint:NSMakePoint(offsetX - lineSize*1.5, offsetY + height * 1/2)];
            [line lineToPoint:NSMakePoint(offsetX + lineSize, offsetY + height * 1/2)];
        } else if (direction == SOUTH) {
            [line moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + lineSize/2)];
            [line lineToPoint:NSMakePoint(offsetX + width / 2, offsetY - lineSize * 2)];
        }
        
        [line setLineWidth:1.0];
        [[NSColor colorWithCalibratedRed:(22.0/255.0f) green:(39.0/255.0f) blue:(32.0/255.0f) alpha:0.15] set];
        [line stroke];
    }
}


@end
