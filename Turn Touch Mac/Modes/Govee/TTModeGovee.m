//
//  TTModeGovee.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGovee.h"
#import <Security/Security.h>

NSString *const kGoveeSelectedDevices = @"goveeSelectedDevices";
NSString *const kGoveeFoundDevices = @"goveeFoundDevicesV1";
NSInteger const kGoveeBrightnessStep = 25;

static NSString *const kKeychainService = @"com.turntouch.mac.govee";

@implementation TTModeGovee

static TTGoveeState goveeState;
static NSMutableArray<TTModeGoveeDevice *> *foundDevices;
static TTModeGoveeAPIClient *apiClient;

- (instancetype)init {
    if (self = [super init]) {
        if (!apiClient) {
            apiClient = [[TTModeGoveeAPIClient alloc] init];
        }
        apiClient.delegate = self;

        if (foundDevices.count == 0) {
            [self assembleFoundDevices];
        }

        NSString *savedApiKey = [TTModeGovee loadApiKey];
        if (savedApiKey) {
            [apiClient setApiKey:savedApiKey];

            if (foundDevices.count == 0) {
                NSLog(@" ---> Govee: No devices, fetching from API");
                goveeState = GOVEE_STATE_CONNECTING;
                [self beginConnectingToGovee];
            } else {
                NSLog(@" ---> Govee: Have %lu devices, setting connected", (unsigned long)foundDevices.count);
                goveeState = GOVEE_STATE_CONNECTED;
            }
        } else {
            NSLog(@" ---> Govee: No API key, setting disconnected");
            goveeState = GOVEE_STATE_NOT_CONNECTED;
        }

        [self.delegate changeState:goveeState withMode:self];
    }
    return self;
}

+ (TTGoveeState)goveeState {
    return goveeState;
}

+ (void)setGoveeState:(TTGoveeState)state {
    @synchronized (self) {
        goveeState = state;
    }
}

+ (NSMutableArray<TTModeGoveeDevice *> *)foundDevices {
    if (!foundDevices) {
        foundDevices = [NSMutableArray array];
    }
    return foundDevices;
}

+ (TTModeGoveeAPIClient *)apiClient {
    if (!apiClient) {
        apiClient = [[TTModeGoveeAPIClient alloc] init];
    }
    return apiClient;
}

#pragma mark - Mode Info

+ (NSString *)title {
    return @"Govee";
}

+ (NSString *)description {
    return @"Smart lights and devices";
}

+ (NSString *)imageName {
    return @"mode_govee.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeGoveeDeviceOn",
             @"TTModeGoveeDeviceOff",
             @"TTModeGoveeDeviceToggle",
             @"TTModeGoveeBrightnessUp",
             @"TTModeGoveeBrightnessDown"];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeGoveeDeviceOn {
    return @"Turn on";
}

- (NSString *)titleTTModeGoveeDeviceOff {
    return @"Turn off";
}

- (NSString *)titleTTModeGoveeDeviceToggle {
    return @"Toggle device";
}

- (NSString *)titleTTModeGoveeBrightnessUp {
    return @"Brightness up";
}

- (NSString *)titleTTModeGoveeBrightnessDown {
    return @"Brightness down";
}

#pragma mark - Action Images

- (NSString *)imageTTModeGoveeDeviceOn {
    return @"hue_on";
}

- (NSString *)imageTTModeGoveeDeviceOff {
    return @"hue_off";
}

- (NSString *)imageTTModeGoveeDeviceToggle {
    return @"electrical";
}

- (NSString *)imageTTModeGoveeBrightnessUp {
    return @"hue_brightness";
}

- (NSString *)imageTTModeGoveeBrightnessDown {
    return @"hue_brightness";
}

#pragma mark - Action Methods

- (void)runTTModeGoveeDeviceOn:(TTModeDirection)direction {
    NSLog(@"Running TTModeGoveeDeviceOn");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeGoveeDevice *device in devices) {
        [apiClient controlDevice:device turnOn:YES];
        device.deviceState = GOVEE_DEVICE_STATE_ON;
    }
}

