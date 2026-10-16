//
//  TTModeKasaConnecting.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasa.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeKasaConnecting : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeKasa *modeKasa;
@property (nonatomic) IBOutlet NSTextField *progressMessage;
@property (nonatomic) IBOutlet NSButton *cancelButton;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;

- (void)setConnectingWithMessage:(NSString *)message;
- (IBAction)clickCancelButton:(id)sender;

@end
