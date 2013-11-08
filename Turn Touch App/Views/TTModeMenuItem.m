//
//  TTModeMenuItem.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMenuItem.h"

#define DIAMOND_SIZE 18.0f

@implementation TTModeMenuItem

- (id)initWithFrame:(NSRect)frame direction:(TTModeDirection)direction {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        modeDirection = direction;
        CGRect diamondRect = NSMakeRect(NSWidth(frame) - 24 - DIAMOND_SIZE,
                                        NSHeight(frame) / 2 - (DIAMOND_SIZE / 2),
                                        DIAMOND_SIZE * 1.3, DIAMOND_SIZE);
        diamondView = [[TTDiamondView alloc] initWithFrame:diamondRect direction:modeDirection];
        [self addSubview:diamondView];
        switch (modeDirection) {
            case NORTH:
                itemMode = appDelegate.diamond.northMode;
                break;
            case EAST:
                itemMode = appDelegate.diamond.eastMode;
                break;
            case WEST:
                itemMode = appDelegate.diamond.westMode;
                break;
            case SOUTH:
                itemMode = appDelegate.diamond.southMode;
                break;
        }
        
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
        if (appDelegate.diamond.selectedModeDirection == modeDirection) {
            [self setNeedsDisplay:YES];
        }
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        if (appDelegate.diamond.selectedModeDirection == modeDirection) {
            [self setNeedsDisplay:YES];
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    NSString *modeTitle = [[NSString stringWithFormat:@"%@ mode",
                            [itemMode title]] uppercaseString];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = appDelegate.diamond.selectedModeDirection == modeDirection ?
                         NSColorFromRGB(0x404A60) : NSColorFromRGB(0x808388);
    NSDictionary *textAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Futura" size:13],
                                     NSForegroundColorAttributeName: textColor,
                                     NSShadowAttributeName: stringShadow
                                     };
    CGSize textSize = [modeTitle sizeWithAttributes:textAttributes];
    NSPoint point = NSMakePoint(12, NSHeight(self.frame) / 2 - ceil(textSize.height / 2) - 1);
    [modeTitle drawAtPoint:point withAttributes:textAttributes];
}

@end
