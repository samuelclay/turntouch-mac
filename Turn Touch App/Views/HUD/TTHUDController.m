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

@synthesize hudWindow;
@synthesize hudViewController;

- (instancetype)init {
    if (self = [super init]) {
        hudViewController = [[TTHUDViewController alloc] initWithNibName:@"TTHUDView"
                                                                  bundle:nil];
    }
    return self;
}

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
}

#pragma mark - Toasts

- (void)toastActiveMode {
    [self.hudViewController fadeIn:nil];
    
    [self performBlock:^{
        [self.hudViewController fadeOut:nil];
    } afterDelay:0.5 cancelPreviousRequest:YES];
}

- (void)toastActiveAction {
    [self.hudViewController fadeIn:nil];
    
    [self performBlock:^{
        [self.hudViewController fadeOut:nil];
    } afterDelay:0.5 cancelPreviousRequest:YES];
}

@end
