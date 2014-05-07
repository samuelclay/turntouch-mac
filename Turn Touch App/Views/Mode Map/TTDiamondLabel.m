//
//  TTDiamondLabel.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamondLabel.h"

#define PADDING 0

@implementation TTDiamondLabel

- (id)initWithFrame:(NSRect)frame inDirection:(TTModeDirection)direction {
    frame = NSInsetRect(frame, 0, -1 * PADDING);

    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        labelDirection = direction;
        
        [self setupLabels];
        [self registerAsObserver];
    }
    return self;
}

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"hoverModeDirection"
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
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))] ||
        [keyPath isEqual:NSStringFromSelector(@selector(hoverModeDirection))]      ||
        [keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))]     ||
        [keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]   ||
        [keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setupLabels];
        [self.superview setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
	NSString *directionLabel;

    if (labelDirection == NORTH) {
        directionLabel = [appDelegate.modeMap.selectedMode titleNorth];
    } else if (labelDirection == EAST) {
        directionLabel = [appDelegate.modeMap.selectedMode titleEast];
    } else if (labelDirection == WEST) {
        directionLabel = [appDelegate.modeMap.selectedMode titleWest];
    } else if (labelDirection == SOUTH) {
        directionLabel = [appDelegate.modeMap.selectedMode titleSouth];
    }
    
    [directionLabel drawInRect:self.bounds withAttributes:labelAttributes];
    
    
    // Draw border, used for debugging
//    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRect:self.bounds];
//    [textViewSurround setLineWidth:1];
//    [[NSColor redColor] set];
//    [textViewSurround stroke];
}

- (void)setupLabels {
    BOOL hovering = appDelegate.modeMap.hoverModeDirection == labelDirection;
    BOOL selected = appDelegate.modeMap.inspectingModeDirection == labelDirection;
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = (hovering || selected) ? NSColorFromRGB(0x303AA0) : NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Futura" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };
}

@end
