//
//  TTModeKasa.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasa.h"
#import <Security/Security.h>

NSString *const kKasaSelectedSerials = @"kasaSelectedSerials";
NSString *const kKasaFoundDevices = @"kasaFoundDevicesV1";

static NSString *const kKeychainService = @"com.turntouch.mac.kasa";

@interface TTModeKasa ()

@property (nonatomic, strong) NSMutableArray *failedDevices;

@end

@implementation TTModeKasa

static TTKasaState kasaState;
static NSMutableArray *foundDevices;
static NSMutableArray *recentlyFoundDevices;

- (instancetype)init {
    if (self = [super init]) {
        [[self sharedDiscovery] setDelegate:self];

        if (!recentlyFoundDevices) {
            recentlyFoundDevices = [NSMutableArray array];
        }

        if (foundDevices.count == 0) {
            [self assembleFoundDevices];
        }

        if (foundDevices.count == 0) {
            kasaState = KASA_STATE_CONNECTING;
            [self beginConnectingToKasa];
        } else {
            kasaState = KASA_STATE_CONNECTED;
            [self applyCredentialsToDevices];
        }

        self.failedDevices = [NSMutableArray array];

        [self.delegate changeState:TTModeKasa.kasaState withMode:self];
    }
    return self;
}

- (TTModeKasaDiscovery *)sharedDiscovery {
    static TTModeKasaDiscovery *discovery = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        discovery = [[TTModeKasaDiscovery alloc] init];
    });
    return discovery;
}

+ (TTKasaState)kasaState {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kasaState = KASA_STATE_NOT_CONNECTED;
    });
    return kasaState;
}

+ (void)setKasaState:(TTKasaState)state {
    @synchronized (self) {
        kasaState = state;
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

#pragma mark - Mode Info

+ (NSString *)title {
    return @"TP-Link Kasa";
}

+ (NSString *)description {
    return @"Smart plugs and switches";
}

+ (NSString *)imageName {
    return @"mode_wemo.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeKasaDeviceOn",
             @"TTModeKasaDeviceOff",
             @"TTModeKasaDeviceToggle"];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeKasaDeviceOn {
    return @"Turn on";
}

- (NSString *)titleTTModeKasaDeviceOff {
    return @"Turn off";
}

- (NSString *)titleTTModeKasaDeviceToggle {
    return @"Toggle device";
}

#pragma mark - Action Images

- (NSString *)imageTTModeKasaDeviceOn {
    return @"electrical_connected";
}

- (NSString *)imageTTModeKasaDeviceOff {
    return @"electrical_disconnected";
}

- (NSString *)imageTTModeKasaDeviceToggle {
    return @"electrical";
}

#pragma mark - Action Methods

- (void)runTTModeKasaDeviceOn:(TTModeDirection)direction {
    NSLog(@"Running TTModeKasaDeviceOn");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeKasaDevice *device in devices) {
        [device changeDeviceState:KASA_DEVICE_STATE_ON];
    }
}

- (void)runTTModeKasaDeviceOff:(TTModeDirection)direction {
    NSLog(@"Running TTModeKasaDeviceOff");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeKasaDevice *device in devices) {
        [device changeDeviceState:KASA_DEVICE_STATE_OFF];
    }
}

- (void)runTTModeKasaDeviceToggle:(TTModeDirection)direction {
    NSLog(@"Running TTModeKasaDeviceToggle");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeKasaDevice *device in devices) {
        [device requestDeviceState:^{
            if (device.deviceState == KASA_DEVICE_STATE_ON) {
                [device changeDeviceState:KASA_DEVICE_STATE_OFF];
            } else {
                [device changeDeviceState:KASA_DEVICE_STATE_ON];
            }
        }];
    }
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeKasaDeviceOn";
}

- (NSString *)defaultEast {
    return @"TTModeKasaDeviceToggle";
}

- (NSString *)defaultWest {
    return @"TTModeKasaDeviceToggle";
}

- (NSString *)defaultSouth {
    return @"TTModeKasaDeviceOff";
}

#pragma mark - Device Selection

- (NSArray *)selectedDevices:(TTModeDirection)direction {
    [self ensureDevicesSelected];
    NSMutableArray *devices = [NSMutableArray array];

    if (!foundDevices.count) return devices;

    NSArray *selectedIds = [self.action optionValue:kKasaSelectedSerials inDirection:direction];
    for (TTModeKasaDevice *foundDevice in foundDevices) {
        for (NSString *selectedId in selectedIds) {
            if ((foundDevice.deviceId && [foundDevice.deviceId isEqualToString:selectedId]) ||
                (foundDevice.macAddress && [foundDevice.macAddress isEqualToString:selectedId])) {
                [devices addObject:foundDevice];
            }
        }
    }

    return devices;
}

