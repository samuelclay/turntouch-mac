//
//  TTModeIftttConnect.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIftttConnect.h"

@interface TTModeIftttConnect ()

@property (nonatomic, strong) NSPopover *authPopover;

@end

@implementation TTModeIftttConnect

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Actions

- (IBAction)clickAuthButton:(id)sender {
    [self.modeIfttt registerTriggers:^{    
        // Generate new device ID when reconnecting to IFTTT. Or better don't.
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        [prefs removeObjectForKey:kIftttDeviceIdKey];
    
        TTModeIftttAuthViewController *iftttAuthViewController = [[TTModeIftttAuthViewController alloc] init];
        iftttAuthViewController.modeIfttt = self.modeIfttt;
        
        self.authPopover = [[NSPopover alloc] init];
        [self.authPopover setContentSize:NSMakeSize(420, 480)];
        [self.authPopover setBehavior:NSPopoverBehaviorSemitransient];
        [self.authPopover setAnimates:YES];
        [self.authPopover setContentViewController:iftttAuthViewController];
        
        NSRect entryRect = [sender convertRect:((NSButton *)sender).bounds
                                        toView:self.appDelegate.panelController.backgroundView];
        
        iftttAuthViewController.authPopover = self.authPopover;
        [self.authPopover showRelativeToRect:entryRect
                                 ofView:self.appDelegate.panelController.backgroundView
                          preferredEdge:NSMinYEdge];
        
        [iftttAuthViewController authorizeIfttt];
    }];
}

- (void)closePopover {
    [self.authPopover close];
}

@end
