//
//  TTModeGoveeConnecting.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGoveeConnecting.h"

@implementation TTModeGoveeConnecting

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setConnectingWithMessage:(NSString *)message {
    if (!message) message = @"Connecting to Govee...";

    self.progressMessage.stringValue = message;
    [self.progressIndicator startAnimation:self];
}

- (IBAction)clickCancelButton:(id)sender {
    [self.modeGovee cancelConnectingToGovee];
}

@end
