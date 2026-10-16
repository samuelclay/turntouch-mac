//
//  TTModeGoveeSwitchOptions.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGovee.h"
#import "TTOptionsDetailViewController.h"
#import "TTModeGoveeSwitchDevice.h"

@interface TTModeGoveeSwitchOptions : TTOptionsDetailViewController <TTModeGoveeDelegate, NSStackViewDelegate, TTModeGoveeSwitchDeviceDelegate, NSMenuDelegate>

@property (nonatomic) IBOutlet NSButton *refreshButton;
@property (nonatomic) IBOutlet NSProgressIndicator *spinner;
@property (nonatomic) IBOutlet NSStackView *devicesStack;
@property (nonatomic) IBOutlet NSTextField *noticeLabel;
@property (nonatomic, strong) TTModeGovee *modeGovee;

- (IBAction)showGoveeSwitchMenu:(id)sender;

@end
