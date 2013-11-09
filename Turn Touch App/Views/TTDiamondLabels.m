//
//  TTDiamondLabels.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/7/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamondLabels.h"
#import "TTDiamondView.h"

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
        [line stroke];
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
        [[NSColor colorWithCalibratedHue:0.55f saturation:0.5f brightness:0.2f
                                   alpha:appDelegate.diamond.activeModeDirection == direction ? 0.5f :INACTIVE_OPACITY] set];
        [line stroke];
    }
    
    CGFloat frameWidth = NSWidth(self.frame);
    CGFloat frameHeight = NSHeight(self.frame);
    CGFloat topWidth = 100;
    CGFloat sideWidth = 60;
    CGFloat labelHeight = 48;
    NSLog(@"Label container: %@", NSStringFromRect(self.frame));
    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSString *label;
        NSRect textRect;
        
        if (direction == NORTH) {
            textRect = NSMakeRect(frameWidth/2 - topWidth/2,
                                  frameHeight - labelHeight,
                                  topWidth, labelHeight);
            label = [appDelegate.diamond.selectedMode titleNorth];
        } else if (direction == EAST) {
            textRect = NSMakeRect(frameWidth - sideWidth, frameHeight/2,
                                  sideWidth, labelHeight);
            label = [appDelegate.diamond.selectedMode titleEast];
        } else if (direction == WEST) {
            textRect = NSMakeRect(0, frameHeight/2,
                                  sideWidth, labelHeight);
            label = [appDelegate.diamond.selectedMode titleWest];
        } else if (direction == SOUTH) {
            textRect = NSMakeRect(frameWidth/2 - topWidth/2,
                                  labelHeight*0.5,
                                  topWidth, labelHeight);
            label = [appDelegate.diamond.selectedMode titleSouth];
        }
        
        NSLog(@"Label: %@ - %@", label, NSStringFromRect(textRect));
        [label drawInRect:textRect withAttributes:labelAttributes];
    }
}


@end
