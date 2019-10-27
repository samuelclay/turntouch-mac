//
//  TTModeWemoConnect.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemo.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeWemoConnect : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSButton *authButton;
@property (nonatomic, strong) TTModeWemo *modeWemo;

- (IBAction)clickAuthButton:(id)sender;

@end
