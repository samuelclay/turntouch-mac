//
//  TTModeWemoSwitchOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemo.h"
#import "TTOptionsDetailViewController.h"
#import "TTModeWemoSwitchDevice.h"

@interface TTModeWemoSwitchOptions : TTOptionsDetailViewController <TTModeWemoDelegate, NSStackViewDelegate, TTModeWemoSwitchDeviceDelegate, NSMenuDelegate>

@property (nonatomic) IBOutlet NSPopUpButton *devicePopup;
@property (nonatomic) IBOutlet NSButton *refreshButton;
@property (nonatomic) IBOutlet NSProgressIndicator *spinner;
@property (nonatomic) IBOutlet NSStackView *devicesStack;
@property (nonatomic) IBOutlet NSTextField *noticeLabel;
@property (nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (nonatomic, strong) TTModeWemo *modeWemo;

- (IBAction)showWemoSwitchMenu:(id)sender;

@end
