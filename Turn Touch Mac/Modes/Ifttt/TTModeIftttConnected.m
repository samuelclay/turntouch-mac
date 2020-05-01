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

@property (nonatomic, strong) NSPopover *authPopover;

@end

@implementation TTModeIftttConnected

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)clickEditButton:(id)sender {
    [self.modeIfttt registerTriggers:^{
        TTModeIftttAuthViewController *iftttAuthViewController = [[TTModeIftttAuthViewController alloc] init];
        iftttAuthViewController.modeIfttt = self.modeIfttt;
        
        self.authPopover = [[NSPopover alloc] init];
        [self.authPopover setContentSize:NSMakeSize(420, 480)];
        [self.authPopover setBehavior:NSPopoverBehaviorTransient];
        [self.authPopover setAnimates:YES];
        [self.authPopover setContentViewController:iftttAuthViewController];
        
        NSRect entryRect = [sender convertRect:((NSButton *)sender).bounds
                                        toView:self.appDelegate.panelController.backgroundView];
        
        iftttAuthViewController.authPopover = self.authPopover;
        [self.authPopover showRelativeToRect:entryRect
                                 ofView:self.appDelegate.panelController.backgroundView
                          preferredEdge:NSMinYEdge];
        
        BOOL hasAuthorizedIfttt = [[self.modeIfttt.action optionValue:kIftttAuthorized] boolValue];
        if (hasAuthorizedIfttt) {
            [iftttAuthViewController openRecipe:self.action.direction];
        } else {
            [iftttAuthViewController authorizeIfttt];
            [self.modeIfttt.action changeActionOption:kIftttAuthorized to:@(YES)];
        }
    }];
}

@end
