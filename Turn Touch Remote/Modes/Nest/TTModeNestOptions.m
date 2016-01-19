//
//  TTModeNestOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestOptions.h"
#import "TTModeNestAuthViewController.h"

@interface TTModeNestOptions ()

@end

@implementation TTModeNestOptions

@synthesize authButton;

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)clickAuthButton:(id)sender {
    TTModeNestAuthViewController *nestAuthViewController = [[TTModeNestAuthViewController alloc] init];

    authPopover = [[NSPopover alloc] init];
    [authPopover setContentSize:NSMakeSize(320, 480)];
    [authPopover setBehavior:NSPopoverBehaviorTransient];
    [authPopover setAnimates:YES];
    [authPopover setContentViewController:nestAuthViewController];
    
    NSRect entryRect = [sender convertRect:((NSButton *)sender).bounds
                                    toView:appDelegate.panelController.backgroundView];
    
    [authPopover showRelativeToRect:entryRect
                             ofView:appDelegate.panelController.backgroundView
                      preferredEdge:NSMinYEdge];
}

- (void)closePopover {
    [authPopover close];
}

@end
