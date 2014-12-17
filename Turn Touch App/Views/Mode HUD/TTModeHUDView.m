//
//  TTHUDView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeHUDView.h"

@implementation TTModeHUDView

const CGFloat kPaddingPct = .6f;

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self drawMapBackground];
    [self drawLabelBackground];
    [self drawLabel];
}

- (void)drawMapBackground {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    CGFloat widthPadding = (screen.frame.size.width * kPaddingPct) / 2;
    CGFloat heightPadding = (screen.frame.size.height * kPaddingPct) / 2;
    CGFloat width = screen.frame.size.width - widthPadding*2;
    CGFloat height = screen.frame.size.height - heightPadding*2;
    NSBezierPath *ellipse = [NSBezierPath bezierPath];
    [ellipse moveToPoint:NSMakePoint(widthPadding, height/2 + heightPadding)];
    [ellipse lineToPoint:NSMakePoint(width/2 + widthPadding, height + heightPadding)];
    [ellipse lineToPoint:NSMakePoint(width + widthPadding, height/2 + heightPadding)];
    [ellipse lineToPoint:NSMakePoint(width/2 + widthPadding, heightPadding)];
    [ellipse closePath];
    CGFloat alpha = 0.9f;
    [NSColorFromRGBAlpha(0xC0BCCF, alpha) setStroke];
    [ellipse stroke];
    NSGradient *borderGradient = [[NSGradient alloc]
                                  initWithStartingColor:NSColorFromRGBAlpha(0xffffff, alpha)
                                  endingColor:NSColorFromRGB(0xa7a7a7)];
    [borderGradient drawInBezierPath:ellipse angle:-90];
}

- (void)drawLabelBackground {
    NSBezierPath *ellipse = [NSBezierPath bezierPathWithRoundedRect:[self labelFrame]
                                                            xRadius:35.0
                                                            yRadius:35.0];
    CGFloat alpha = 0.9f;
    [NSColorFromRGBAlpha(0xC0BCCF, alpha) setStroke];
    [ellipse stroke];
    NSGradient *borderGradient = [[NSGradient alloc]
                                  initWithStartingColor:NSColorFromRGBAlpha(0xffffff, alpha)
                                  endingColor:NSColorFromRGB(0xa7a7a7)];
    [borderGradient drawInBezierPath:ellipse angle:-90];
}

- (NSRect)labelFrame {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    CGFloat widthPadding = (screen.frame.size.width * kPaddingPct) / 2;
    CGFloat heightPadding = (screen.frame.size.height * kPaddingPct) / 2;
    CGFloat width = screen.frame.size.width - widthPadding*2;
    CGFloat height = screen.frame.size.height - heightPadding*2;

    return NSMakeRect(widthPadding, height + heightPadding + heightPadding/4,
                      width, 75.0);
}

- (void)drawLabel {
    NSRect frame = [self labelFrame];
    modeImage = [NSImage imageNamed:[[appDelegate.modeMap.selectedMode class] imageName]];
    [modeImage setSize:NSMakeSize(36, 36)];
    CGFloat offset = (NSHeight(frame)/2) - (modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(frame.origin.x + offset, frame.origin.y + offset);
    [modeImage drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                     modeImage.size.width, modeImage.size.height)];
    
    NSSize titleSize = [modeTitle sizeWithAttributes:modeAttributes];
    NSPoint titlePoint = NSMakePoint(imagePoint.x + modeImage.size.width + 12,
                                     frame.origin.y);
    [modeTitle drawAtPoint:titlePoint withAttributes:modeAttributes];
}

- (void)setupTitleAttributes {
    modeTitle = [[appDelegate.modeMap.selectedMode class] title];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:36],
                       NSForegroundColorAttributeName: textColor,
                       NSShadowAttributeName: stringShadow
                       };
    textSize = [modeTitle sizeWithAttributes:modeAttributes];
}

@end
