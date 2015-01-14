//
//  TTModeHueConnecting.m
//  Turn Touch App
//
//  Created by Samuel Clay on 1/9/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHueConnecting.h"

@interface TTModeHueConnecting ()

@end

@implementation TTModeHueConnecting

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setConnectingWithMessage:(NSString*)message {
    if (!message) message = @"Connecting to Hue...";

    self.progressMessage.stringValue = message;
    [self.progressIndicator startAnimation:self];
}

@end
