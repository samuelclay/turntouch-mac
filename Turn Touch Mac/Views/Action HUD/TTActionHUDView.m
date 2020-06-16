//
//  TTHUDView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTActionHUDView.h"

@interface TTActionHUDView ()

@property (nonatomic, strong) TTProgressBar *progressBar;
@property (nonatomic, strong) NSView *imageLayoutView;
@property (nonatomic, strong) NSImageView *backgroundView;
@property (nonatomic, strong) NSImageView *iconView;
@property (nonatomic, strong) NSImageView *northChevron;
@property (nonatomic, strong) NSImageView *eastChevron;
@property (nonatomic, strong) NSImageView *westChevron;
@property (nonatomic, strong) NSImageView *southChevron;

@end

@implementation TTActionHUDView

- (void)awakeFromNib {
    NSRect actionFrame = [self.class actionFrame];

    self.appDelegate = (TTAppDelegate *)[NSApp delegate];
    self.backgroundView = [[NSImageView alloc] initWithFrame:actionFrame];
    self.progressBar = [[TTProgressBar alloc] init];
    self.iconView = [[NSImageView alloc] initWithFrame:actionFrame];
    self.northChevron = [[NSImageView alloc] initWithFrame:[self frameForChevron:actionFrame inDirection:NORTH]];
    self.eastChevron = [[NSImageView alloc] initWithFrame:[self frameForChevron:actionFrame inDirection:EAST]];
    self.westChevron = [[NSImageView alloc] initWithFrame:[self frameForChevron:actionFrame inDirection:WEST]];
    self.southChevron = [[NSImageView alloc] initWithFrame:[self frameForChevron:actionFrame inDirection:SOUTH]];
    
    [self.northChevron setImage:[self chevronForDirection:NORTH]];
    [self.eastChevron setImage:[self chevronForDirection:EAST]];
    [self.westChevron setImage:[self chevronForDirection:WEST]];
    [self.southChevron setImage:[self chevronForDirection:SOUTH]];

    [self addSubview:self.backgroundView];
    [self addSubview:self.progressBar];
    [self addSubview:self.iconView];
    [self addSubview:self.northChevron];
    [self addSubview:self.eastChevron];
    [self addSubview:self.westChevron];
    [self addSubview:self.southChevron];
}

#pragma mark - Constants

- (CGFloat)hudRadius {
    return 30;
}

- (CGFloat)hudChevronSize {
    return 40;
}

- (CGFloat)hudIconSize {
    return 80;
}

- (CGFloat)hudModeTitleSize {
    return 26;
}

- (CGFloat)hudActionTitleSize {
    return 21;
}

#pragma mark - Drawing

+ (NSRect)actionFrame {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    CGFloat width = 320;
    CGFloat height = width;
    
    CGFloat widthPadding = NSWidth(screen.frame) / 2 - width / 2;
    CGFloat heightPadding = NSHeight(screen.frame) / 10;
    
    return NSMakeRect(widthPadding, heightPadding, width, height);
}

- (NSRect)frameForChevron:(NSRect)actionFrame inDirection:(TTModeDirection)_direction {
    if (_direction == NORTH) {
        NSRect horizontalRect = NSInsetRect(actionFrame, NSWidth(actionFrame)/2-self.hudChevronSize/2, 0);
        NSRect verticalRect = horizontalRect;
        verticalRect.origin.y += NSHeight(verticalRect)/2 - 36 - 12;
        return verticalRect;
    } else if (_direction == SOUTH) {
        NSRect horizontalRect = NSInsetRect(actionFrame, NSWidth(actionFrame)/2-self.hudChevronSize/2, 0);
        NSRect verticalRect = horizontalRect;
        verticalRect.origin.y -= NSHeight(verticalRect)/2 - 36 - 12;
        return verticalRect;
    } else if (_direction == EAST) {
        NSRect verticalRect = NSInsetRect(actionFrame, 0, NSHeight(actionFrame)/2-self.hudChevronSize/2);
        NSRect horizontalRect = verticalRect;
        horizontalRect.origin.x += NSWidth(verticalRect)/2 - 36 - 12;
        return horizontalRect;
    } else if (_direction == WEST) {
        NSRect verticalRect = NSInsetRect(actionFrame, 0, NSHeight(actionFrame)/2-self.hudChevronSize/2);
        NSRect horizontalRect = verticalRect;
        horizontalRect.origin.x -= NSWidth(verticalRect)/2 - 36 - 12;
        return horizontalRect;
    }
    
    return actionFrame;
}

- (void)drawProgressBar:(TTProgressBar *)_progressBar {
    ActionLayout layout = [self.mode layoutForAction:self.actionName];
    if (layout == ACTION_LAYOUT_TITLE || layout == ACTION_LAYOUT_IMAGE_TITLE) {
        self.progressBar.hidden = YES;
        return;
    } else if (layout == ACTION_LAYOUT_PROGRESSBAR) {
        self.progressBar.hidden = NO;
    }

    NSInteger progress = [self.mode progressForAction:self.actionName];

    if (progress == -1) {
        self.progressBar.hidden = YES;
    } else {
        self.progressBar.hidden = NO;
        [self.progressBar setProgress:progress];
    }
    
    NSRect actionFrame = [self.class actionFrame];
    NSRect frame = NSInsetRect(actionFrame, 100, 0);
    frame.size.height = 8;
    frame.origin.y = frame.origin.y + NSHeight(actionFrame) * 0.3f - NSHeight(frame);
    [self.progressBar setFrame:frame];
}

