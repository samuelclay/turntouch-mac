//
//  TTModeNest.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNest.h"
#import "NestAuthManager.h"

@implementation TTModeNest

@synthesize nestStructureManager;
@synthesize nestThermostatManager;
@synthesize currentStructure;
@synthesize delegate;
@synthesize nestState;

#pragma mark - Mode

+ (NSString *)title {
    return @"Nest";
}

+ (NSString *)description {
    return @"Smart learning thermostat";
}

+ (NSString *)imageName {
    return @"mode_nest.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeNestRaiseTemp",
             @"TTModeNestLowerTemp",
             @"TTModeNestSetTemp",
             @"TTModeNestChangeMode"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeNestRaiseTemp {
    return @"Raise temperature";
}
- (NSString *)titleTTModeNestLowerTemp {
    return @"Lower temperature";
}
- (NSString *)titleTTModeNestSetTemp {
    return @"Set temperature";
}
- (NSString *)titleTTModeNestChangeMode {
    return @"Change mode";
}

#pragma mark - Action Images

- (NSString *)imageTTModeNestRaiseTemp {
    return @"next_story.png";
}
- (NSString *)imageTTModeNestLowerTemp {
    return @"next_site.png";
}
- (NSString *)imageTTModeNestSetTemp {
    return @"previous_story.png";
}
- (NSString *)imageTTModeNestChangeMode {
    return @"previous_site.png";
}

#pragma mark - Action methods

- (void)runTTModeNestRaiseTemp {
    Thermostat *thermostat = [[self.currentStructure objectForKey:@"thermostats"] objectAtIndex:0];
    NSLog(@"Running TTModeNestRaiseTemp: %ld+1", thermostat.targetTemperatureF);
    thermostat.targetTemperatureF += 1;
    [self.nestThermostatManager saveChangesForThermostat:thermostat];
}
- (void)runTTModeNestLowerTemp {
    Thermostat *thermostat = [[self.currentStructure objectForKey:@"thermostats"] objectAtIndex:0];
    NSLog(@"Running TTModeNestLowerTemp: %ld-1", thermostat.targetTemperatureF);
    thermostat.targetTemperatureF -= 1;
    [self.nestThermostatManager saveChangesForThermostat:thermostat];
}
- (void)runTTModeNestSetTemp {
    NSLog(@"Running TTModeNestSetTemp");
}
- (void)runTTModeNestChangeMode {
    NSLog(@"Running TTModeNestChangeMode");
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeNestRaiseTemp";
}
- (NSString *)defaultEast {
    return @"TTModeNestSetTemp";
}
- (NSString *)defaultWest {
    return @"TTModeNestChangeMode";
}
- (NSString *)defaultSouth {
    return @"TTModeNestLowerTemp";
}

#pragma mark - Activation

- (void)activate {
    self.nestThermostatManager = [[NestThermostatManager alloc] init];
    [self.nestThermostatManager setDelegate:self];

    self.nestStructureManager = [[NestStructureManager alloc] init];
    [self.nestStructureManager setDelegate:self];
    [self.nestStructureManager initialize];

    if ([[NestAuthManager sharedManager] accessToken]) {
        nestState = NEST_STATE_CONNECTING;
        [self subscribeToThermostat:0];
    } else {
        nestState = NEST_STATE_NOT_CONNECTED;
    }
    [self.delegate changeState:nestState withMode:self];
}

- (void)deactivate {
    self.nestThermostatManager = nil;
    self.nestStructureManager = nil;
}

- (void)beginConnectingToNest {
    nestState = NEST_STATE_CONNECTING;
    [self.delegate changeState:nestState withMode:self];
}

- (void)cancelConnectingToNest {
    nestState = NEST_STATE_NOT_CONNECTED;
    [self.delegate changeState:nestState withMode:self];
}

- (void)structureUpdated:(NSDictionary *)structure {
    NSLog(@"Nest Structure updated: %@", structure);
    self.currentStructure = structure;
    [self subscribeToThermostat:0];
}

- (void)thermostatValuesChanged:(Thermostat *)thermostat {
    NSLog(@"thermostat value changed: %@: %ld - %ld", thermostat, thermostat.targetTemperatureF, thermostat.ambientTemperatureF);
    [self.delegate updateThermostat:thermostat];
}

- (void)subscribeToThermostat:(NSInteger)thermostatIndex {
    Thermostat *thermostat = [[self.currentStructure objectForKey:@"thermostats"] objectAtIndex:thermostatIndex];
    NSLog(@"Subscribing to thermostat: %ld=%@", thermostatIndex, thermostat);
    if (!thermostat) return;
    
    [self.nestThermostatManager beginSubscriptionForThermostat:thermostat];

    nestState = NEST_STATE_CONNECTED;
    [self.delegate changeState:nestState withMode:self];
}


@end
