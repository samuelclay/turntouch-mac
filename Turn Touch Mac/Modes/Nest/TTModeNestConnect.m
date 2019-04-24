//
//  TTModeNestConnect.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestConnect.h"

@interface TTModeNestConnect ()

@property (nonatomic, strong) NSPopover *authPopover;

@end

@implementation TTModeNestConnect

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Actions

- (IBAction)clickAuthButton:(id)sender {
    TTModeNestAuthViewController *nestAuthViewController = [[TTModeNestAuthViewController alloc] init];
    nestAuthViewController.modeNest = self.modeNest;
    
    self.authPopover = [[NSPopover alloc] init];
    [self.authPopover setContentSize:NSMakeSize(320, 480)];
    [self.authPopover setBehavior:NSPopoverBehaviorTransient];
    [self.authPopover setAnimates:YES];
    [self.authPopover setContentViewController:nestAuthViewController];
    
    NSRect entryRect = [sender convertRect:((NSButton *)sender).bounds
                                    toView:self.appDelegate.panelController.backgroundView];
    
    nestAuthViewController.authPopover = self.authPopover;
    [self.authPopover showRelativeToRect:entryRect
                             ofView:self.appDelegate.panelController.backgroundView
                      preferredEdge:NSMinYEdge];
}

- (void)closePopover {
    [self.authPopover close];
}

@end
