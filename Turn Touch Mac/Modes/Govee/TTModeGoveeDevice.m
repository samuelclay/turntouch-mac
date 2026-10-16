//
//  TTModeGoveeDevice.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGoveeDevice.h"

@implementation TTModeGoveeDevice

- (instancetype)initWithDeviceId:(NSString *)deviceId sku:(NSString *)sku deviceName:(NSString *)deviceName {
    if (self = [super init]) {
        self.deviceId = deviceId;
        self.sku = sku;
        self.deviceName = deviceName;
        self.deviceState = GOVEE_DEVICE_STATE_OFF;
        self.brightness = 100;
        self.capabilities = @[];
    }
    return self;
}

- (BOOL)supportsBrightness {
    for (NSDictionary *cap in self.capabilities) {
        if ([[cap objectForKey:@"type"] isEqualToString:@"devices.capabilities.range"] &&
            [[cap objectForKey:@"instance"] isEqualToString:@"brightness"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)supportsOnOff {
    for (NSDictionary *cap in self.capabilities) {
        if ([[cap objectForKey:@"type"] isEqualToString:@"devices.capabilities.on_off"] &&
            [[cap objectForKey:@"instance"] isEqualToString:@"powerSwitch"]) {
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)toDictionary {
    return @{
        @"deviceId": self.deviceId ?: @"",
        @"sku": self.sku ?: @"",
        @"deviceName": self.deviceName ?: @""
    };
}

+ (TTModeGoveeDevice *)fromDictionary:(NSDictionary *)dict {
    NSString *deviceId = dict[@"deviceId"];
    NSString *sku = dict[@"sku"];
    NSString *deviceName = dict[@"deviceName"];

    if (!deviceId || !sku || !deviceName) return nil;

    return [[TTModeGoveeDevice alloc] initWithDeviceId:deviceId sku:sku deviceName:deviceName];
}

@end
