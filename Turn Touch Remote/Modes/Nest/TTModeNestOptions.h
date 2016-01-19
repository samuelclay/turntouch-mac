//
//  TTModeNestOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@interface TTModeNestOptions : TTOptionsDetailViewController {
    NSPopover *authPopover;
}

@property (nonatomic) IBOutlet NSButton *authButton;

- (IBAction)clickAuthButton:(id)sender;
- (void)closePopover;

@end
