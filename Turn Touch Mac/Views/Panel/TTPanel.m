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
#import "TTPanelGeometry.h"

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

- (void)setFrame:(NSRect)frameRect display:(BOOL)display {
    // AppKit also resizes the window after its content finishes Auto Layout.
    // Keep those automatic resizes below the menu bar, including transitions
    // where a collapsing menu gives its height back to the scroll viewport.
    TTPanelController *controller = (TTPanelController *)self.windowController;
    if (self.isVisible && [controller isKindOfClass:TTPanelController.class]) {
        frameRect = TTPanelFrameBelowStatusItem([controller statusRectForWindow:self],
            frameRect.size, controller.screenForPanel.visibleFrame, ARROW_HEIGHT);
    }
    [super setFrame:frameRect display:display];
}

@end
