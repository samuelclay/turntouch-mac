//
//  TTModeGoveeAPIClient.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTModeGoveeDevice.h"

@protocol TTModeGoveeAPIClientDelegate <NSObject>

- (void)apiClientDidFetchDevices:(NSArray<TTModeGoveeDevice *> *)devices;
- (void)apiClientDidFailWithError:(NSString *)error;
- (void)apiClientDidControlDevice:(BOOL)success error:(NSString *)error;
- (void)apiClientDidFetchDeviceState:(TTModeGoveeDevice *)device
                          powerState:(NSNumber *)powerState
                          brightness:(NSNumber *)brightness;

@end

@interface TTModeGoveeAPIClient : NSObject

@property (nonatomic, weak) id<TTModeGoveeAPIClientDelegate> delegate;

- (void)setApiKey:(NSString *)apiKey;
- (void)fetchDevices;
- (void)controlDevice:(TTModeGoveeDevice *)device turnOn:(BOOL)turnOn;
- (void)setBrightness:(TTModeGoveeDevice *)device brightness:(NSInteger)brightness;
- (void)fetchDeviceState:(TTModeGoveeDevice *)device;

@end
