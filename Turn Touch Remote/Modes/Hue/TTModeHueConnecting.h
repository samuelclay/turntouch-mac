//
//  TTModeHueConnecting.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/9/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"
#import "TTModeHue.h"

@interface TTModeHueConnecting : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeHue *modeHue;
@property (nonatomic) IBOutlet NSTextField *progressMessage;
@property (nonatomic,weak) IBOutlet NSProgressIndicator *progressIndicator;

- (void)setConnectingWithMessage:(NSString*)message;

@end