- (void)activate {
    [self.delegate changeState:kasaState withMode:self];
}

- (void)deactivate {
    [[self sharedDiscovery] deactivate];
}

#pragma mark - Connection

- (void)refreshDevices {
    recentlyFoundDevices = [NSMutableArray array];
    [self beginConnectingToKasa];
}

- (void)beginConnectingToKasa {
    kasaState = KASA_STATE_CONNECTING;
    [self.delegate changeState:kasaState withMode:self];

    [[self sharedDiscovery] setDelegate:self];
    [[self sharedDiscovery] beginDiscovery];
}

- (void)cancelConnectingToKasa {
    kasaState = KASA_STATE_CONNECTED;
    [self.delegate changeState:kasaState withMode:self];
}

- (void)resetKnownDevices {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kKasaFoundDevices];
    [prefs synchronize];

    foundDevices = [NSMutableArray array];
    [self assembleFoundDevices];
}

#pragma mark - Device Persistence

- (void)assembleFoundDevices {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    foundDevices = [NSMutableArray array];

    for (NSDictionary *deviceDict in [prefs arrayForKey:kKasaFoundDevices]) {
        TTModeKasaDevice *device = [TTModeKasaDevice fromDictionary:deviceDict];
        if (device) {
            device.delegate = self;
            [foundDevices addObject:device];
            NSLog(@" ---> Loading Kasa: %@ (%@)", device.deviceName, device.location);
        }
    }

    [self applyCredentialsToDevices];
}

- (void)storeFoundDevices {
    TTModeKasa.foundDevices = [foundDevices sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[[((TTModeKasaDevice *)obj1) deviceName] lowercaseString]
                compare:[[((TTModeKasaDevice *)obj2) deviceName] lowercaseString]];
    }];

    NSMutableArray *devices = [NSMutableArray array];
    NSMutableSet *savedIds = [NSMutableSet set];

    for (TTModeKasaDevice *device in foundDevices) {
        if (!device.deviceName) continue;

        NSString *uniqueId = device.deviceId ?: device.macAddress ?: device.location;
        if ([savedIds containsObject:uniqueId]) continue;
        [savedIds addObject:uniqueId];

        // Remove from failed list if working
        NSMutableArray *toRemove = [NSMutableArray array];
        for (TTModeKasaDevice *failedDevice in self.failedDevices) {
            if ([failedDevice isSameDeviceDifferentLocation:device]) {
                [toRemove addObject:failedDevice];
            }
        }
        [self.failedDevices removeObjectsInArray:toRemove];

        [devices addObject:[device toDictionary]];
    }

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:devices forKey:kKasaFoundDevices];
    [prefs synchronize];
}

#pragma mark - Credentials

+ (void)saveCredentialsUsername:(NSString *)username password:(NSString *)password {
    [self saveToKeychainKey:@"username" value:username];
    [self saveToKeychainKey:@"password" value:password];
}

+ (NSDictionary *)loadCredentials {
    NSString *username = [self loadFromKeychainKey:@"username"];
    NSString *password = [self loadFromKeychainKey:@"password"];
    if (username && password) {
        return @{@"username": username, @"password": password};
    }
    return nil;
}

+ (BOOL)hasCredentials {
    return [self loadCredentials] != nil;
}

+ (void)clearCredentials {
    [self deleteFromKeychainKey:@"username"];
    [self deleteFromKeychainKey:@"password"];
}

+ (BOOL)hasKLAPDevices {
    for (TTModeKasaDevice *device in foundDevices) {
        if (device.protocolType == KASA_PROTOCOL_KLAP) {
            return YES;
        }
    }
    return NO;
}

- (void)applyCredentialsToDevices {
    NSDictionary *creds = [TTModeKasa loadCredentials];
    if (!creds) return;

    for (TTModeKasaDevice *device in foundDevices) {
        if (device.protocolType == KASA_PROTOCOL_KLAP) {
            [device setCredentialsUsername:creds[@"username"] password:creds[@"password"]];
        }
    }
}

#pragma mark - Keychain Helpers

+ (void)saveToKeychainKey:(NSString *)key value:(NSString *)value {
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) return;

    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kKeychainService,
        (__bridge id)kSecAttrAccount: key
    };

    SecItemDelete((__bridge CFDictionaryRef)query);

    NSMutableDictionary *newQuery = [query mutableCopy];
    newQuery[(__bridge id)kSecValueData] = data;
    SecItemAdd((__bridge CFDictionaryRef)newQuery, nil);
}

