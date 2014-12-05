//
//  TTHUDController.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTHUDViewController.h"
#import "TTHUDWindow.h"
#import "TTAppDelegate.h"

@interface TTHUDController : NSWindowController <NSWindowDelegate> {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) IBOutlet TTHUDWindow *hudWindow;
@property (nonatomic) TTHUDViewController *hudViewController;

- (void)toastActiveMode;

@end
