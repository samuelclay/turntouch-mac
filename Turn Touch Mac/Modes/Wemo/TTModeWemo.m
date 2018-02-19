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

NSString *const kWemoSelectedSerials = @"wemoSelectedSerials";
NSString *const kWemoFoundDevices = @"wemoFoundDevicesV2";
NSString *const kWemoSeenDevices = @"wemoSeenDevicesV2";

static TTWemoState wemoState;
static NSMutableArray *foundDevices;
static NSMutableArray *recentlyFoundDevices;

//@synthesize foundDevices;
//@synthesize multicastServer;
@synthesize delegate;

- (instancetype)init {
    if (self = [super init]) {
//        foundDevices = [NSMutableArray array];
//        multicastServer = [[TTModeWemoMulticastServer alloc] init];
        [[self sharedMulticastServer] setDelegate:self];

        if (!recentlyFoundDevices) {
            recentlyFoundDevices = [NSMutableArray array];
        }

        if (foundDevices.count == 0) {
            [self assembleFoundDevices];
        }
        
        if (foundDevices.count == 0) {
            wemoState = WEMO_STATE_CONNECTING;
            [self beginConnectingToWemo];
        } else {
            wemoState = WEMO_STATE_CONNECTED;
        }
        
        failedDevices = [NSMutableArray array];
        
        [self.delegate changeState:TTModeWemo.wemoState withMode:self];
    }
    
    return self;
}

- (void)resetKnownDevices {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kWemoFoundDevices];
    [prefs synchronize];
    
    [self assembleFoundDevices];
}

- (void)assembleFoundDevices {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    foundDevices = [NSMutableArray array];
    
    for (NSDictionary *device in [prefs arrayForKey:kWemoFoundDevices]) {
        TTModeWemoDevice *newDevice = [self foundDevice:nil host:[device objectForKey:@"ipaddress"]
                                                   port:[[device objectForKey:@"port"] integerValue]
                                                   name:[device objectForKey:@"name"]
                                           serialNumber:[device objectForKey:@"serialNumber"]
                                             macAddress:[device objectForKey:@"macAddress"]
                                                   live:NO];
        NSLog(@" ---> Loading wemo: %@ (%@)", newDevice.deviceName, newDevice.location);
    }
}

- (TTModeWemoMulticastServer *)sharedMulticastServer {
    static TTModeWemoMulticastServer *multicastServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        multicastServer = [[TTModeWemoMulticastServer alloc] init];
    });
    return multicastServer;
}

+ (TTWemoState)wemoState {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wemoState = WEMO_STATE_NOT_CONNECTED;
    });
    return wemoState;
}

+ (void)setWemoState:(TTWemoState)state {
    @synchronized (self) {
        wemoState = state;
    }
}

+ (NSMutableArray *)foundDevices {
    return foundDevices;
}

+ (void)setFoundDevices:(NSArray *)devices {
    foundDevices = [devices mutableCopy];
}

+ (NSMutableArray *)recentlyFoundDevices {
    return recentlyFoundDevices;
}

+ (void)setRecentlyFoundDevices:(NSArray *)devices {
    recentlyFoundDevices = [devices mutableCopy];
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
    return @"electrical_connected";
}
- (NSString *)imageTTModeWemoDeviceOff {
    return @"electrical_disconnected";
}
- (NSString *)imageTTModeWemoDeviceToggle {
    return @"electrical";
}

#pragma mark - Action methods

- (void)runTTModeWemoDeviceOn:(TTModeDirection)direction {
    NSLog(@"Running TTModeWemoDeviceOn");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeWemoDevice *device in devices) {
        [device changeDeviceState:WEMO_DEVICE_STATE_ON];
    }
}

- (void)runTTModeWemoDeviceOff:(TTModeDirection)direction {
    NSLog(@"Running TTModeWemoDeviceOff");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeWemoDevice *device in devices) {
        [device changeDeviceState:WEMO_DEVICE_STATE_OFF];
    }
}
- (void)runTTModeWemoDeviceToggle:(TTModeDirection)direction {
    NSLog(@"Running TTModeWemoDeviceToggle");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeWemoDevice *device in devices) {
        [device requestDeviceState:^() {
            if (device.deviceState == WEMO_DEVICE_STATE_ON) {
                [device changeDeviceState:WEMO_DEVICE_STATE_OFF];
            } else {
                [device changeDeviceState:WEMO_DEVICE_STATE_ON];
            }
        }];
    }
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

- (NSArray *)selectedDevices:(TTModeDirection)direction {
    [self ensureDevicesSelected];
    NSMutableArray *devices = [NSMutableArray array];
    
    if (!foundDevices.count) return devices;
    
    NSArray *selectedDevices = [self.action optionValue:kWemoSelectedSerials inDirection:direction];
    for (TTModeWemoDevice *foundDevice in foundDevices) {
        for (NSString *serialNumber in selectedDevices) {
            if ([foundDevice.serialNumber isEqualToString:serialNumber]) {
                [devices addObject:foundDevice];
            }
        }
    }
    
    return devices;
}

- (void)activate {
    [self.delegate changeState:wemoState withMode:self];
}

- (void)deactivate {
    [[self sharedMulticastServer] deactivate];
}

#pragma mark - Connection

- (void)refreshDevices {
    recentlyFoundDevices = [NSMutableArray array];
    [self beginConnectingToWemo];
}

