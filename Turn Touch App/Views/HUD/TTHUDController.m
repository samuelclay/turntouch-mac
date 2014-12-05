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

- (instancetype)init {
    if (self = [super init]) {
        hudWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 200, 200, 500)
                                                        styleMask:NSBorderlessWindowMask
                                                          backing:NSBackingStoreBuffered
                                                            defer:NO
                                                           screen:[[NSScreen screens] objectAtIndex:0]];
        hudViewController = [[TTHUDViewController alloc] initWithNibName:@"TTHUDView"
                                                                  bundle:nil];
        [self setWindow:hudWindow];
        [self setContentViewController:hudViewController];
    }
    return self;
}

@end
