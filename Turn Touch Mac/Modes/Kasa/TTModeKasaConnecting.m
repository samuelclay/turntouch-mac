//
//  TTModeKasaConnecting.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasaConnecting.h"

@implementation TTModeKasaConnecting

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setConnectingWithMessage:(NSString *)message {
    if (!message) message = @"Connecting to Kasa devices...";

    self.progressMessage.stringValue = message;
    [self.progressIndicator startAnimation:self];
}

- (IBAction)clickCancelButton:(id)sender {
    [self.modeKasa cancelConnectingToKasa];
}

@end
