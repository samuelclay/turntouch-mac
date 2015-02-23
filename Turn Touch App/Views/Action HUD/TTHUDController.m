
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
    [modeHUDController fadeIn:YES];
    
    if (modeOperation) [modeOperation cancel];
    
    modeOperation = [self performBlock:^{
        [modeHUDController fadeOut:nil];
    } afterDelay:2.5 cancelPreviousRequest:YES];
}

- (void)holdToastActiveMode:(BOOL)animate {
    if (modeOperation) [modeOperation cancel];

    [modeHUDController fadeIn:animate];
}

- (void)releaseToastActiveMode {
    [modeHUDController fadeOut:nil];
}

- (void)teaseMode:(TTModeDirection)direction {
    [modeHUDController teaseMode:direction];
}

- (void)hideModeTease {
    [modeHUDController fadeOut:nil];
}

- (void)toastActiveAction:(TTModeDirection)direction {
    [actionHUDController fadeIn:direction];
    
    if (actionOperation) [actionOperation cancel];
    
    actionOperation = [self performBlock:^{
        [actionHUDController slideOut:nil];
    } afterDelay:0.5 cancelPreviousRequest:YES];
}

- (void)holdToastActiveAction:(TTModeDirection)direction {
    if (actionOperation) [actionOperation cancel];
    
    if (direction == NO_DIRECTION) {
        [actionHUDController fadeOut:nil];
    } else {
        [actionHUDController fadeIn:direction];
    }
}

- (void)releaseToastActiveAction {
    [actionHUDController slideOut:nil];
}
@end