- (void)beginConnectingToWemo {
    wemoState = WEMO_STATE_CONNECTING;
    [self.delegate changeState:wemoState withMode:self];

    [[self sharedMulticastServer] setDelegate:self];
    [[self sharedMulticastServer] beginbroadcast];
}

- (void)cancelConnectingToWemo {
    wemoState = WEMO_STATE_CONNECTED;
    [self.delegate changeState:wemoState withMode:self];
}


#pragma mark - Multicast delegate

- (TTModeWemoDevice *)foundDevice:(NSDictionary *)headers host:(NSString *)ipAddress port:(NSInteger)port
                             name:(NSString *)name serialNumber:(NSString *)serialNumber macAddress:(NSString *)macAddress live:(BOOL)live {
    TTModeWemoDevice *newDevice = [[TTModeWemoDevice alloc] initWithIpAddress:ipAddress port:port];
    [newDevice setDelegate:self];
    
    newDevice.deviceName = name;
    newDevice.serialNumber = serialNumber;
    newDevice.macAddress = macAddress;
    
    for (TTModeWemoDevice *device in foundDevices) {
        if ([device isEqualToDevice:newDevice]) {
            // Already found
            return device;
        }
    }
    for (TTModeWemoDevice *device in recentlyFoundDevices) {
        if ([device isEqualToDevice:newDevice]) {
//            return device;
        }
    }
    
    if (newDevice.deviceName != nil && newDevice.serialNumber != nil) {
        [foundDevices addObject:newDevice];
    }
    [recentlyFoundDevices addObject:newDevice];
    
    [newDevice requestDeviceInfo];
    
    return newDevice;
}

- (void)finishScanning {
    wemoState = WEMO_STATE_CONNECTED;
    [self.delegate changeState:wemoState withMode:self];
    
    
}

#pragma mark - Device delegate

- (void)deviceReady:(TTModeWemoDevice *)device {
    TTModeWemoDevice *replaceDevice;
    // Device's name has been found, ready to display
    for (TTModeWemoDevice *foundDevice in TTModeWemo.foundDevices) {
        if ([foundDevice isSameAddress:device]) {
            return;
        } else if ([foundDevice isEqualToDevice:device] &&
                   [foundDevice isSameDeviceDifferentLocation:device]) {
            // Wemo device changed IPs (very common), so correct all references and
            // store new IP in place of old
            replaceDevice = foundDevice;
            break;
        }
    }
    
    if (replaceDevice) {
        NSLog(@" ---> Reassigning wemo device from %@ to %@", replaceDevice.location, device.location);
        replaceDevice.ipAddress = device.ipAddress;
        replaceDevice.port = device.port;
    } else {
        [foundDevices addObject:device];
    }
    
    [self storeFoundDevices];
    
    wemoState = WEMO_STATE_CONNECTED;
    [self.delegate changeState:wemoState withMode:self];
}

- (void)storeFoundDevices {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    TTModeWemo.foundDevices = [foundDevices sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [[[((TTModeWemoDevice *)obj1) deviceName] lowercaseString]
                compare:[[((TTModeWemoDevice *)obj2) deviceName] lowercaseString]];
    }];
    
    NSMutableArray *devices = [NSMutableArray array];
    NSMutableArray *foundSerials = [NSMutableArray array];
    for (TTModeWemoDevice *device in foundDevices) {
        if (device.deviceName == nil || device.serialNumber == nil) {
            continue;
        }
        
        if (![foundSerials containsObject:device.serialNumber]) {
            [foundSerials addObject:device.serialNumber];
        } else {
            continue;
        }
        
        for (TTModeWemoDevice *failedDevice in failedDevices) {
            if ([failedDevice isSameDeviceDifferentLocation:device]) {
                [failedDevices removeObject:device];
                break;
            }
        }
        
        [devices addObject:@{@"ipaddress": device.ipAddress,
                             @"port": [NSNumber numberWithInteger:device.port],
                             @"name": device.deviceName,
                             @"serialNumber": device.serialNumber,
                             @"macAddress": device.macAddress,
                             }];
    }
    
    [prefs setObject:devices forKey:kWemoFoundDevices];
    [prefs synchronize];
}

- (void)deviceFailed:(TTModeWemoDevice *)device {
    NSLog(@" ---> Wemo device %@ failed, searching for changed IP...", device);
    
    if ([failedDevices containsObject:device]) {
        NSLog(@" ---> Wemo device %@ already failed and searching, ignoring.", device);
        return;
    }

    [appDelegate.modeMap recordUsageMoment:@"wemoDeviceFailed"];
    [failedDevices addObject:device];
    [self refreshDevices];
}

- (void)ensureDevicesSelected {
    if (TTModeWemo.foundDevices.count == 0) {
        return;
    }
    
    NSArray *selectedDevices = [self.action optionValue:kWemoSelectedSerials inDirection:self.action.direction];
    if (selectedDevices.count > 0) {
        return;
    }
    
    // Nothing selected, so select everything
    NSMutableArray *locations = [NSMutableArray array];
    for (TTModeWemoDevice *device in TTModeWemo.foundDevices) {
        if (device.serialNumber == nil) continue; // Not ready yet
        if ([locations containsObject:device.serialNumber]) continue;
        [locations addObject:device.serialNumber];
    }
    [self.action changeActionOption:kWemoSelectedSerials to:locations];
}

@end
