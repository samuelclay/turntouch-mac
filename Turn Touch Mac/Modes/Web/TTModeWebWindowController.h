//
//  TTModeWebWindowController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeWebBrowserView.h"
#import "TTModeWebWindow.h"
#import "TTModeWebBackgroundView.h"
#import "TTModeWebMenuView.h"

@interface TTModeWebWindowController : NSWindowController  <NSWindowDelegate, TTHUDMenuDelegate>

@property (nonatomic) IBOutlet TTModeWebWindow *webWindow;
@property (nonatomic) IBOutlet TTModeWebBackgroundView *backgroundView;
@property (nonatomic) IBOutlet TTModeWebBrowserView *browserView;
@property (nonatomic) IBOutlet TTModeWebMenuView *menuView;

- (void)fadeIn;
- (IBAction)fadeOut;

@end