- (void)runTTModeGoveeDeviceOff:(TTModeDirection)direction {
    NSLog(@"Running TTModeGoveeDeviceOff");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeGoveeDevice *device in devices) {
        [apiClient controlDevice:device turnOn:NO];
        device.deviceState = GOVEE_DEVICE_STATE_OFF;
    }
}

- (void)runTTModeGoveeDeviceToggle:(TTModeDirection)direction {
    NSLog(@"Running TTModeGoveeDeviceToggle");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeGoveeDevice *device in devices) {
        apiClient.delegate = self;
        [apiClient fetchDeviceState:device];
    }
}

- (void)runTTModeGoveeBrightnessUp:(TTModeDirection)direction {
    NSLog(@"Running TTModeGoveeBrightnessUp");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeGoveeDevice *device in devices) {
        NSInteger newBrightness = MIN(100, device.brightness + kGoveeBrightnessStep);
        [apiClient setBrightness:device brightness:newBrightness];
        device.brightness = newBrightness;
    }
}

- (void)runTTModeGoveeBrightnessDown:(TTModeDirection)direction {
    NSLog(@"Running TTModeGoveeBrightnessDown");
    NSArray *devices = [self selectedDevices:direction];
    for (TTModeGoveeDevice *device in devices) {
        NSInteger newBrightness = MAX(1, device.brightness - kGoveeBrightnessStep);
        [apiClient setBrightness:device brightness:newBrightness];
        device.brightness = newBrightness;
    }
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeGoveeDeviceOn";
}

- (NSString *)defaultEast {
    return @"TTModeGoveeBrightnessUp";
}

- (NSString *)defaultWest {
    return @"TTModeGoveeBrightnessDown";
}

- (NSString *)defaultSouth {
    return @"TTModeGoveeDeviceOff";
}

#pragma mark - Activation

- (void)activate {
    [self.delegate changeState:goveeState withMode:self];
}

- (void)deactivate {
    // No persistent connections to clean up
}

#pragma mark - Device Selection

- (NSArray<TTModeGoveeDevice *> *)selectedDevices:(TTModeDirection)direction {
    [self ensureDevicesSelected];
    NSMutableArray *devices = [NSMutableArray array];

    if (!foundDevices.count) return devices;

    NSArray *selectedIds = [self.action optionValue:kGoveeSelectedDevices inDirection:direction];
    for (TTModeGoveeDevice *foundDevice in foundDevices) {
        for (NSString *selectedId in selectedIds) {
            if ([foundDevice.deviceId isEqualToString:selectedId]) {
                [devices addObject:foundDevice];
            }
        }
    }

    return devices;
}

- (void)ensureDevicesSelected {
    if (foundDevices.count == 0) return;

    NSArray *selectedDevices = [self.action optionValue:kGoveeSelectedDevices inDirection:self.action.direction];
    if (selectedDevices.count > 0) return;

    // Nothing selected, select everything
    NSMutableArray *ids = [NSMutableArray array];
    for (TTModeGoveeDevice *device in foundDevices) {
        if (device.deviceId && ![ids containsObject:device.deviceId]) {
            [ids addObject:device.deviceId];
        }
    }
    [self.action changeActionOption:kGoveeSelectedDevices to:ids];
}

#pragma mark - Connection

- (void)refreshDevices {
    [self beginConnectingToGovee];
}

- (void)beginConnectingToGovee {
    NSLog(@" ---> Govee: beginConnectingToGovee CALLED");
    goveeState = GOVEE_STATE_CONNECTING;
    [self.delegate changeState:goveeState withMode:self];

    if ([self.delegate respondsToSelector:@selector(fetchStatusUpdate:)]) {
        [self.delegate fetchStatusUpdate:@"Fetching devices from Govee..."];
    }

    apiClient.delegate = self;
    [apiClient fetchDevices];
}

- (void)cancelConnectingToGovee {
    goveeState = GOVEE_STATE_CONNECTED;
    [self.delegate changeState:goveeState withMode:self];
}

- (void)resetKnownDevices {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kGoveeFoundDevices];
    [prefs synchronize];

    foundDevices = [NSMutableArray array];
}

