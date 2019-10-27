//
//  TTModeIftttConnect.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIfttt.h"
#import "TTOptionsDetailViewController.h"
#import "TTModeIftttAuthViewController.h"

@interface TTModeIftttConnect : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSButton *authButton;
@property (nonatomic, strong) TTModeIfttt *modeIfttt;

- (IBAction)clickAuthButton:(id)sender;
- (void)closePopover;

@end
