//
//  TTModeWemo.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemo.h"
#import "TTModeWemoDevice.h"

@implementation TTModeWemo

@synthesize multicastServer;

- (instancetype)init {
    if (self = [super init]) {
        foundDevices = [NSMutableArray array];
        multicastServer = [[TTModeWemoMulticastServer alloc] init];
        [multicastServer setDelegate:self];
    }
    
    return self;
}

#pragma mark - Mode

+ (NSString *)title {
    return @"WeMo";
}

+ (NSString *)description {
    return @"Smart power meter and outlet";
}

+ (NSString *)imageName {
    return @"mode_wemo.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeWemoDeviceOn",
             @"TTModeWemoDeviceOff",
             @"TTModeWemoDeviceToggle",
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeWemoDeviceOn {
    return @"Turn on";
}
- (NSString *)titleTTModeWemoDeviceOff {
    return @"Turn off";
}
- (NSString *)titleTTModeWemoDeviceToggle {
    return @"Toggle device";
}

#pragma mark - Action Images

- (NSString *)imageTTModeWemoDeviceOn {
    return @"next_story.png";
}
- (NSString *)imageTTModeWemoDeviceOff {
    return @"next_site.png";
}
- (NSString *)imageTTModeWemoDeviceToggle {
    return @"previous_story.png";
}

#pragma mark - Action methods

- (void)runTTModeWemoDeviceOn {
    NSLog(@"Running TTModeWemoDeviceOn");
    TTModeWemoDevice *device = [foundDevices objectAtIndex:0];
    [device changeDeviceState:WEMO_DEVICE_STATE_ON];
}
- (void)runTTModeWemoDeviceOff {
    NSLog(@"Running TTModeWemoDeviceOff");
    TTModeWemoDevice *device = [foundDevices objectAtIndex:0];
    [device changeDeviceState:WEMO_DEVICE_STATE_OFF];
}
- (void)runTTModeWemoDeviceToggle {
    NSLog(@"Running TTModeWemoDeviceToggle");
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeWemoDeviceOn";
}
- (NSString *)defaultEast {
    return @"TTModeWemoDeviceToggle";
}
- (NSString *)defaultWest {
    return @"TTModeWemoDeviceToggle";
}
- (NSString *)defaultSouth {
    return @"TTModeWemoDeviceOff";
}

#pragma mark - Wemo devices

- (void)activate {
    [self loadWemoDevices];
}

- (void)deactivate {
    [multicastServer deactivate];
}

- (void)loadWemoDevices {
    [multicastServer beginbroadcast];
}

- (void)foundDevice:(NSDictionary *)headers host:(NSString *)ipAddress port:(NSInteger)port {
    BOOL alreadyFound = NO;

    TTModeWemoDevice *newDevice = [[TTModeWemoDevice alloc] initWithIpAddress:ipAddress port:port];
    [newDevice setDelegate:self];
    
    for (TTModeWemoDevice *device in foundDevices) {
        if ([device isEqualToDevice:newDevice]) {
            alreadyFound = YES;
            break;
        }
    }
    
    if (alreadyFound) return;
    
    [foundDevices addObject:newDevice];

    [newDevice requestDeviceInfo];
}

- (void)deviceReady:(id)device {
    // Device's name has been found, ready to display
    
}

@end
