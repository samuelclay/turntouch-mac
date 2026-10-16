//
//  TTModeGovee.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "TTModeGoveeDevice.h"
#import "TTModeGoveeAPIClient.h"

typedef enum TTGoveeState : NSUInteger {
    GOVEE_STATE_NOT_CONNECTED,
    GOVEE_STATE_CONNECTING,
    GOVEE_STATE_CONNECTED
} TTGoveeState;

@class TTModeGovee;

@protocol TTModeGoveeDelegate <NSObject>
@required
- (void)changeState:(TTGoveeState)goveeState withMode:(TTModeGovee *)modeGovee;
@optional
- (void)fetchStatusUpdate:(NSString *)status;
@end

@interface TTModeGovee : TTMode <TTModeGoveeAPIClientDelegate>

extern NSString *const kGoveeSelectedDevices;
extern NSString *const kGoveeFoundDevices;
extern NSInteger const kGoveeBrightnessStep;

@property (nonatomic, weak) id<TTModeGoveeDelegate> delegate;

+ (TTGoveeState)goveeState;
+ (void)setGoveeState:(TTGoveeState)state;
+ (NSMutableArray<TTModeGoveeDevice *> *)foundDevices;
+ (TTModeGoveeAPIClient *)apiClient;

- (void)resetKnownDevices;
- (void)refreshDevices;
- (void)beginConnectingToGovee;
- (void)cancelConnectingToGovee;
- (void)ensureDevicesSelected;

// API Key
+ (void)saveApiKey:(NSString *)apiKey;
+ (NSString *)loadApiKey;
+ (BOOL)hasApiKey;
+ (void)clearApiKey;

@end
