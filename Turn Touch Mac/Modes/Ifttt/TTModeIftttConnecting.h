//
//  TTModeIftttConnecting.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIfttt.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeIftttConnecting : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeIfttt *modeIfttt;
@property (nonatomic) IBOutlet NSTextField *progressMessage;
@property (nonatomic) IBOutlet NSButton *cancelButton;
@property (nonatomic,weak) IBOutlet NSProgressIndicator *progressIndicator;

- (void)setConnectingWithMessage:(NSString*)message;
- (IBAction)clickCancelButton:(id)sender;

@end
