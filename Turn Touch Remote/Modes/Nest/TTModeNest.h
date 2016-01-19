//
//  TTModeNest.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "NestThermostatManager.h"
#import "NestStructureManager.h"

@interface TTModeNest : TTMode <NestThermostatManagerDelegate, NestStructureManagerDelegate>

@property (nonatomic, strong) NestThermostatManager *nestThermostatManager;
@property (nonatomic, strong) NestStructureManager *nestStructureManager;

@property (nonatomic, strong) NSDictionary *currentStructure;

- (void)subscribeToThermostat:(NSInteger)thermostatIndex;

@end
