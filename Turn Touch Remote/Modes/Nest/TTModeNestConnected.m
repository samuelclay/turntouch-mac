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

@synthesize thermostatPopup;
@synthesize labelAmbient;
@synthesize labelTarget;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self selectThermostat];
}

- (void)selectThermostat {
    NSString *thermostatSelectedIdentifier = [appDelegate.modeMap mode:self.mode
                                                     actionOptionValue:kNestThermostat
                                                           inDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *thermostatSelected;
    NSMutableArray *thermostats = [NSMutableArray array];
    [thermostatPopup removeAllItems];
    for (Thermostat *thermostat in [self.modeNest.currentStructure objectForKey:@"thermostats"]) {
        if (!thermostat.nameLong) thermostat.nameLong = @"Connecting to Nest...";
        [thermostats addObject:@{@"name": thermostat.nameLong, @"identifier": thermostat.thermostatId}];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [thermostats sortUsingDescriptors:@[sd]];
    
    for (NSDictionary *thermostatData in thermostats) {
        [thermostatPopup addItemWithTitle:thermostatData[@"name"]];
        if ([thermostatData[@"identifier"] isEqualToString:thermostatSelectedIdentifier]) {
            thermostatSelected = thermostatData[@"name"];
        }
    }
    if (thermostatSelected) {
        [thermostatPopup selectItemWithTitle:thermostatSelected];
    }
}

@end
