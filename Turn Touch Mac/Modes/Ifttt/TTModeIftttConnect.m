//
//  TTModeIftttConnect.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIftttConnect.h"

@interface TTModeIftttConnect ()

@end

@implementation TTModeIftttConnect

@synthesize authButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Actions

- (IBAction)clickAuthButton:(id)sender {
    [self.modeIfttt beginConnectingToIfttt:^{
        TTModeIftttAuthViewController *iftttAuthViewController = [[TTModeIftttAuthViewController alloc] init];
        iftttAuthViewController.modeIfttt = self.modeIfttt;
        
        authPopover = [[NSPopover alloc] init];
        [authPopover setContentSize:NSMakeSize(320, 480)];
        [authPopover setBehavior:NSPopoverBehaviorTransient];
        [authPopover setAnimates:YES];
        [authPopover setContentViewController:iftttAuthViewController];
        
        NSRect entryRect = [sender convertRect:((NSButton *)sender).bounds
                                        toView:appDelegate.panelController.backgroundView];
        
        iftttAuthViewController.authPopover = authPopover;
        [authPopover showRelativeToRect:entryRect
                                 ofView:appDelegate.panelController.backgroundView
                          preferredEdge:NSMinYEdge];
        
        [iftttAuthViewController authorizeIfttt];
    }];
}

- (void)closePopover {
    [authPopover close];
}

@end
