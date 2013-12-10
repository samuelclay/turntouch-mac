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

@implementation TTDiamondLabels

- (id)initWithFrame:(NSRect)frame diamondRect:(NSRect)theDiamondRect {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        diamondRect = theDiamondRect;
        appDelegate = [NSApp delegate];
        
        [self setupMode];
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

- (void)setupMode {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Futura" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];

    CGFloat backingScaleFactor = [self.window backingScaleFactor];
    CGFloat offsetX = NSMinX(diamondRect);
    CGFloat offsetY = NSMaxY(self.frame) - NSMaxY(diamondRect);
    CGFloat width = NSWidth(diamondRect);
    CGFloat height = NSHeight(diamondRect);
    
    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSBezierPath *line = [NSBezierPath bezierPath];
        
        if (direction == NORTH) {
            [line moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + height - LINE_SIZE)];
            [line lineToPoint:NSMakePoint(offsetX + width / 2, offsetY + height + LINE_SIZE)];
        } else if (direction == EAST) {
            [line moveToPoint:NSMakePoint(offsetX + width - LINE_SIZE*2, offsetY + height * 1/2)];
            [line lineToPoint:NSMakePoint(offsetX + width + LINE_SIZE, offsetY + height * 1/2)];
        } else if (direction == WEST) {
            [line moveToPoint:NSMakePoint(offsetX + LINE_SIZE*2, offsetY + height * 1/2)];
            [line lineToPoint:NSMakePoint(offsetX - LINE_SIZE, offsetY + height * 1/2)];
        } else if (direction == SOUTH) {
            [line moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + LINE_SIZE)];
            [line lineToPoint:NSMakePoint(offsetX + width / 2, offsetY - LINE_SIZE)];
        }
        
        [line setLineWidth:12.0];
//        [[NSColor whiteColor] set];
//        [line stroke];
    }

    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSBezierPath *line = [NSBezierPath bezierPath];
        
        if (direction == NORTH) {
            [line moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + height - 0*LINE_SIZE/2)];
            [line lineToPoint:NSMakePoint(offsetX + width / 2, offsetY + height + LINE_SIZE*2)];
        } else if (direction == EAST) {
            [line moveToPoint:NSMakePoint(offsetX + width - 0*LINE_SIZE, offsetY + height * 1/2)];
            [line lineToPoint:NSMakePoint(offsetX + width + LINE_SIZE*2, offsetY + height * 1/2)];
        } else if (direction == WEST) {
            [line moveToPoint:NSMakePoint(offsetX - LINE_SIZE*2, offsetY + height * 1/2)];
            [line lineToPoint:NSMakePoint(offsetX + 0*LINE_SIZE, offsetY + height * 1/2)];
        } else if (direction == SOUTH) {
            [line moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + 0*LINE_SIZE/2)];
            [line lineToPoint:NSMakePoint(offsetX + width / 2, offsetY - LINE_SIZE * 2)];
        }
        
        [line setLineWidth:1.0];
        [[NSColor colorWithCalibratedHue:0.55f saturation:0.5f brightness:0.2f
                                   alpha:appDelegate.diamond.activeModeDirection == direction ? 0.5f :INACTIVE_OPACITY] set];
        [line stroke];
    }
    
    CGFloat frameWidth = NSWidth(self.frame);
    CGFloat frameHeight = NSHeight(self.frame);
    CGFloat topWidth = 100;
    CGFloat sideWidth = 80;
    CGFloat labelHeight = 24;
    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSString *label;
        NSRect textRect;
        
        if (direction == NORTH) {
            textRect = NSMakeRect(frameWidth/2 - topWidth/2,
                                  frameHeight - labelHeight*2,
                                  topWidth, labelHeight);
            label = [appDelegate.diamond.selectedMode titleNorth];
        } else if (direction == EAST) {
            textRect = NSMakeRect(frameWidth - sideWidth, frameHeight/2 - labelHeight/2,
                                  sideWidth, labelHeight);
            label = [appDelegate.diamond.selectedMode titleEast];
        } else if (direction == WEST) {
            textRect = NSMakeRect(0, frameHeight/2 - labelHeight/2,
                                  sideWidth, labelHeight);
            label = [appDelegate.diamond.selectedMode titleWest];
        } else if (direction == SOUTH) {
            textRect = NSMakeRect(frameWidth/2 - topWidth/2,
                                  labelHeight,
                                  topWidth, labelHeight);
            label = [appDelegate.diamond.selectedMode titleSouth];
        }
        
        NSSize textSize = [label sizeWithAttributes:labelAttributes];
        [label drawInRect:textRect withAttributes:labelAttributes];
    }
}


@end
