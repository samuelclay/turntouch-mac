//
//  TTModeWemoSwitchOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemo.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeWemoSwitchOptions : TTOptionsDetailViewController <TTModeWemoDelegate>

@property (nonatomic) IBOutlet NSPopUpButton *devicePopup;
@property (nonatomic) IBOutlet NSButton *refreshButton;
@property (nonatomic) IBOutlet NSProgressIndicator *spinner;
@property (nonatomic, strong) TTModeWemo *modeWemo;

- (IBAction)didChangeDevice:(id)sender;

@end
