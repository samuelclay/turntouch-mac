//
//  TTModeKasa.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "TTModeKasaDiscovery.h"
#import "TTModeKasaDevice.h"

typedef enum TTKasaState : NSUInteger {
    KASA_STATE_NOT_CONNECTED,
    KASA_STATE_CONNECTING,
    KASA_STATE_CONNECTED
} TTKasaState;

@class TTModeKasa;

@protocol TTModeKasaDelegate <NSObject>
@required
- (void)changeState:(TTKasaState)kasaState withMode:(TTModeKasa *)modeKasa;
@end

@interface TTModeKasa : TTMode <TTModeKasaDiscoveryDelegate, TTModeKasaDeviceDelegate>

extern NSString *const kKasaSelectedSerials;
extern NSString *const kKasaFoundDevices;

@property (nonatomic, weak) id<TTModeKasaDelegate> delegate;

+ (TTKasaState)kasaState;
+ (void)setKasaState:(TTKasaState)state;
+ (NSMutableArray *)foundDevices;

- (void)resetKnownDevices;
- (void)refreshDevices;
- (void)beginConnectingToKasa;
- (void)cancelConnectingToKasa;
- (void)ensureDevicesSelected;

// Credentials
+ (void)saveCredentialsUsername:(NSString *)username password:(NSString *)password;
+ (NSDictionary *)loadCredentials;
+ (BOOL)hasCredentials;
+ (void)clearCredentials;
+ (BOOL)hasKLAPDevices;

@end
