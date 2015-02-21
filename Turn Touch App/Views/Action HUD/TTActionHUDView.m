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

- (void)drawProgressBar:(NSProgressIndicator *)_progressBar {
    NSInteger progress = [appDelegate.modeMap.selectedMode progressInDirection:direction];
    progressBar = _progressBar;
    if (progress == -1) {
        progressBar.hidden = YES;
    } else {
        progressBar.hidden = NO;
        [progressBar setDoubleValue:progress];
    }

//    NSRect frame = [self actionFrame];
//    [progressBar setFrame:NSInsetRect(frame, 100, 0)];
}

- (void)drawImageLayoutView {
    ActionLayout layout = [appDelegate.modeMap.selectedMode layoutInDirection:direction];
    [imageLayoutView removeFromSuperview];
    if (layout == ACTION_LAYOUT_TITLE) {
        [imageLayoutView setHidden:YES];
    } else if (layout == ACTION_LAYOUT_IMAGE_TITLE) {
        NSRect frame = [self actionFrame];
        imageLayoutView = [appDelegate.modeMap.selectedMode viewForLayout:direction withRect:frame];
        [self addSubview:imageLayoutView];
        [imageLayoutView setHidden:NO];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    ActionLayout layout = [appDelegate.modeMap.selectedMode layoutInDirection:direction];
    
    [self drawBackground];
    if (layout == ACTION_LAYOUT_TITLE) {
        [self drawLabel];
        [self drawProgress];
    } else if (layout == ACTION_LAYOUT_IMAGE_TITLE) {
        [self drawSmallLabel];
        [imageLayoutView setHidden:NO];
    }
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

#pragma mark - Action Layout - Text / Progress

- (void)drawLabel {
    NSRect frame = [self actionFrame];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:52],
                                      NSForegroundColorAttributeName: textColor,
                                      NSShadowAttributeName: stringShadow,
                                      NSParagraphStyleAttributeName: style
                                      };
    NSString *directionLabel = [appDelegate.modeMap.selectedMode
                                actionTitleInDirection:direction];
    frame.size.height = frame.size.height / 2 + [directionLabel sizeWithAttributes:labelAttributes].height/2;
    [directionLabel drawInRect:frame withAttributes:labelAttributes];
}

- (void)drawProgress {
    NSInteger progress = [appDelegate.modeMap.selectedMode progressInDirection:direction];
    if (progress == -1) return;
    
    [progressBar setDoubleValue:progress];    
}

#pragma mark - Action Layout - Image

- (void)drawSmallLabel {
    NSRect frame = [self actionFrame];
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
    NSString *directionLabel = [appDelegate.modeMap.selectedMode
                                actionTitleInDirection:direction];
    frame.size.height = frame.size.height * 0.7 + [directionLabel sizeWithAttributes:labelAttributes].height/2;
    [directionLabel drawInRect:frame withAttributes:labelAttributes];
}

@end
