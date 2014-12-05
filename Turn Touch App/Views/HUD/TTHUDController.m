//
//  TTHUDController.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTHUDController.h"

@interface TTHUDController ()

@end

@implementation TTHUDController

@synthesize hudWindow;
@synthesize hudViewController;

- (void)awakeFromNib {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    [hudWindow setFrame:NSMakeRect(0, 0, CGRectGetWidth(mainScreen.frame), 200)
                  display:YES
                  animate:YES];
    [hudWindow makeKeyAndOrderFront:NSApp];
    [hudWindow setLevel:CGShieldingWindowLevel()];
    hudWindow.collectionBehavior = (NSWindowCollectionBehaviorIgnoresCycle |
                                    NSWindowCollectionBehaviorCanJoinAllSpaces);
    [self setWindow:hudWindow];
}

@end
