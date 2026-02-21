//
//  TTModeGoveeConnect.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGovee.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeGoveeConnect : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSTextField *apiKeyField;
@property (nonatomic) IBOutlet NSButton *connectButton;
@property (nonatomic) IBOutlet NSTextField *instructionLabel;
@property (nonatomic, strong) TTModeGovee *modeGovee;

- (IBAction)clickConnectButton:(id)sender;

@end
