//
//  TTModeGoveeDevice.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GOVEE_DEVICE_STATE_ON,
    GOVEE_DEVICE_STATE_OFF
} TTGoveeDeviceState;

@interface TTModeGoveeDevice : NSObject

@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *sku;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic) TTGoveeDeviceState deviceState;
@property (nonatomic) NSInteger brightness;
@property (nonatomic, strong) NSArray *capabilities;

- (instancetype)initWithDeviceId:(NSString *)deviceId sku:(NSString *)sku deviceName:(NSString *)deviceName;

- (BOOL)supportsBrightness;
- (BOOL)supportsOnOff;

- (NSDictionary *)toDictionary;
+ (TTModeGoveeDevice *)fromDictionary:(NSDictionary *)dict;

@end
