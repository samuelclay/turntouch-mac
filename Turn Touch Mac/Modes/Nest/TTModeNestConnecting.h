//
//  TTModeNestConnecting.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNest.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeNestConnecting : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeNest *modeNest;
@property (nonatomic) IBOutlet NSTextField *progressMessage;
@property (nonatomic) IBOutlet NSButton *cancelButton;
@property (nonatomic,weak) IBOutlet NSProgressIndicator *progressIndicator;

- (void)setConnectingWithMessage:(NSString*)message;
- (IBAction)clickCancelButton:(id)sender;

@end
