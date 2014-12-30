//
//  TTHUDView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTActionHUDView.h"

@implementation TTActionHUDView

@synthesize direction;

const CGFloat kMarginPct = .6f;

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self drawBackground];
    [self drawLabel];
}

- (NSRect)actionFrame {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    CGFloat margin = (screen.frame.size.width * kMarginPct) / 2;
    CGFloat width = screen.frame.size.width - margin*2;
    
    return NSMakeRect(margin, 0, width, 200);
}

- (void)drawBackground {
    NSRect frame = [self actionFrame];
    NSBezierPath *ellipse = [NSBezierPath bezierPath];
    [ellipse moveToPoint:NSMakePoint(frame.origin.x, frame.origin.y)];
    [ellipse lineToPoint:NSMakePoint(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height)];
    [ellipse lineToPoint:NSMakePoint(frame.origin.x + frame.size.width, frame.origin.y)];
    [ellipse closePath];
    CGFloat alpha = 0.9f;
    [NSColorFromRGBAlpha(0xC0BCCF, alpha) setStroke];
    [ellipse stroke];
    NSGradient *borderGradient = [[NSGradient alloc]
                                  initWithStartingColor:NSColorFromRGBAlpha(0xffffff, alpha)
                                  endingColor:NSColorFromRGB(0xa7a7a7)];
    [borderGradient drawInBezierPath:ellipse angle:-90];
}

- (void)drawLabel {
    NSRect frame = [self actionFrame];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:54],
                                      NSForegroundColorAttributeName: textColor,
                                      NSShadowAttributeName: stringShadow,
                                      NSParagraphStyleAttributeName: style
                                      };
    NSString *directionLabel = [appDelegate.modeMap.selectedMode
                                titleInDirection:direction];
    frame.size.height = frame.size.height / 2 + [directionLabel sizeWithAttributes:labelAttributes].height/2;
    [directionLabel drawInRect:frame withAttributes:labelAttributes];
}

@end
