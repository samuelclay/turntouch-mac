//
//  TTModeKasaSwitchOptions.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasa.h"
#import "TTOptionsDetailViewController.h"
#import "TTModeKasaSwitchDevice.h"

@interface TTModeKasaSwitchOptions : TTOptionsDetailViewController <TTModeKasaDelegate, NSStackViewDelegate, TTModeKasaSwitchDeviceDelegate, NSMenuDelegate>

@property (nonatomic) IBOutlet NSButton *refreshButton;
@property (nonatomic) IBOutlet NSProgressIndicator *spinner;
@property (nonatomic) IBOutlet NSStackView *devicesStack;
@property (nonatomic) IBOutlet NSTextField *noticeLabel;
@property (nonatomic, strong) TTModeKasa *modeKasa;

- (IBAction)showKasaSwitchMenu:(id)sender;

@end
