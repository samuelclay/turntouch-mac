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

@synthesize devicePopup;
@synthesize labelAmbient;
@synthesize labelTarget;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self selectDevice];
}

- (void)selectDevice {
    NSString *deviceSelectedIdentifier = [appDelegate.modeMap mode:self.mode
                                                 actionOptionValue:kNestThermostat
                                                       inDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *deviceSelected;
    NSMutableArray *devices = [NSMutableArray array];
    [devicePopup removeAllItems];
    for (Thermostat *thermostat in [self.modeNest.currentStructure objectForKey:@"thermostats"]) {
        if (!thermostat.nameLong) thermostat.nameLong = @"Connecting to Nest...";
        [devices addObject:@{@"name": thermostat.nameLong, @"identifier": thermostat.thermostatId}];
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
