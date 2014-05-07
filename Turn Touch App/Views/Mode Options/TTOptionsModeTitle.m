//
//  TTModeOptionsTitle.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTOptionsModeTitle.h"

#define X_MARGIN 12.0f
#define Y_MARGIN 18.0f

@implementation TTOptionsModeTitle

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];

        [self setupLabels];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
    NSString *modeTitle = [[appDelegate.modeMap.selectedMode class] title];
    NSString *modeDescription = @"Options";
    
    NSSize titleSize = [modeTitle sizeWithAttributes:titleAttributes];
    NSSize descriptonSize = [modeDescription sizeWithAttributes:descriptionAttributes];

    NSPoint titlePoint = NSMakePoint(X_MARGIN,
                                     NSHeight(self.frame) - Y_MARGIN - floor(titleSize.height/2) + 1);
    NSPoint descriptionPoint = NSMakePoint(NSMaxX(self.frame) - descriptonSize.width - X_MARGIN,
                                           NSHeight(self.frame) - Y_MARGIN - floor(descriptonSize.height/2) + 1);
    
    [modeTitle drawAtPoint:titlePoint withAttributes:titleAttributes];
    [modeDescription drawAtPoint:descriptionPoint withAttributes:descriptionAttributes];
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(titlePoint.x + titleSize.width + X_MARGIN,
                                  titlePoint.y + titleSize.height/2 - 2)];
    [line lineToPoint:NSMakePoint(descriptionPoint.x - X_MARGIN,
                                  titlePoint.y + titleSize.height/2 - 2)];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];

}

- (void)setupLabels {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    titleAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Futura" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };

    NSColor *descriptionColor = NSColorFromRGB(0x606A80);
    descriptionAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Futura" size:13],
                              NSForegroundColorAttributeName: descriptionColor,
                              NSShadowAttributeName: stringShadow,
                              NSParagraphStyleAttributeName: style
                              };
}

@end
