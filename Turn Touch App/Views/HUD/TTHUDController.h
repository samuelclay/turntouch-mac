//
//  TTHUDController.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTHUDViewController.h"
#import "TTAppDelegate.h"

@interface TTHUDController : NSWindowController <NSWindowDelegate> {
}

@property (nonatomic) NSWindow *hudWindow;
@property (nonatomic) TTHUDViewController *hudViewController;
@end
