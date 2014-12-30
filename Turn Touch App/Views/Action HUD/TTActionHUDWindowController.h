//
//  TTHUDViewController.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTActionHUDView.h"
#import "TTActionHUDWindow.h"

@class TTActionHUDView;

@interface TTActionHUDWindowController : NSWindowController <NSWindowDelegate> {
    TTAppDelegate *appDelegate;
    TTActionHUDView *hudView;
    TTActionHUDWindow *hudWindow;
}

@property (nonatomic) IBOutlet TTActionHUDView *hudView;
@property (nonatomic) IBOutlet TTActionHUDWindow *hudWindow;

- (IBAction)fadeIn:(TTModeDirection)direction;
- (IBAction)fadeOut:(id)sender;

@end
