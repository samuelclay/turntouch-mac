//
//  TTHUDView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTMode.h"

@class TTAppDelegate;

extern const CGFloat kActionHUDMarginPct;

@interface TTActionHUDView : NSView {
    TTAppDelegate *appDelegate;
    TTModeDirection direction;
    NSProgressIndicator *progressBar;
    NSView *imageLayoutView;
}

@property (nonatomic) TTModeDirection direction;
@property (nonatomic) TTMode *mode;

- (void)drawProgressBar:(NSProgressIndicator *)progressBar;
- (void)drawImageLayoutView;
+ (NSRect)actionFrame;

@end
