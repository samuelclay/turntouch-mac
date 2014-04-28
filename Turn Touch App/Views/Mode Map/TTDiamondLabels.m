//
//  TTDiamondLabels.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/7/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamondLabels.h"
#import "TTDiamondView.h"

#define LINE_SIZE 6.0f
#define MARGIN 0.0f

@implementation TTDiamondLabels

- (id)initWithFrame:(NSRect)frame diamondRect:(NSRect)theDiamondRect {
    self = [super initWithFrame:frame];
    if (self) {
        diamondRect = theDiamondRect;
        appDelegate = [NSApp delegate];
        
        [self registerAsObserver];
        
        CGFloat offsetX = NSMinX(diamondRect);
        CGFloat offsetY = NSMaxY(self.frame) - NSMaxY(diamondRect);
        CGFloat width = NSWidth(diamondRect);
        CGFloat height = NSHeight(diamondRect);
        
        for (TTModeDirection direction=1; direction <= 4; direction++) {
            if (direction == NORTH) {
                northLine = [NSBezierPath bezierPath];
                [northLine moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + height - 0*LINE_SIZE/2)];
                [northLine lineToPoint:NSMakePoint(offsetX + width / 2, offsetY + height + LINE_SIZE*2)];
            } else if (direction == EAST) {
                eastLine = [NSBezierPath bezierPath];
                [eastLine moveToPoint:NSMakePoint(offsetX + width - 0*LINE_SIZE, offsetY + height * 1/2)];
                [eastLine lineToPoint:NSMakePoint(offsetX + width + LINE_SIZE*2, offsetY + height * 1/2)];
            } else if (direction == WEST) {
                westLine = [NSBezierPath bezierPath];
                [westLine moveToPoint:NSMakePoint(offsetX - LINE_SIZE*2, offsetY + height * 1/2)];
                [westLine lineToPoint:NSMakePoint(offsetX + 0*LINE_SIZE, offsetY + height * 1/2)];
            } else if (direction == SOUTH) {
                southLine = [NSBezierPath bezierPath];
                [southLine moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + 0*LINE_SIZE/2)];
                [southLine lineToPoint:NSMakePoint(offsetX + width / 2, offsetY - LINE_SIZE * 2)];
            }
        }
        
        CGFloat frameWidth = NSWidth(self.frame);
        CGFloat frameHeight = NSHeight(self.frame);
        CGFloat topWidth = 120;
        CGFloat sideWidth = frameWidth - NSMaxX(diamondRect);
        CGFloat labelHeight = 20;

        for (TTModeDirection direction=1; direction <= 4; direction++) {
            NSRect textRect;
            
            if (direction == NORTH) {
                textRect = NSMakeRect(frameWidth/2 - topWidth/2,
                                      frameHeight - labelHeight*3,
                                      topWidth, labelHeight);
                northLabel = [[TTDiamondLabel alloc] initWithFrame:textRect inDirection:NORTH];
                [self addSubview:northLabel];
            } else if (direction == EAST) {
                textRect = NSMakeRect(NSMaxX(diamondRect), frameHeight/2 - labelHeight/2,
                                      sideWidth, labelHeight);
                eastLabel = [[TTDiamondLabel alloc] initWithFrame:textRect inDirection:EAST];
                [self addSubview:eastLabel];
            } else if (direction == WEST) {
                textRect = NSMakeRect(4, frameHeight/2 - labelHeight/2,
                                      sideWidth, labelHeight);
                westLabel = [[TTDiamondLabel alloc] initWithFrame:textRect inDirection:WEST];
                [self addSubview:westLabel];
            } else if (direction == SOUTH) {
                textRect = NSMakeRect(frameWidth/2 - topWidth/2,
                                      labelHeight * 2,
                                      topWidth, labelHeight);
                southLabel = [[TTDiamondLabel alloc] initWithFrame:textRect inDirection:SOUTH];
                [self addSubview:southLabel];
            }
        }

    }
    
    return self;
}

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {    
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
//    NSLog(@"Drawing labels: %@", NSStringFromRect(dirtyRect));
    [self drawBackground];
}


- (void)drawBackground {
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);
}

#pragma mark - Events

- (void)mouseUp:(NSEvent *)theEvent {
    
}

@end
