//
//  TTModeKasaLegacyProtocol.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

typedef enum {
    KASA_DEVICE_STATE_ON_VALUE = 1,
    KASA_DEVICE_STATE_OFF_VALUE = 0
} TTKasaRelayState;

@class TTModeKasaLegacyProtocol;

@protocol TTModeKasaLegacyProtocolDelegate <NSObject>

- (void)legacyProtocolDidReceiveDeviceInfoWithAlias:(NSString *)alias
                                           deviceId:(NSString *)deviceId
                                         macAddress:(NSString *)mac
                                         relayState:(NSInteger)relayState;
- (void)legacyProtocolDidReceiveState:(NSInteger)relayState;
- (void)legacyProtocolDidChangeState:(BOOL)success;
- (void)legacyProtocolDidFail:(NSError *)error;

@end

@interface TTModeKasaLegacyProtocol : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic, weak) id<TTModeKasaLegacyProtocolDelegate> delegate;

- (id)initWithIpAddress:(NSString *)ipAddress port:(UInt16)port;

- (void)requestDeviceInfo;
- (void)requestDeviceStateWithCallback:(void (^)(void))callback;
- (void)setRelayState:(NSInteger)state;

// Static encryption helpers for discovery
+ (NSData *)encrypt:(NSData *)plaintext;
+ (NSData *)decrypt:(NSData *)ciphertext;
+ (NSData *)encryptWithHeader:(NSData *)plaintext;

@end
