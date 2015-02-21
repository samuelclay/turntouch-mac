//
//  TTHUDViewController.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeHUDView.h"
#import "TTModeHUDWindow.h"

@class TTModeHUDView;

@interface TTModeHUDWindowController : NSWindowController <NSWindowDelegate> {
    TTAppDelegate *appDelegate;
    TTModeHUDView *hudView;
    TTModeHUDWindow *hudWindow;
    
    BOOL isFading;
}

@property (nonatomic) IBOutlet TTModeHUDView *hudView;
@property (nonatomic) IBOutlet TTModeHUDWindow *hudWindow;

- (IBAction)fadeIn:(id)sender;
- (IBAction)fadeOut:(id)sender;
- (void)teaseMode:(TTModeDirection)direction;

@end
