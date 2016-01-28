//
//  TTModeHUDView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeHUDView.h"
#import <CoreImage/CoreImage.h>

@implementation TTModeHUDView

const NSInteger kSizeMultiplier = 16;
const CGFloat kPaddingPct = .75f;

@synthesize isTeaser;
@synthesize gradientView;
@synthesize teaserGradientView;
@synthesize modeAttributes;
@synthesize titleMode;
@synthesize inactiveModeAttributes;

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    diamondLabels = [[TTDiamondLabels alloc] initWithInteractive:NO isHud:YES];
    isTeaser = NO;
    teaserGradientView = [[NSImageView alloc] init];
    gradientView = [[NSImageView alloc] init];
    labelsView = [[TTModeHUDLabelsView alloc] initWithHUDView:self];
    
    visualEffectView = [[NSVisualEffectView alloc] init];
    visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    visualEffectView.material = NSVisualEffectMaterialDark;
    visualEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    visualEffectView.state = NSVisualEffectStateActive;
    [visualEffectView setWantsLayer:YES];
    
    [self addSubview:visualEffectView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];

    [self drawMapBackground];
    [self addSubview:teaserGradientView];
    [self addSubview:gradientView];
    [self addSubview:diamondLabels];
    [self addSubview:labelsView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:labelsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:labelsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:labelsView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:labelsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
}

#pragma mark - Constants

- (CGFloat)hudRadius {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    
    return NSWidth(screen.frame)/84.f;
}

- (CGFloat)hudImageMargin {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    
    return NSWidth(screen.frame)/128.f;
}

- (CGFloat)hudImageTextMargin {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    
    return NSWidth(screen.frame)/384.f;
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
//    NSRect mapFrame = [self mapFrame];
//    NSLog(@"Draw mode: %d / %@", isTeaser, NSStringFromRect(mapFrame));
    
    [self drawMap];
    
    [labelsView setNeedsDisplay:YES];
    [diamondLabels setNeedsDisplay:YES];
}

- (NSRect)mapFrame:(BOOL)rotated {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    CGFloat widthPadding = (screen.frame.size.width * kPaddingPct) / 2;
    CGFloat width = screen.frame.size.width - widthPadding*2;
    CGFloat height = width;
    CGFloat actionHeight = NSHeight(screen.frame) / 3;
    CGFloat heightPadding = (NSHeight(screen.frame) - height + actionHeight) / 2;
    
    if (rotated) {
        return NSMakeRect(widthPadding + width/1.414/2/2, heightPadding + height/1.414/2/2, width/1.414, height/1.414);
    } else {
        return NSMakeRect(widthPadding, heightPadding, width, height);
    }
}

- (void)drawMapBackground {
    NSRect mapFrame = [self mapFrame:NO];
    [gradientView setFrame:mapFrame];
    [teaserGradientView setFrame:mapFrame];
    NSRect diamondFrame = mapFrame;
    diamondFrame.origin = CGPointZero;
    
    NSBezierPath *diamond = [NSBezierPath bezierPathWithRoundedRect:diamondFrame
                                                            xRadius:self.hudRadius
                                                            yRadius:self.hudRadius];
    
    NSBezierPath *diamondBorder1 = [NSBezierPath bezierPath];
    [diamondBorder1 moveToPoint:NSMakePoint(0, diamondFrame.size.height/2)];
    [diamondBorder1 lineToPoint:NSMakePoint(diamondFrame.size.width, diamondFrame.size.height/2)];
    [diamondBorder1 setLineWidth:1.f];
    
    NSBezierPath *diamondBorder2 = [NSBezierPath bezierPath];
    [diamondBorder2 moveToPoint:NSMakePoint(diamondFrame.size.width/2, 0)];
    [diamondBorder2 lineToPoint:NSMakePoint(diamondFrame.size.width/2, diamondFrame.size.height)];
    [diamondBorder2 setLineWidth:1.f];
    
    NSAffineTransform *rotation = [NSAffineTransform transform];
    [rotation translateXBy:diamondFrame.size.width/2 yBy:0];
    [rotation rotateByDegrees:45.f];
    [rotation scaleBy:1/1.414f];
    [diamond transformUsingAffineTransform:rotation];
    [diamondBorder1 transformUsingAffineTransform:rotation];
    [diamondBorder2 transformUsingAffineTransform:rotation];
    
    NSColor *diamondColor = NSColorFromRGB(0xF1F1F2);
    NSColor *borderColor = NSColorFromRGB(0x57585F);
    CGFloat alpha = 0.6f;
    NSColor *teaserDiamondColor = NSColorFromRGBAlpha(0xF1F1F2, alpha);
    NSColor *teaserBorderColor = NSColorFromRGBAlpha(0x57585F, alpha);

    NSImage *teaserGradientImage = [[NSImage alloc] initWithSize:mapFrame.size];
    [teaserGradientImage lockFocus];
    [teaserDiamondColor set];
    [diamond fill];
    [teaserBorderColor set];
    [diamondBorder1 stroke];
    [diamondBorder2 stroke];
    [teaserGradientImage unlockFocus];
    [teaserGradientView setImage:teaserGradientImage];

    NSImage *gradientImage = [[NSImage alloc] initWithSize:mapFrame.size];
    [gradientImage lockFocus];
    [diamondColor set];
    [diamond fill];
    [borderColor set];
    [diamondBorder1 stroke];
    [diamondBorder2 stroke];
    [gradientImage unlockFocus];
    [gradientView setImage:gradientImage];
}

- (void)drawMap {
    [diamondLabels setMode:titleMode];
    NSRect mapFrame = [self mapFrame:NO];
    [diamondLabels setFrame:mapFrame];
    
    
    // Debug for map frame
//    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRect:mapFrame];
//    [textViewSurround setLineWidth:10];
//    [[NSColor redColor] set];
//    [textViewSurround stroke];
}

- (void)setupTitleAttributes {
    [self setupTitleAttributes:appDelegate.modeMap.selectedMode];
}

- (void)setupTitleAttributes:(TTMode *)mode {
    NSRect mapFrame = [self mapFrame:NO];
    NSInteger fontSize = round(CGRectGetHeight(mapFrame) / kSizeMultiplier);
    titleMode = mode;
    modeTitle = [[titleMode class] title];
    NSColor *textColor = NSColorFromRGB(0x57585F);
    CGFloat alpha = 0.99f;

    NSColor *inactiveTextColor = NSColorFromRGBAlpha(0x57585F, alpha);
    modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:fontSize],
                       NSForegroundColorAttributeName: textColor
                       };
    inactiveModeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:fontSize],
                               NSForegroundColorAttributeName: inactiveTextColor
                               };
    textSize = [modeTitle sizeWithAttributes:modeAttributes];
}

@end