+ (NSString *)loadFromKeychainKey:(NSString *)key {
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kKeychainService,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecReturnData: @YES
    };

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

    if (status == errSecSuccess && result) {
        NSData *data = (__bridge_transfer NSData *)result;
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (void)deleteFromKeychainKey:(NSString *)key {
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kKeychainService,
        (__bridge id)kSecAttrAccount: key
    };
    SecItemDelete((__bridge CFDictionaryRef)query);
}

#pragma mark - Discovery Delegate

- (TTModeKasaDevice *)discoveryFoundDeviceWithIpAddress:(NSString *)ipAddress
                                                   port:(UInt16)port
                                           protocolType:(TTKasaProtocolType)protocolType
                                                   name:(NSString *)name
                                               deviceId:(NSString *)deviceId
                                             macAddress:(NSString *)macAddress {
    TTModeKasaDevice *device = [[TTModeKasaDevice alloc] initWithIpAddress:ipAddress
                                                                     port:port
                                                             protocolType:protocolType];
    device.delegate = self;
    device.deviceName = name;
    device.deviceId = deviceId;
    device.macAddress = macAddress;

    // Check for duplicates
    for (TTModeKasaDevice *existingDevice in foundDevices) {
        if ([existingDevice isEqualToDevice:device]) {
            if ([existingDevice isSameDeviceDifferentLocation:device]) {
                NSLog(@" ---> Kasa: Device moved from %@ to %@", existingDevice.location, device.location);
                existingDevice.ipAddress = device.ipAddress;
                existingDevice.port = device.port;
            }
            return existingDevice;
        }
    }

    for (TTModeKasaDevice *existingDevice in recentlyFoundDevices) {
        if ([existingDevice isEqualToDevice:device]) {
            return existingDevice;
        }
    }

    [recentlyFoundDevices addObject:device];

    // Apply credentials if KLAP
    if (protocolType == KASA_PROTOCOL_KLAP) {
        NSDictionary *creds = [TTModeKasa loadCredentials];
        if (creds) {
            [device setCredentialsUsername:creds[@"username"] password:creds[@"password"]];
        }
    }

    // Request full device info
    [device requestDeviceInfo];

    return device;
}

- (void)discoveryFinishedScanning {
    kasaState = KASA_STATE_CONNECTED;
    [self.delegate changeState:kasaState withMode:self];
}

#pragma mark - Device Delegate

- (void)deviceReady:(TTModeKasaDevice *)device {
    TTModeKasaDevice *replaceDevice = nil;

    for (TTModeKasaDevice *foundDevice in foundDevices) {
        if ([foundDevice isSameAddress:device]) {
            return;
        } else if ([foundDevice isEqualToDevice:device] &&
                   [foundDevice isSameDeviceDifferentLocation:device]) {
            replaceDevice = foundDevice;
            break;
        }
    }

    if (replaceDevice) {
        NSLog(@" ---> Kasa: Re-assigning device from %@ to %@", replaceDevice.location, device.location);
        replaceDevice.ipAddress = device.ipAddress;
        replaceDevice.port = device.port;
    } else {
        [foundDevices addObject:device];
    }

    [self storeFoundDevices];

    kasaState = KASA_STATE_CONNECTED;
    [self.delegate changeState:kasaState withMode:self];
}

- (void)deviceFailed:(TTModeKasaDevice *)device {
    NSLog(@" ---> Kasa: Device %@ failed, searching for changed IP...", device);

    BOOL alreadyFailed = NO;
    for (TTModeKasaDevice *failedDevice in self.failedDevices) {
        if ([failedDevice isEqualToDevice:device]) {
            alreadyFailed = YES;
            break;
        }
    }

    if (!alreadyFailed) {
        [self.failedDevices addObject:device];
        [self.appDelegate.modeMap recordUsageMoment:@"kasaDeviceFailed"];
        [self refreshDevices];
    }
}

- (void)deviceNeedsAuthentication:(TTModeKasaDevice *)device {
    NSLog(@" ---> Kasa: Device needs authentication");
    [self.delegate changeState:kasaState withMode:self];
}

- (void)ensureDevicesSelected {
    if (foundDevices.count == 0) return;

    NSArray *selectedDevices = [self.action optionValue:kKasaSelectedSerials inDirection:self.action.direction];
    if (selectedDevices.count > 0) return;

    // Nothing selected, select everything
    NSMutableArray *ids = [NSMutableArray array];
    for (TTModeKasaDevice *device in foundDevices) {
        NSString *identifier = device.deviceId ?: device.macAddress;
        if (!identifier) continue;
        if ([ids containsObject:identifier]) continue;
        [ids addObject:identifier];
    }
    [self.action changeActionOption:kKasaSelectedSerials to:ids];
}

@end
