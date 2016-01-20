//
//  TTModeNestConnect.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNest.h"
#import "TTOptionsDetailViewController.h"
#import "TTModeNestAuthViewController.h"

@interface TTModeNestConnect : TTOptionsDetailViewController {
    NSPopover *authPopover;
}

@property (nonatomic) IBOutlet NSButton *authButton;
@property (nonatomic, strong) TTModeNest *modeNest;

- (IBAction)clickAuthButton:(id)sender;
- (void)closePopover;

@end
