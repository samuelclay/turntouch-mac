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

@synthesize hudViewController;

- (instancetype)init {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        hudViewController = [[TTHUDWindowController alloc] initWithWindowNibName:@"TTHUDView"];
    }
    return self;
}

#pragma mark - Toasts

- (void)toastActiveMode {
    [hudViewController fadeIn:nil];
    
    [self performBlock:^{
        [hudViewController fadeOut:nil];
    } afterDelay:0.5 cancelPreviousRequest:YES];
}

- (void)toastActiveAction {
    [hudViewController fadeIn:nil];
    
    [self performBlock:^{
        [hudViewController fadeOut:nil];
    } afterDelay:0.5 cancelPreviousRequest:YES];
}

@end
