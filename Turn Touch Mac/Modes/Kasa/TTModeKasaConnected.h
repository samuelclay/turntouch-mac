//
//  TTModeKasaConnected.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasa.h"
#import "TTOptionsDetailViewController.h"

@class TTChangeButtonView;

@interface TTModeKasaConnected : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeKasa *modeKasa;
@property (nonatomic) IBOutlet NSTextField *connectedLabel;
@property (nonatomic) IBOutlet TTChangeButtonView *scanButton;
@property (nonatomic) IBOutlet NSButton *credentialsButton;

- (IBAction)scanForDevices:(id)sender;
- (IBAction)enterCredentials:(id)sender;

@end
