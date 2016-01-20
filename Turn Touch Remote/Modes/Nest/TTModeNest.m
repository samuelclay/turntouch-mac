//
//  TTModeNest.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNest.h"
#import "NestAuthManager.h"
#import "FirebaseManager.h"

@implementation TTModeNest

NSString *const kNestSetTemperature = @"nestSetTemperature";

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
             @"TTModeNestSetTemp"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeNestRaiseTemp {
    return @"Raise temp";
}
- (NSString *)titleTTModeNestLowerTemp {
    return @"Lower temp";
}
- (NSString *)titleTTModeNestSetTemp {
    return @"Set temperature";
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

#pragma mark - Action methods

- (void)runTTModeNestRaiseTemp {
    Thermostat *thermostat = [self selectedThermostat];
    NSLog(@"Running TTModeNestRaiseTemp: %ld+1", thermostat.targetTemperatureF);
    thermostat.targetTemperatureF += 1;
    [self.nestThermostatManager saveChangesForThermostat:thermostat];
}
- (void)runTTModeNestLowerTemp {
    Thermostat *thermostat = [self selectedThermostat];
    NSLog(@"Running TTModeNestLowerTemp: %ld-1", thermostat.targetTemperatureF);
    thermostat.targetTemperatureF -= 1;
    [self.nestThermostatManager saveChangesForThermostat:thermostat];
}
- (void)runTTModeNestSetTemp:(TTModeDirection)direction {
    Thermostat *thermostat = [self selectedThermostat];
    NSInteger temperature = [[self.action optionValue:kNestSetTemperature
                                          inDirection:direction] integerValue];
    NSLog(@"Running TTModeNestSetTemp: %ld", temperature);

    thermostat.targetTemperatureF = temperature;
    [self.nestThermostatManager saveChangesForThermostat:thermostat];
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeNestRaiseTemp";
}
- (NSString *)defaultEast {
    return @"TTModeNestSetTemp";
}
- (NSString *)defaultWest {
    return @"TTModeNestSetTemp";
}
- (NSString *)defaultSouth {
    return @"TTModeNestLowerTemp";
}

#pragma mark - Activation

- (void)activate {
    if ([[NestAuthManager sharedManager] isValidSession]) {
        if (self.currentStructure) {
            nestState = NEST_STATE_CONNECTED;
        } else {
            nestState = NEST_STATE_CONNECTING;
        }
    } else {
        nestState = NEST_STATE_NOT_CONNECTED;
    }
    [self.delegate changeState:nestState withMode:self];
    
    self.nestThermostatManager = [[NestThermostatManager alloc] init];
    [self.nestThermostatManager setDelegate:self];

    self.nestStructureManager = [[NestStructureManager alloc] init];
    [self.nestStructureManager setDelegate:self];
    [self.nestStructureManager initialize];
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
    nestState = NEST_STATE_CONNECTED;
    [self.delegate changeState:nestState withMode:self];
    [self.delegate updateThermostat:thermostat];
}

- (Thermostat *)selectedThermostat {
    Thermostat *thermostat = [[self.currentStructure objectForKey:@"thermostats"] objectAtIndex:0];;
    return thermostat;
}
- (void)subscribeToThermostat:(NSInteger)thermostatIndex {
    Thermostat *thermostat = [self selectedThermostat];
    
    NSLog(@"Subscribing to thermostat: %ld=%@", thermostatIndex, thermostat);
    if (!thermostat) return;
    
    [self.nestThermostatManager beginSubscriptionForThermostat:thermostat];

    nestState = NEST_STATE_CONNECTED;
    [self.delegate changeState:nestState withMode:self];
}


@end
