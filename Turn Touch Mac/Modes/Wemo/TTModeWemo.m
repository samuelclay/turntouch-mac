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

NSString *const kWemoDeviceLocation = @"wemoDeviceLocation";

//@synthesize foundDevices;
//@synthesize multicastServer;
@synthesize delegate;
@synthesize wemoState;

- (instancetype)init {
    if (self = [super init]) {
//        foundDevices = [NSMutableArray array];
//        multicastServer = [[TTModeWemoMulticastServer alloc] init];
        [[self sharedMulticastServer] setDelegate:self];
    }
    
    return self;
}

- (TTModeWemoMulticastServer *)sharedMulticastServer {
    static TTModeWemoMulticastServer *multicastServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        multicastServer = [[TTModeWemoMulticastServer alloc] init];
    });
    return multicastServer;
}

- (NSMutableArray *)sharedFoundDevices {
    static NSMutableArray *foundDevices = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        foundDevices = [NSMutableArray array];
    });
    return foundDevices;
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

- (void)runTTModeWemoDeviceOn:(TTModeDirection)direction {
    NSLog(@"Running TTModeWemoDeviceOn");
    TTModeWemoDevice *device = [self selectedDevice:direction];
    [device changeDeviceState:WEMO_DEVICE_STATE_ON];
}

- (void)runTTModeWemoDeviceOff:(TTModeDirection)direction {
    NSLog(@"Running TTModeWemoDeviceOff");
    TTModeWemoDevice *device = [self selectedDevice:direction];
    [device changeDeviceState:WEMO_DEVICE_STATE_OFF];
}
- (void)runTTModeWemoDeviceToggle:(TTModeDirection)direction {
    NSLog(@"Running TTModeWemoDeviceToggle");
    TTModeWemoDevice *device = [self selectedDevice:direction];
    [device requestDeviceState:^() {
        if (device.deviceState == WEMO_DEVICE_STATE_ON) {
            [device changeDeviceState:WEMO_DEVICE_STATE_OFF];
        } else {
            [device changeDeviceState:WEMO_DEVICE_STATE_ON];
        }
    }];
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

- (TTModeWemoDevice *)selectedDevice:(TTModeDirection)direction {
    if (![self sharedFoundDevices].count) return nil;
    
    TTModeWemoDevice *device;
    NSString *deviceLocation = [self.action optionValue:kWemoDeviceLocation inDirection:direction];
    for (TTModeWemoDevice *foundDevice in [self sharedFoundDevices]) {
        if ([foundDevice.location isEqualToString:deviceLocation]) {
            device = foundDevice;
            break;
        }
    }
    if (!device) device = [[self sharedFoundDevices] objectAtIndex:0];
    return device;
}

- (void)activate {
    if ([[self sharedFoundDevices] count]) {
        wemoState = WEMO_STATE_CONNECTED;
    } else {
        wemoState = WEMO_STATE_CONNECTING;
        [self beginConnectingToWemo];
    }
    [self.delegate changeState:wemoState withMode:self];
}

- (void)deactivate {
    [[self sharedMulticastServer] deactivate];
}

#pragma mark - Connection

- (void)beginConnectingToWemo {
    wemoState = WEMO_STATE_CONNECTING;
    [self.delegate changeState:wemoState withMode:self];

    [[self sharedMulticastServer] beginbroadcast];
}

- (void)cancelConnectingToWemo {
    wemoState = WEMO_STATE_NOT_CONNECTED;
    [self.delegate changeState:wemoState withMode:self];
}


#pragma mark - Multicast delegate

- (void)foundDevice:(NSDictionary *)headers host:(NSString *)ipAddress port:(NSInteger)port {
    BOOL alreadyFound = NO;

    TTModeWemoDevice *newDevice = [[TTModeWemoDevice alloc] initWithIpAddress:ipAddress port:port];
    [newDevice setDelegate:self];
    
    for (TTModeWemoDevice *device in [self sharedFoundDevices]) {
        if ([device isEqualToDevice:newDevice]) {
            alreadyFound = YES;
            break;
        }
    }
    
    if (alreadyFound) return;
    
    [[self sharedFoundDevices] addObject:newDevice];

    [newDevice requestDeviceInfo];
}

#pragma mark - Device delegate

- (void)deviceReady:(id)device {
    // Device's name has been found, ready to display
    wemoState = WEMO_STATE_CONNECTED;
    [self.delegate changeState:wemoState withMode:self];
}

@end
