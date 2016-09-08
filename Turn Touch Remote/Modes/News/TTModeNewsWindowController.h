//
//  TTModeNewsWindowController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeNewsBrowserView.h"
#import "TTModeNewsWindow.h"
#import "TTModeNewsBackgroundView.h"
#import "TTModeNewsMenuView.h"

@interface TTModeNewsWindowController : NSWindowController  <NSWindowDelegate, TTHUDMenuDelegate> {
    TTAppDelegate *appDelegate;
    
    BOOL isFading;
}

@property (nonatomic) IBOutlet TTModeNewsWindow *webWindow;
@property (nonatomic) IBOutlet TTModeNewsBackgroundView *backgroundView;
@property (nonatomic) IBOutlet TTModeNewsBrowserView *browserView;
@property (nonatomic) IBOutlet TTModeNewsMenuView *menuView;

- (void)fadeIn;
- (IBAction)fadeOut;
- (void)addFeeds:(NSArray *)stories;
- (void)addStories:(NSArray *)stories;

@end
