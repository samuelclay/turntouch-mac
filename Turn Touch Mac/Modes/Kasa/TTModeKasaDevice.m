//
//  TTModeKasaDevice.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasaDevice.h"
#import "TTModeKasaLegacyProtocol.h"
#import "TTModeKasaKLAPProtocol.h"

@interface TTModeKasaDevice () <TTModeKasaLegacyProtocolDelegate, TTModeKasaKLAPProtocolDelegate>

@property (nonatomic, strong) TTModeKasaLegacyProtocol *legacyProtocol;
@property (nonatomic, strong) TTModeKasaKLAPProtocol *klapProtocol;

@end

@implementation TTModeKasaDevice

- (id)initWithIpAddress:(NSString *)ipAddress port:(UInt16)port protocolType:(TTKasaProtocolType)protocolType {
    if (self = [super init]) {
        self.ipAddress = ipAddress;
        self.port = port;
        self.protocolType = protocolType;
        self.deviceState = KASA_DEVICE_STATE_OFF;
        self.needsAuthentication = NO;
        self.isAuthenticated = NO;

        [self setupProtocol];
    }
    return self;
}

- (void)setupProtocol {
    switch (self.protocolType) {
        case KASA_PROTOCOL_LEGACY:
            self.legacyProtocol = [[TTModeKasaLegacyProtocol alloc] initWithIpAddress:self.ipAddress
                                                                                 port:self.port];
            self.legacyProtocol.delegate = self;
            break;
        case KASA_PROTOCOL_KLAP:
            self.klapProtocol = [[TTModeKasaKLAPProtocol alloc] initWithIpAddress:self.ipAddress
                                                                             port:80];
            self.klapProtocol.delegate = self;
            self.needsAuthentication = YES;
            break;
    }
}

#pragma mark - Description

- (NSString *)description {
    NSString *name = self.deviceName ?: @"Unknown";
    NSString *proto = (self.protocolType == KASA_PROTOCOL_LEGACY) ? @"Legacy" : @"KLAP";
    return [NSString stringWithFormat:@"%@ (%@ - %@)", name, self.location, proto];
}

- (NSString *)location {
    return [NSString stringWithFormat:@"%@:%d", self.ipAddress, self.port];
}

#pragma mark - Comparison

- (BOOL)isEqualToDevice:(TTModeKasaDevice *)device {
    if (self.deviceId && device.deviceId) {
        return [self.deviceId isEqualToString:device.deviceId];
    }
    if (self.macAddress && device.macAddress) {
        return [[self.macAddress lowercaseString] isEqualToString:[device.macAddress lowercaseString]];
    }
    return NO;
}

- (BOOL)isSameAddress:(TTModeKasaDevice *)device {
    return [self.ipAddress isEqualToString:device.ipAddress] && self.port == device.port;
}

- (BOOL)isSameDeviceDifferentLocation:(TTModeKasaDevice *)device {
    return [self isEqualToDevice:device] && ![self isSameAddress:device];
}

#pragma mark - Credentials

- (void)setCredentialsUsername:(NSString *)username password:(NSString *)password {
    [self.klapProtocol setCredentialsUsername:username password:password];
}

#pragma mark - Device Info

- (void)requestDeviceInfo {
    switch (self.protocolType) {
        case KASA_PROTOCOL_LEGACY:
            [self.legacyProtocol requestDeviceInfo];
            break;
        case KASA_PROTOCOL_KLAP:
            [self.klapProtocol requestDeviceInfo];
            break;
    }
}

#pragma mark - Device State

- (void)requestDeviceState:(void (^)(void))callback {
    switch (self.protocolType) {
        case KASA_PROTOCOL_LEGACY:
            [self.legacyProtocol requestDeviceStateWithCallback:callback];
            break;
        case KASA_PROTOCOL_KLAP:
            [self.klapProtocol requestDeviceInfo];
            // KLAP device info includes the state
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                          dispatch_get_main_queue(), ^{
                callback();
            });
            break;
    }
}

- (void)changeDeviceState:(TTKasaDeviceState)state {
    NSLog(@" ---> Kasa: Changing %@ to %@",
          self.deviceName ?: self.location,
          state == KASA_DEVICE_STATE_ON ? @"ON" : @"OFF");

    switch (self.protocolType) {
        case KASA_PROTOCOL_LEGACY:
            [self.legacyProtocol setRelayState:(state == KASA_DEVICE_STATE_ON ? 1 : 0)];
            break;
        case KASA_PROTOCOL_KLAP:
            [self.klapProtocol setDeviceState:(state == KASA_DEVICE_STATE_ON)];
            break;
    }
}

