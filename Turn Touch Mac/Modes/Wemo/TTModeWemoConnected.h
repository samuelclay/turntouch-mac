//
//  TTModeWemoConnected.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemo.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeWemoConnected : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeWemo *modeWemo;
@property (nonatomic) IBOutlet NSTextField *connectedLabel;
@property (nonatomic) IBOutlet TTChangeButtonView *scanButton;

- (IBAction)scanForDevices:(id)sender;

@end
