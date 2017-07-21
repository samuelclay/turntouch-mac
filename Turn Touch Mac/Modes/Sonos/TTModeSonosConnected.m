//
//  TTModeSonosConnected.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/18/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeSonosConnected.h"

@interface TTModeSonosConnected ()

@end

@implementation TTModeSonosConnected

@synthesize modeSonos;
@synthesize connectedLabel;
@synthesize scanButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateConnected];
}

- (void)updateConnected {
    NSInteger count = [self.modeSonos foundDevices].count;
    if (count > 0) {
        [connectedLabel setStringValue:[NSString stringWithFormat:@"Connected to %ld Sonos device%@",
                                        (long)count, count == 1 ? @"" : @"s"]];
    } else {
        [connectedLabel setStringValue:@"No Sonos devices found"];
    }
}

- (IBAction)scanForDevices:(id)sender {
    [self.modeSonos beginConnectingToSonos:nil];
}

@end
