//
//  TTModeNanoleafPushlink.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTModeNanoleafPushlink.h"
#import "TTModeNanoleaf.h"

@implementation TTModeNanoleafPushlink

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceNameLabel.stringValue = [TTModeNanoleaf deviceName] ?: @"Nanoleaf";
}

- (void)setProgress:(NSNumber *)progressPercentage {
    if (progressPercentage) {
        [self.progressView setDoubleValue:[progressPercentage doubleValue]];
    }
}

@end
