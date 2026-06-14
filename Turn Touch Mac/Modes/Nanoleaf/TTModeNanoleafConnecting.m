//
//  TTModeNanoleafConnecting.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTModeNanoleafConnecting.h"

@implementation TTModeNanoleafConnecting

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setConnectingWithMessage:(NSString *)message {
    if (!message) message = @"Connecting to Nanoleaf...";
    self.progressMessage.stringValue = message;
    [self.progressIndicator startAnimation:self];
}

@end
