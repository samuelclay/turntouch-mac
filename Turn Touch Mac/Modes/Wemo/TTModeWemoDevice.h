//
//  TTModeWemoDevice.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/23/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WEMO_DEVICE_STATE_ON,
    WEMO_DEVICE_STATE_OFF
} TTWemoDeviceState;

@class TTModeWemoDevice;

@protocol TTModeWemoDeviceDelegate <NSObject>

- (void)deviceReady:(TTModeWemoDevice *)device;

@end

@interface TTModeWemoDevice : NSObject

@property (nonatomic) NSString *deviceName;
@property (nonatomic) NSString *ipAddress;
@property (nonatomic) NSInteger port;
@property (nonatomic) TTWemoDeviceState deviceState;
@property (nonatomic) id<TTModeWemoDeviceDelegate> delegate;

- (id)initWithIpAddress:(NSString *)_ip port:(NSInteger)_port;
- (BOOL)isEqualToDevice:(TTModeWemoDevice *)device;
- (NSString *)location;

- (void)requestDeviceInfo;
- (void)requestDeviceState:(void (^)())callback;
- (void)changeDeviceState:(TTWemoDeviceState)state;

@end