#pragma mark - Serialization

- (NSDictionary *)toDictionary {
    return @{
        @"ipaddress": self.ipAddress ?: @"",
        @"port": @(self.port),
        @"protocolType": (self.protocolType == KASA_PROTOCOL_LEGACY) ? @"legacy" : @"klap",
        @"name": self.deviceName ?: @"",
        @"deviceId": self.deviceId ?: @"",
        @"macAddress": self.macAddress ?: @""
    };
}

+ (TTModeKasaDevice *)fromDictionary:(NSDictionary *)dict {
    NSString *ipAddress = dict[@"ipaddress"];
    if (!ipAddress) return nil;

    NSNumber *portNum = dict[@"port"];
    if (!portNum) return nil;
    UInt16 port = [portNum unsignedShortValue];

    NSString *protocolTypeString = dict[@"protocolType"] ?: @"legacy";
    TTKasaProtocolType protocolType = [protocolTypeString isEqualToString:@"klap"]
                                      ? KASA_PROTOCOL_KLAP : KASA_PROTOCOL_LEGACY;

    TTModeKasaDevice *device = [[TTModeKasaDevice alloc] initWithIpAddress:ipAddress
                                                                     port:port
                                                             protocolType:protocolType];
    device.deviceName = dict[@"name"];
    device.deviceId = dict[@"deviceId"];
    device.macAddress = dict[@"macAddress"];

    return device;
}

#pragma mark - Legacy Protocol Delegate

- (void)legacyProtocolDidReceiveDeviceInfoWithAlias:(NSString *)alias
                                           deviceId:(NSString *)deviceId
                                         macAddress:(NSString *)mac
                                         relayState:(NSInteger)relayState {
    self.deviceName = alias ?: @"Kasa Device";
    self.deviceId = deviceId;
    self.macAddress = mac;
    self.deviceState = (relayState == 1 || relayState == 8) ? KASA_DEVICE_STATE_ON : KASA_DEVICE_STATE_OFF;

    NSLog(@" ---> Kasa Legacy: Device info received for %@", self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate deviceReady:self];
    });
}

- (void)legacyProtocolDidReceiveState:(NSInteger)relayState {
    self.deviceState = (relayState == 1 || relayState == 8) ? KASA_DEVICE_STATE_ON : KASA_DEVICE_STATE_OFF;
}

- (void)legacyProtocolDidChangeState:(BOOL)success {
    NSLog(@" ---> Kasa Legacy: State change %@", success ? @"successful" : @"failed");
}

- (void)legacyProtocolDidFail:(NSError *)error {
    NSLog(@" ---> Kasa Legacy: Protocol failed - %@", error.localizedDescription ?: @"unknown error");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate deviceFailed:self];
    });
}

#pragma mark - KLAP Protocol Delegate

- (void)klapProtocolDidReceiveDeviceInfoWithNickname:(NSString *)nickname
                                            deviceId:(NSString *)deviceId
                                          macAddress:(NSString *)mac
                                            deviceOn:(BOOL)deviceOn
                                               model:(NSString *)model {
    self.deviceName = nickname ?: model ?: @"Kasa Device";
    self.deviceId = deviceId;
    self.macAddress = mac;
    self.deviceState = deviceOn ? KASA_DEVICE_STATE_ON : KASA_DEVICE_STATE_OFF;
    self.isAuthenticated = YES;
    self.needsAuthentication = NO;

    NSLog(@" ---> Kasa KLAP: Device info received for %@", self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate deviceReady:self];
    });
}

- (void)klapProtocolDidReceiveState:(BOOL)deviceOn {
    self.deviceState = deviceOn ? KASA_DEVICE_STATE_ON : KASA_DEVICE_STATE_OFF;
}

- (void)klapProtocolDidChangeState:(BOOL)success {
    NSLog(@" ---> Kasa KLAP: State change %@", success ? @"successful" : @"failed");
}

- (void)klapProtocolDidFail:(NSError *)error {
    NSLog(@" ---> Kasa KLAP: Protocol failed - %@", error.localizedDescription ?: @"unknown error");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate deviceFailed:self];
    });
}

- (void)klapProtocolNeedsAuthentication {
    self.needsAuthentication = YES;
    self.isAuthenticated = NO;
    NSLog(@" ---> Kasa KLAP: Device needs authentication");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate deviceNeedsAuthentication:self];
    });
}

@end
