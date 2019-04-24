//
//  TTModeNestConnected.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestConnected.h"

@interface TTModeNestConnected ()

@end

@implementation TTModeNestConnected

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self selectDevice];
}

- (void)selectDevice {
    NSString *deviceSelectedIdentifier = [self.appDelegate.modeMap mode:self.mode
                                                 actionOptionValue:kNestThermostat inDirection:self.appDelegate.modeMap.inspectingModeDirection];
    NSString *deviceSelected;
    NSMutableArray *devices = [NSMutableArray array];
    [self.devicePopup removeAllItems];
    for (Thermostat *thermostat in [self.modeNest.currentStructure objectForKey:@"thermostats"]) {
        if (!thermostat.nameLong) thermostat.nameLong = @"Connecting to Nest...";
        [devices addObject:@{@"name": thermostat.nameLong, @"identifier": thermostat.thermostatId}];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [devices sortUsingDescriptors:@[sd]];
    
    for (NSDictionary *deviceData in devices) {
        [self.devicePopup addItemWithTitle:deviceData[@"name"]];
        if ([deviceData[@"identifier"] isEqualToString:deviceSelectedIdentifier]) {
            deviceSelected = deviceData[@"name"];
        }
    }
    if (deviceSelected) {
        [self.devicePopup selectItemWithTitle:deviceSelected];
    }
}

- (void)didChangeDevice:(id)sender {
    
}

@end
