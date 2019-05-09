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
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end
