//
//  TTModeGoveeConnected.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGovee.h"
#import "TTOptionsDetailViewController.h"

@class TTChangeButtonView;

@interface TTModeGoveeConnected : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeGovee *modeGovee;
@property (nonatomic) IBOutlet NSTextField *connectedLabel;
@property (nonatomic) IBOutlet TTChangeButtonView *scanButton;

- (IBAction)scanForDevices:(id)sender;
- (IBAction)changeApiKey:(id)sender;

@end
