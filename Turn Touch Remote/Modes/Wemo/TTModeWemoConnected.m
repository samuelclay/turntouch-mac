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

@synthesize devicePopup;
@synthesize labelAmbient;
@synthesize labelTarget;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self selectDevice];
}

- (void)selectDevice {
    NSString *deviceSelectedIdentifier = [appDelegate.modeMap mode:self.mode
                                                 actionOptionValue:kWemoDeviceLocation
                                                       inDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *deviceSelected;
    NSMutableArray *devices = [NSMutableArray array];
    [devicePopup removeAllItems];
    for (TTModeWemoDevice *device in [self.modeWemo sharedFoundDevices]) {
        [devices addObject:@{@"name": device.deviceName, @"identifier": device.location}];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [devices sortUsingDescriptors:@[sd]];
    
    for (NSDictionary *deviceData in devices) {
        [devicePopup addItemWithTitle:deviceData[@"name"]];
        if ([deviceData[@"identifier"] isEqualToString:deviceSelectedIdentifier]) {
            deviceSelected = deviceData[@"name"];
        }
    }
    if (deviceSelected) {
        [devicePopup selectItemWithTitle:deviceSelected];
    }
}

- (void)didChangeDevice:(id)sender {
    
}

@end
