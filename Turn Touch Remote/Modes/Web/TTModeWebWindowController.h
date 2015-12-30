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

@interface TTModeWebWindowController : NSWindowController  <NSWindowDelegate> {
    TTAppDelegate *appDelegate;
    TTModeWebBrowserView *browserView;
    TTModeWebWindow *webWindow;
    
    BOOL isFading;
}

@property (nonatomic) IBOutlet TTModeWebBrowserView *browserView;
@property (nonatomic) IBOutlet TTModeWebWindow *webWindow;
@property (nonatomic) IBOutlet TTModeWebBackgroundView *backgroundView;

- (void)fadeIn;
- (IBAction)fadeOut;

@end
