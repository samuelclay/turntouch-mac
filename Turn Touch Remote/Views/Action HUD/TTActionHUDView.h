//
//  TTHUDView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTProgressBar.h"

@class TTAppDelegate;

extern const CGFloat kActionHUDMarginPct;

@interface TTActionHUDView : NSView {
    TTAppDelegate *appDelegate;
    TTModeDirection direction;
    TTProgressBar *progressBar;
    NSView *imageLayoutView;
    NSImageView *backgroundView;
    NSImageView *iconView;
    NSImageView *northChevron;
    NSImageView *eastChevron;
    NSImageView *westChevron;
    NSImageView *southChevron;
}

@property (nonatomic) TTModeDirection direction;
@property (nonatomic) TTMode *mode;
@property (nonatomic) TTButtonMoment buttonMoment;

- (void)drawProgressBar:(NSProgressIndicator *)progressBar;
- (void)drawImageLayoutView;
+ (NSRect)actionFrame;


@end
