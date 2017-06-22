//
//  TTModeWemoConnected.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemoConnected.h"

@interface TTModeWemoConnected ()

@end

@implementation TTModeWemoConnected

@synthesize modeWemo;
@synthesize connectedLabel;
@synthesize scanButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateConnected];
}

- (void)updateConnected {
    NSInteger count = [TTModeWemo foundDevices].count;
    if (count > 0) {
        [connectedLabel setStringValue:[NSString stringWithFormat:@"Connected to %ld Wemo device%@",
                                        (long)count, count == 1 ? @"" : @"s"]];
    } else {
        [connectedLabel setStringValue:@"No Wemo devices found"];
    }
}

- (IBAction)scanForDevices:(id)sender {
    [self.modeWemo beginConnectingToWemo];
}

@end
