//
//  TTModeIftttTriggerActionOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIftttTriggerActionOptions.h"
#import "TTModeIftttAuthViewController.h"

@interface TTModeIftttTriggerActionOptions ()

@end

@implementation TTModeIftttTriggerActionOptions

@synthesize modeIfttt;
@synthesize authPopover;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    modeIfttt = (TTModeIfttt *)self.action.mode;
}

- (IBAction)clickRecipeButton:(id)sender {
    [modeIfttt registerTriggers:^{
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