#pragma mark - Device Persistence

- (void)assembleFoundDevices {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    foundDevices = [NSMutableArray array];

    for (NSDictionary *deviceDict in [prefs arrayForKey:kGoveeFoundDevices]) {
        TTModeGoveeDevice *device = [TTModeGoveeDevice fromDictionary:deviceDict];
        if (device) {
            [foundDevices addObject:device];
            NSLog(@" ---> Govee: Loaded device: %@", device.deviceName);
        }
    }
}

- (void)storeFoundDevices {
    [foundDevices sortUsingComparator:^NSComparisonResult(TTModeGoveeDevice *a, TTModeGoveeDevice *b) {
        return [a.deviceName.lowercaseString compare:b.deviceName.lowercaseString];
    }];

    NSMutableArray *savedDevices = [NSMutableArray array];
    NSMutableSet *savedIds = [NSMutableSet set];

    for (TTModeGoveeDevice *device in foundDevices) {
        if (!device.deviceId || [savedIds containsObject:device.deviceId]) continue;
        [savedIds addObject:device.deviceId];
        [savedDevices addObject:[device toDictionary]];
    }

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:savedDevices forKey:kGoveeFoundDevices];
    [prefs synchronize];
}

#pragma mark - API Key Management

+ (void)saveApiKey:(NSString *)apiKey {
    [self saveToKeychainKey:@"apiKey" value:apiKey];
}

+ (NSString *)loadApiKey {
    return [self loadFromKeychainKey:@"apiKey"];
}

+ (BOOL)hasApiKey {
    return [self loadApiKey] != nil;
}

+ (void)clearApiKey {
    [self deleteFromKeychainKey:@"apiKey"];
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

#pragma mark - API Client Delegate

- (void)apiClientDidFetchDevices:(NSArray<TTModeGoveeDevice *> *)devices {
    NSLog(@" ---> Govee: Received %lu devices from API", (unsigned long)devices.count);

    foundDevices = [devices mutableCopy];
    [self storeFoundDevices];

    goveeState = GOVEE_STATE_CONNECTED;
    [self.delegate changeState:goveeState withMode:self];

    if ([self.delegate respondsToSelector:@selector(fetchStatusUpdate:)]) {
        [self.delegate fetchStatusUpdate:[NSString stringWithFormat:@"Found %lu devices", (unsigned long)devices.count]];
    }
}

- (void)apiClientDidFailWithError:(NSString *)error {
    NSLog(@" ---> Govee: API error: %@", error);

    if ([error isEqualToString:@"Invalid API key"]) {
        goveeState = GOVEE_STATE_NOT_CONNECTED;
    } else {
        goveeState = GOVEE_STATE_CONNECTED;
    }

    [self.delegate changeState:goveeState withMode:self];

    if ([self.delegate respondsToSelector:@selector(fetchStatusUpdate:)]) {
        [self.delegate fetchStatusUpdate:[NSString stringWithFormat:@"Error: %@", error]];
    }
}

- (void)apiClientDidControlDevice:(BOOL)success error:(NSString *)error {
    if (error) {
        NSLog(@" ---> Govee: Control failed: %@", error);
    } else {
        NSLog(@" ---> Govee: Control succeeded");
    }
}

- (void)apiClientDidFetchDeviceState:(TTModeGoveeDevice *)device
                          powerState:(NSNumber *)powerState
                          brightness:(NSNumber *)brightness {
    if (powerState) {
        device.deviceState = powerState.integerValue == 1 ? GOVEE_DEVICE_STATE_ON : GOVEE_DEVICE_STATE_OFF;
        // Toggle: flip the state
        BOOL turnOn = (device.deviceState == GOVEE_DEVICE_STATE_OFF);
        [apiClient controlDevice:device turnOn:turnOn];
        device.deviceState = turnOn ? GOVEE_DEVICE_STATE_ON : GOVEE_DEVICE_STATE_OFF;
    }
    if (brightness) {
        device.brightness = brightness.integerValue;
    }
}

@end
