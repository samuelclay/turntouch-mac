//
//  TTModeIftttConnected.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIftttConnected.h"
#import "TTModeIftttAuthViewController.h"

@interface TTModeIftttConnected ()

@end

@implementation TTModeIftttConnected

@synthesize modeIfttt;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)clickEditButton:(id)sender {
    [self.modeIfttt registerTriggers:^{
        TTModeIftttAuthViewController *iftttAuthViewController = [[TTModeIftttAuthViewController alloc] init];
        iftttAuthViewController.modeIfttt = self.modeIfttt;
        
        authPopover = [[NSPopover alloc] init];
        [authPopover setContentSize:NSMakeSize(420, 480)];
        [authPopover setBehavior:NSPopoverBehaviorTransient];
        [authPopover setAnimates:YES];
        [authPopover setContentViewController:iftttAuthViewController];
        
        NSRect entryRect = [sender convertRect:((NSButton *)sender).bounds
                                        toView:appDelegate.panelController.backgroundView];
        
        iftttAuthViewController.authPopover = authPopover;
        [authPopover showRelativeToRect:entryRect
                                 ofView:appDelegate.panelController.backgroundView
                          preferredEdge:NSMinYEdge];
        
        [iftttAuthViewController openRecipe:self.action.direction];
    }];
}

@end
