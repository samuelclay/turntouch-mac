//
//  TTModeNest.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNest.h"

@implementation TTModeNest

@synthesize nestStructureManager;
@synthesize nestThermostatManager;
@synthesize currentStructure;

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
    NSLog(@"Running TTModeNestRaiseTemp");
}
- (void)runTTModeNestLowerTemp {
    NSLog(@"Running TTModeNestLowerTemp");
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
    return @"TTModeNestLowerTemp";
}
- (NSString *)defaultWest {
    return @"TTModeNestSetTemp";
}
- (NSString *)defaultSouth {
    return @"TTModeNestChangeMode";
}

#pragma mark - Activation

- (void)activate {
    self.nestStructureManager = [[NestStructureManager alloc] init];
    [self.nestStructureManager setDelegate:self];
    [self.nestStructureManager initialize];
    
    self.nestThermostatManager = [[NestThermostatManager alloc] init];
    [self.nestThermostatManager setDelegate:self];
}

- (void)structureUpdated:(NSDictionary *)structure {
    NSLog(@"Nest Structure updated: %@", structure);
    self.currentStructure = structure;
    [self subscribeToThermostat:0];
}

- (void)thermostatValuesChanged:(Thermostat *)thermostat {
    NSLog(@"thermostat value changed: %@: %ld - %ld", thermostat, thermostat.targetTemperatureF, thermostat.ambientTemperatureF);
}

- (void)subscribeToThermostat:(NSInteger)thermostatIndex {
    NSLog(@"Subscribing to thermostat: %ld", thermostatIndex);
    Thermostat *thermostat = [[self.currentStructure objectForKey:@"thermostats"] objectAtIndex:thermostatIndex];
    [self.nestThermostatManager beginSubscriptionForThermostat:thermostat];
}


@end
