//
//  TTModeWemo.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemo.h"

@implementation TTModeWemo

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
}
- (void)runTTModeWemoDeviceOff {
    NSLog(@"Running TTModeWemoDeviceOff");
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

- (void)loadWemoDevices {

}

@end
