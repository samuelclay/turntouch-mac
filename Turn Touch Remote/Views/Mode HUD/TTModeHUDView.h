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

@interface TTModeHUDView : NSView {
    TTAppDelegate *appDelegate;
    NSImage *modeImage;
    NSString *modeTitle;
    NSDictionary *modeAttributes;
    NSDictionary *inactiveModeAttributes;
    CGSize textSize;
    TTDiamondLabels *diamondLabels;
    TTMode *titleMode;
    NSImageView *gradientView;
    BOOL teaserFadeStarted;
}

@property (nonatomic, readwrite) BOOL isTeaser;
@property (nonatomic, readwrite) NSImageView *gradientView;
@property (nonatomic, readwrite) NSImageView *teaserGradientView;

- (void)setupTitleAttributes;
- (void)setupTitleAttributes:(TTMode *)mode;

@end
