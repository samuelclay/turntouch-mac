//
//  TTHUDViewController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTActionHUDView.h"
#import "TTActionHUDWindow.h"

@class TTActionHUDView;
@class TTProgressBar;

@interface TTActionHUDWindowController : NSWindowController <NSWindowDelegate> {
    TTAppDelegate *appDelegate;
    TTActionHUDView *hudView;
    TTActionHUDWindow *hudWindow;
    
    BOOL fadingIn;
}

@property (nonatomic) IBOutlet TTActionHUDView *hudView;
@property (nonatomic) IBOutlet TTActionHUDWindow *hudWindow;
@property (nonatomic) IBOutlet TTProgressBar *progressBar;

- (IBAction)fadeIn:(NSString *)actionName inDirection:(TTModeDirection)direction;
- (IBAction)fadeIn:(NSString *)actionName inDirection:(TTModeDirection)direction withMode:(TTMode *)mode;
- (IBAction)fadeIn:(NSString *)actionName inDirection:(TTModeDirection)direction withMode:(TTMode *)mode buttonMoment:(TTButtonMoment)buttonMoment;
- (IBAction)fadeOut:(id)sender;
- (IBAction)slideOut:(id)sender;

@end
