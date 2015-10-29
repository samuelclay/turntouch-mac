//
//  TTHUDView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTActionHUDView.h"

@implementation TTActionHUDView

@synthesize direction;
@synthesize mode;
@synthesize buttonAction;

const CGFloat kActionHUDMarginPct = .6f;

- (void)awakeFromNib {
    NSRect actionFrame = [self.class actionFrame];

    appDelegate = (TTAppDelegate *)[NSApp delegate];
    backgroundView = [[NSImageView alloc] initWithFrame:actionFrame];
    progressBar = [[TTProgressBar alloc] init];
    iconView = [[NSImageView alloc] initWithFrame:actionFrame];
    
    [self addSubview:backgroundView];
    [self addSubview:progressBar];
    [self addSubview:iconView];
}

+ (NSRect)actionFrame {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    CGFloat width = NSWidth(screen.frame)/8;
    CGFloat height = width;
    
    if (width < 220) {
        width = 220;
        height = 220;
    }
    
    CGFloat widthPadding = NSWidth(screen.frame) / 2 - width / 2;
    CGFloat heightPadding = 48;
    
    return NSMakeRect(widthPadding, heightPadding, width, height);
}

- (void)drawProgressBar:(NSProgressIndicator *)_progressBar {
    NSInteger progress = [mode progressInDirection:direction];

    if (progress == -1) {
        progressBar.hidden = YES;
    } else {
        progressBar.hidden = NO;
        [progressBar setProgress:progress];
    }
    
    NSRect actionFrame = [self.class actionFrame];
    NSRect frame = NSInsetRect(actionFrame, 100, 0);
    frame.size.height = 8;
    frame.origin.y = frame.origin.y + NSHeight(actionFrame) / 4;
    [progressBar setFrame:frame];
}

- (void)drawImageLayoutView {
    ActionLayout layout = [mode layoutInDirection:direction];
    [imageLayoutView removeFromSuperview];
    if (layout == ACTION_LAYOUT_TITLE) {
        [imageLayoutView setHidden:YES];
    } else if (layout == ACTION_LAYOUT_IMAGE_TITLE) {
        NSRect frame = [self.class actionFrame];
        imageLayoutView = [mode viewForLayout:direction withRect:frame];
        [self addSubview:imageLayoutView];
        [imageLayoutView setHidden:NO];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    ActionLayout layout = [mode layoutInDirection:direction];
    
    [self drawBackground];
    [self drawIcon];
    if (layout == ACTION_LAYOUT_TITLE) {
        [self drawModeLabel];
        [self drawActionLabel];
        [self drawProgress];
    } else if (layout == ACTION_LAYOUT_IMAGE_TITLE) {
        [self drawSmallLabel];
        [imageLayoutView setHidden:NO];
    }
}

- (void)drawBackground {
    NSRect diamondFrame = [self.class actionFrame];
    diamondFrame.origin = CGPointZero;

    NSBezierPath *diamond = [NSBezierPath bezierPathWithRoundedRect:diamondFrame
                                                            xRadius:36.0
                                                            yRadius:36.0];

    NSAffineTransform *rotation = [NSAffineTransform transform];
    [rotation translateXBy:diamondFrame.size.width/2 yBy:0];
    [rotation rotateByDegrees:45.f];
    [rotation scaleBy:1/1.414f];
    [diamond transformUsingAffineTransform:rotation];

    CGFloat alpha = 0.9f;
    NSColor *backgroundColor = NSColorFromRGBAlpha(0xE0E1E1, alpha);
    NSImage *backgroundImage = [[NSImage alloc] initWithSize:diamondFrame.size];
    [backgroundImage lockFocus];
    [backgroundColor set];
    [diamond fill];
    [backgroundImage unlockFocus];
    [backgroundView setImage:backgroundImage];

    // Used to debug label frame
//    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRect:frame];
//    [textViewSurround setLineWidth:1];
//    [[NSColor redColor] set];
//    [textViewSurround stroke];
}

- (void)drawIcon {
    NSString *iconFilename = [mode imageNameInDirection:direction];
    NSString *imageFile = [NSString stringWithFormat:@"%@/actions/%@", [[NSBundle mainBundle] resourcePath], iconFilename];
    NSImage *icon = [[NSImage alloc] initWithContentsOfFile:imageFile];
    [icon setSize:NSMakeSize(96, 96)];
    [iconView setImage:icon];
}

#pragma mark - Action Layout - Text / Progress

- (void)drawModeLabel {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 96);
    NSRect frame = [self.class actionFrame];
    NSColor *textColor = NSColorFromRGB(0x57585F);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:fontSize],
                                      NSForegroundColorAttributeName: textColor,
                                      NSParagraphStyleAttributeName: style
                                      };
    NSString *modeLabel = [[mode class] title];
    frame.size.height = frame.size.height * (0.7f) + [modeLabel sizeWithAttributes:labelAttributes].height/2;
    [backgroundView.image lockFocus];
    frame.origin = NSZeroPoint;
    [modeLabel drawInRect:frame withAttributes:labelAttributes];
    [backgroundView.image unlockFocus];
}

- (void)drawActionLabel {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 118);
    NSRect frame = [self.class actionFrame];
    //    NSShadow *stringShadow = [[NSShadow alloc] init];
    //    stringShadow.shadowColor = [NSColor whiteColor];
    //    stringShadow.shadowOffset = NSMakeSize(0, -1);
    //    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x57585F);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:fontSize],
                                      NSForegroundColorAttributeName: textColor,
                                      //                                      NSShadowAttributeName: stringShadow,
                                      NSParagraphStyleAttributeName: style
                                      };
    NSString *directionLabel = [mode actionTitleInDirection:direction buttonAction:buttonAction];
    frame.size.height = frame.size.height * (0.3f) + [directionLabel sizeWithAttributes:labelAttributes].height/2;
    [backgroundView.image lockFocus];
    frame.origin = NSZeroPoint;
    [directionLabel drawInRect:frame withAttributes:labelAttributes];
    [backgroundView.image unlockFocus];
}

- (void)drawProgress {
    NSInteger progress = [mode progressInDirection:direction];
    if (progress == -1) return;
    
    [progressBar setProgress:progress];
}

#pragma mark - Action Layout - Image

- (void)drawSmallLabel {
    NSRect frame = [self.class actionFrame];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:38],
                                      NSForegroundColorAttributeName: textColor,
                                      NSShadowAttributeName: stringShadow,
                                      NSParagraphStyleAttributeName: style
                                      };
    NSString *directionLabel = [mode actionTitleInDirection:direction buttonAction:buttonAction];
    frame.size.height = frame.size.height * 0.7 + [directionLabel sizeWithAttributes:labelAttributes].height/2;
    [directionLabel drawInRect:frame withAttributes:labelAttributes];
}

@end
