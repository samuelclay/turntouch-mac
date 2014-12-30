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
const NSInteger kImageMargin = 32;
const NSInteger kImageSize = 36;
const NSInteger kImageTextMargin = 24;

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    diamondLabels = [[TTDiamondLabels alloc] initWithInteractive:NO];
    [self addSubview:diamondLabels];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self drawMapBackground];
    [self drawLabelBackground];
    [self drawLabel];
    [self drawMap];
}

- (void)drawMapBackground {
    NSRect mapFrame = [self mapFrame];
    NSBezierPath *ellipse = [NSBezierPath bezierPath];
    [ellipse moveToPoint:NSMakePoint(mapFrame.origin.x,
                                     mapFrame.size.height/2 + mapFrame.origin.y)];
    [ellipse lineToPoint:NSMakePoint(mapFrame.size.width/2 + mapFrame.origin.x,
                                     mapFrame.size.height + mapFrame.origin.y)];
    [ellipse lineToPoint:NSMakePoint(mapFrame.size.width + mapFrame.origin.x,
                                     mapFrame.size.height/2 + mapFrame.origin.y)];
    [ellipse lineToPoint:NSMakePoint(mapFrame.size.width/2 + mapFrame.origin.x, mapFrame.origin.y)];
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

- (NSRect)mapFrame {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    CGFloat widthPadding = (screen.frame.size.width * kPaddingPct) / 2;
    CGFloat width = screen.frame.size.width - widthPadding*2;
    CGFloat height = width / 1.3;
    CGFloat heightPadding = (screen.frame.size.height - height) / 2 - 100;

    return NSMakeRect(widthPadding, heightPadding, width, height);
}

- (NSRect)labelFrame {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSRect mapFrame = [self mapFrame];
    NSSize titleSize = [modeTitle sizeWithAttributes:modeAttributes];
    CGFloat width = titleSize.width + kImageSize + kImageMargin*2 + kImageTextMargin;
    CGFloat height = titleSize.height * 2;

    return NSMakeRect((CGRectGetWidth(screen.frame) - width)/2,
                      mapFrame.origin.y + mapFrame.size.height + 60,
                      width,
                      titleSize.height + kImageMargin/2);
}

- (void)drawLabel {
    NSRect frame = [self labelFrame];
    modeImage = [NSImage imageNamed:[[appDelegate.modeMap.selectedMode class] imageName]];
    [modeImage setSize:NSMakeSize(kImageSize, kImageSize)];
    CGFloat offset = (NSHeight(frame)/2) - (modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(frame.origin.x + kImageMargin, frame.origin.y + offset);
    [modeImage drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                     modeImage.size.width, modeImage.size.height)];
    
    NSSize titleSize = [modeTitle sizeWithAttributes:modeAttributes];
    NSPoint titlePoint = NSMakePoint(imagePoint.x + modeImage.size.width + kImageTextMargin,
                                     frame.origin.y + titleSize.height/2 - kImageMargin/2 - 8);
    [modeTitle drawAtPoint:titlePoint withAttributes:modeAttributes];
}

- (void)drawMap {
    [diamondLabels setFrame:[self mapFrame]];
}

- (void)setupTitleAttributes {
    modeTitle = [[appDelegate.modeMap.selectedMode class] title];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:52],
                       NSForegroundColorAttributeName: textColor,
                       NSShadowAttributeName: stringShadow
                       };
    textSize = [modeTitle sizeWithAttributes:modeAttributes];
}

@end