- (void)drawImageLayoutView {
    ActionLayout layout = [self.mode layoutForAction:self.actionName];
    [self.imageLayoutView removeFromSuperview];
    if (layout == ACTION_LAYOUT_TITLE || layout == ACTION_LAYOUT_PROGRESSBAR) {
        [self.imageLayoutView setHidden:YES];
    } else if (layout == ACTION_LAYOUT_IMAGE_TITLE) {
        NSRect frame = [self.class actionFrame];
        self.imageLayoutView = [self.mode viewForLayoutOfAction:self.actionName withRect:frame];
        [self addSubview:self.imageLayoutView];
        [self.imageLayoutView setHidden:NO];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    ActionLayout layout = [self.mode layoutForAction:self.actionName];

    [self drawBackground];
    [self drawIcon];
    [self drawChevron];
    if (layout == ACTION_LAYOUT_TITLE) {
        [self drawModeLabel];
        [self drawActionLabel];
    } else if (layout == ACTION_LAYOUT_IMAGE_TITLE) {
        [self drawModeLabel];
        [self drawActionLabel];
        [self.imageLayoutView setHidden:NO];
        [self drawActionLayoutImageTitleBackground];
    } else if (layout == ACTION_LAYOUT_PROGRESSBAR) {
        [self drawModeLabel];
        [self drawProgress];
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
    [self.backgroundView setImage:backgroundImage];

    // Used to debug label frame
//    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRect:frame];
//    [textViewSurround setLineWidth:1];
//    [[NSColor redColor] set];
//    [textViewSurround stroke];
}

- (void)drawIcon {
    NSString *iconFilename = [self.mode imageNameForActionHudInDirection:self.actionName];
    NSImage *icon = [NSImage imageNamed:iconFilename];
    [icon setSize:NSMakeSize(self.hudIconSize, self.hudIconSize)];
    [self.iconView setImage:icon];
}

- (void)drawChevron {
    [self.northChevron setHidden:YES];
    [self.eastChevron setHidden:YES];
    [self.westChevron setHidden:YES];
    [self.southChevron setHidden:YES];

    if (self.direction == NORTH) [self.northChevron setHidden:NO];
    if (self.direction == EAST) [self.eastChevron setHidden:NO];
    if (self.direction == WEST) [self.westChevron setHidden:NO];
    if (self.direction == SOUTH) [self.southChevron setHidden:NO];
}

- (NSImage *)chevronForDirection:(TTModeDirection)_direction {
    NSString *directionName = [self.appDelegate.modeMap directionName:_direction];
    NSString *imageFile = [NSString stringWithFormat:@"chevron_%@.png", directionName];
    NSImage *icon = [NSImage imageNamed:imageFile];

    return icon;
}

#pragma mark - Action Layout - Text / Progress

- (void)drawModeLabel {
    NSRect frame = [self.class actionFrame];
    NSColor *textColor = NSColorFromRGB(0x57585F);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:self.hudModeTitleSize],
                                      NSForegroundColorAttributeName: textColor,
                                      NSParagraphStyleAttributeName: style
                                      };
    NSString *modeLabel = [[self.mode class] title];
    frame.size.height = frame.size.height * (0.7f) + [modeLabel sizeWithAttributes:labelAttributes].height/2;
    [self.backgroundView.image lockFocus];
    frame.origin = NSZeroPoint;
    [modeLabel drawInRect:frame withAttributes:labelAttributes];
    [self.backgroundView.image unlockFocus];
}

- (void)drawActionLabel {
    NSRect frame = [self.class actionFrame];
    //    NSShadow *stringShadow = [[NSShadow alloc] init];
    //    stringShadow.shadowColor = [NSColor whiteColor];
    //    stringShadow.shadowOffset = NSMakeSize(0, -1);
    //    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x57585F);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:self.hudActionTitleSize],
                                      NSForegroundColorAttributeName: textColor,
                                      //                                      NSShadowAttributeName: stringShadow,
                                      NSParagraphStyleAttributeName: style
                                      };
    NSString *directionLabel = [self.mode actionTitleInDirection:self.direction buttonMoment:self.buttonMoment];
    frame.size.height = frame.size.height * (0.3f) + [directionLabel sizeWithAttributes:labelAttributes].height/2;
    [self.backgroundView.image lockFocus];
    frame.origin = NSZeroPoint;
    [directionLabel drawInRect:frame withAttributes:labelAttributes];
    [self.backgroundView.image unlockFocus];
}

- (void)drawProgress {
    NSInteger progress = [self.mode progressForAction:self.actionName];
    if (progress == -1) return;
    
    [self.progressBar setProgress:progress];
}

#pragma mark - Action Layout - Image

- (void)drawActionLayoutImageTitleBackground {
    NSBezierPath *ellipse = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.imageLayoutView.frame, self.hudRadius*-0.25, self.hudRadius*-0.25)
                                                            xRadius:self.hudRadius/2
                                                            yRadius:self.hudRadius/2];
    CGFloat alpha = 0.99f;
    NSColor *color = NSColorFromRGBAlpha(0xF1F1F2, alpha);
    [color setFill];
    [ellipse fill];
}


@end
