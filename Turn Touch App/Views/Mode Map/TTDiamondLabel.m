//
//  TTDiamondLabel.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamondLabel.h"

#define PADDING 24

@implementation TTDiamondLabel

- (id)initWithFrame:(NSRect)frame inDirection:(TTModeDirection)direction {
    frame = NSInsetRect(frame, -1 * PADDING, -1 * PADDING);

    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        labelDirection = direction;
        
        [self setupLabels];
        [self createTrackingArea];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = NSInsetRect(dirtyRect, PADDING, PADDING);
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
    
    [directionLabel drawInRect:rect withAttributes:labelAttributes];
}

- (void)setupLabels {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = isHover ? NSColorFromRGB(0x707A90) : NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Futura" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };
}

#pragma mark - Events

- (void)createTrackingArea {
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    NSTrackingArea *trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options:opts
                                                                   owner:self
                                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    isHover = YES;
    [self setupLabels];
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    isHover = NO;
    [self setupLabels];
    [self setNeedsDisplay:YES];
}

@end
