//
//  TTModeGoveeConnecting.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGovee.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeGoveeConnecting : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeGovee *modeGovee;
@property (nonatomic) IBOutlet NSTextField *progressMessage;
@property (nonatomic) IBOutlet NSButton *cancelButton;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;

- (void)setConnectingWithMessage:(NSString *)message;
- (IBAction)clickCancelButton:(id)sender;

@end
