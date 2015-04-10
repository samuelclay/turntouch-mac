//
//  TTTitleBarView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/9/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTSettingsButton.h"

@class TTAppDelegate;

@interface TTTitleBarView : NSView
<NSStackViewDelegate, NSMenuDelegate> {
    TTAppDelegate *appDelegate;
    NSImage *title;
    TTSettingsButton *settingsButton;
    BOOL isMenuVisible;
    NSMenu *settingsMenu;
    NSDictionary *batteryAttributes;
}

- (void)showPreferences:(NSString *)selectedTab;

@end
