//
//  TTHUDController.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTHUDController.h"
#import "NSObject+CancelableBlocks.h"

@interface TTHUDController ()

@end

@implementation TTHUDController

@synthesize modeHUDController;
@synthesize actionHUDController;

- (instancetype)init {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        modeHUDController = [[TTModeHUDWindowController alloc]
                             initWithWindowNibName:@"TTModeHUDView"];
        actionHUDController = [[TTActionHUDWindowController alloc]
                               initWithWindowNibName:@"TTActionHUDView"];
    }
    return self;
}

#pragma mark - Toasts

- (void)toastActiveMode {
    [modeHUDController fadeIn:nil];
    
    [self performBlock:^{
        [modeHUDController fadeOut:nil];
    } afterDelay:0.5 cancelPreviousRequest:YES];
}

- (void)toastActiveAction {
    [actionHUDController fadeIn:nil];
    
    [self performBlock:^{
        [actionHUDController fadeOut:nil];
    } afterDelay:0.5 cancelPreviousRequest:YES];
}

@end
