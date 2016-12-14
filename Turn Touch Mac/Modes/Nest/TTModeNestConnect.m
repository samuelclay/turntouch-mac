//
//  TTModeNestConnect.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestConnect.h"

@interface TTModeNestConnect ()

@end

@implementation TTModeNestConnect

@synthesize authButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Actions

- (IBAction)clickAuthButton:(id)sender {
    TTModeNestAuthViewController *nestAuthViewController = [[TTModeNestAuthViewController alloc] init];
    nestAuthViewController.modeNest = self.modeNest;
    
    authPopover = [[NSPopover alloc] init];
    [authPopover setContentSize:NSMakeSize(320, 480)];
    [authPopover setBehavior:NSPopoverBehaviorTransient];
    [authPopover setAnimates:YES];
    [authPopover setContentViewController:nestAuthViewController];
    
    NSRect entryRect = [sender convertRect:((NSButton *)sender).bounds
                                    toView:appDelegate.panelController.backgroundView];
    
    nestAuthViewController.authPopover = authPopover;
    [authPopover showRelativeToRect:entryRect
                             ofView:appDelegate.panelController.backgroundView
                      preferredEdge:NSMinYEdge];
}

- (void)closePopover {
    [authPopover close];
}

@end
