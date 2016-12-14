//
//  TTModeWemoConnecting.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemo.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeWemoConnecting : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeWemo *modeWemo;
@property (nonatomic) IBOutlet NSTextField *progressMessage;
@property (nonatomic) IBOutlet NSButton *cancelButton;
@property (nonatomic,weak) IBOutlet NSProgressIndicator *progressIndicator;

- (void)setConnectingWithMessage:(NSString*)message;
- (IBAction)clickCancelButton:(id)sender;

@end
