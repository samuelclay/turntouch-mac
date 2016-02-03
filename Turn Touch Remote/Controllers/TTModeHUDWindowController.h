//
//  TTHUDViewController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeHUDView.h"
#import "TTModeHUDWindow.h"
#import "TTHUDMenuView.h"
#import "TTHUDBackgroundView.h"

@class TTModeHUDView;
@class TTHUDMenuView;
@class TTHUDBackgroundView;

@interface TTModeHUDWindowController : NSWindowController <NSWindowDelegate, TTHUDMenuDelegate> {
    TTAppDelegate *appDelegate;
    TTModeHUDView *hudView;
    TTModeHUDWindow *hudWindow;
    
    BOOL isFading;
}

@property (nonatomic) IBOutlet TTModeHUDView *hudView;
@property (nonatomic) IBOutlet TTHUDBackgroundView *backgroundView;
@property (nonatomic) IBOutlet TTModeHUDWindow *hudWindow;
@property (nonatomic) IBOutlet TTHUDMenuView *menuView;

- (void)fadeIn:(BOOL)animate;
- (IBAction)fadeOut:(id)sender;
- (void)teaseMode:(TTModeDirection)direction;

@end
