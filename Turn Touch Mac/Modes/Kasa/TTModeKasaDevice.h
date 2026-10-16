//
//  TTModeKasaDevice.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    KASA_PROTOCOL_LEGACY,
    KASA_PROTOCOL_KLAP
} TTKasaProtocolType;

typedef enum {
    KASA_DEVICE_STATE_ON,
    KASA_DEVICE_STATE_OFF
} TTKasaDeviceState;

@class TTModeKasaDevice;

@protocol TTModeKasaDeviceDelegate <NSObject>

- (void)deviceReady:(TTModeKasaDevice *)device;
- (void)deviceFailed:(TTModeKasaDevice *)device;
- (void)deviceNeedsAuthentication:(TTModeKasaDevice *)device;

@end

@interface TTModeKasaDevice : NSObject

@property (nonatomic) NSString *deviceName;
@property (nonatomic) NSString *deviceId;
@property (nonatomic) NSString *macAddress;
@property (nonatomic) NSString *ipAddress;
@property (nonatomic) UInt16 port;
@property (nonatomic) TTKasaProtocolType protocolType;
@property (nonatomic) TTKasaDeviceState deviceState;
@property (nonatomic) BOOL needsAuthentication;
@property (nonatomic) BOOL isAuthenticated;
@property (nonatomic, weak) id<TTModeKasaDeviceDelegate> delegate;

- (id)initWithIpAddress:(NSString *)ipAddress port:(UInt16)port protocolType:(TTKasaProtocolType)protocolType;

- (BOOL)isEqualToDevice:(TTModeKasaDevice *)device;
- (BOOL)isSameAddress:(TTModeKasaDevice *)device;
- (BOOL)isSameDeviceDifferentLocation:(TTModeKasaDevice *)device;
- (NSString *)location;

- (void)setCredentialsUsername:(NSString *)username password:(NSString *)password;
- (void)requestDeviceInfo;
- (void)requestDeviceState:(void (^)(void))callback;
- (void)changeDeviceState:(TTKasaDeviceState)state;

- (NSDictionary *)toDictionary;
+ (TTModeKasaDevice *)fromDictionary:(NSDictionary *)dict;

@end
