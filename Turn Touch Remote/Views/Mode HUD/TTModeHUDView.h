//
//  TTHUDView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTDiamondLabels.h"
#import "TTDiamondView.h"
#import "TTModeHUDLabelsView.h"
#import "TTHUDMenuViewController.h"

@class TTModeHUDLabelsView;

@interface TTModeHUDView : NSView <TTHUDMenuDelegate> {
    TTAppDelegate *appDelegate;
    NSImage *modeImage;
    NSString *modeTitle;
    CGSize textSize;
    TTDiamondLabels *diamondLabels;
    TTModeHUDLabelsView *labelsView;
    NSImageView *gradientView;
    BOOL teaserFadeStarted;
    NSVisualEffectView *visualEffectView;
}

@property (nonatomic, readwrite) BOOL isTeaser;
@property (nonatomic, readwrite) NSImageView *gradientView;
@property (nonatomic, readwrite) NSImageView *teaserGradientView;
@property (nonatomic) NSDictionary *modeAttributes;
@property (nonatomic) TTMode *titleMode;
@property (nonatomic) NSDictionary *inactiveModeAttributes;

- (void)setupTitleAttributes;
- (void)setupTitleAttributes:(TTMode *)mode;
- (void)drawMapBackground;
- (CGFloat)hudRadius;
- (CGFloat)hudImageMargin;
- (CGFloat)hudImageTextMargin;
- (NSRect)mapFrame:(BOOL)rotated;

@end
