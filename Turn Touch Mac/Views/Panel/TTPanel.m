//
//  TTPanel.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTPanel.h"
#import "TTAppDelegate.h"
#import "TTPanelController.h"

@implementation TTPanel

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // A temporary solution to fix drawing issues in dark mode; should properly implement dark mode later.
    self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];

    // Menu-bar controls must appear on the clicked display even when another
    // app owns its full-screen Space or Stage Manager set.
    self.collectionBehavior |= NSWindowCollectionBehaviorFullScreenAuxiliary;
    if (@available(macOS 13.0, *)) {
        self.collectionBehavior |= NSWindowCollectionBehaviorCanJoinAllApplications;
    }
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end
