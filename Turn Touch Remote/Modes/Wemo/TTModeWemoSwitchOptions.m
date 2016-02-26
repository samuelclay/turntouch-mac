//
//  TTModeWemoSwitchOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemoSwitchOptions.h"
#import "TTModeWemo.h"

@interface TTModeWemoSwitchOptions ()

@end

@implementation TTModeWemoSwitchOptions

@synthesize devicePopup;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self selectDevice];
}

- (void)selectDevice {
    NSString *deviceSelectedIdentifier = [self.action optionValue:kWemoDeviceLocation
                                                      inDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *deviceSelected;
    NSMutableArray *devices = [NSMutableArray array];
    [devicePopup removeAllItems];
    TTModeWemo *modeWemo = (TTModeWemo *)self.mode;
    for (TTModeWemoDevice *device in [modeWemo sharedFoundDevices]) {
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
    NSMenuItem *menuItem = [devicePopup selectedItem];
    NSString *deviceIdentifier;
    
    TTModeWemo *modeWemo = (TTModeWemo *)self.mode;
    for (TTModeWemoDevice *device in [modeWemo sharedFoundDevices]) {
        if ([device.deviceName isEqualToString:menuItem.title]) {
            deviceIdentifier = device.location;
            break;
        }
    }
    
    [self.action changeActionOption:kWemoDeviceLocation to:deviceIdentifier];
}

@end
