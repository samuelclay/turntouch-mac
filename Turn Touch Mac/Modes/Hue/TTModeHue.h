//
//  TTModeHue.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/25/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTMode.h"
#import "TTModeProtocol.h"
#import "TTModeHueSceneOptions.h"

// New Hue API v2 imports
#import "TTHueModels.h"
#import "TTHueAPIClient.h"
#import "TTHueBridgeDiscovery.h"
#import "TTHueBridgeAuthenticator.h"
#import "TTHueResourceCache.h"
#import "TTHueEventStream.h"
#import "TTHueColorUtilities.h"

@class TTModeHue;
@class TTModeHueSceneOptions;

typedef enum TTHueState : NSUInteger {
    STATE_NOT_CONNECTED,
    STATE_CONNECTING,
    STATE_BRIDGE_SELECT,
    STATE_PUSHLINK,
    STATE_CONNECTED
} TTHueState;

typedef enum {
    TTHueRandomColorsAllDifferent = 0,
    TTHueRandomColorsSomeDifferent = 1,
    TTHueRandomColorsAllSame = 2,
} TTHueRandomColors;

typedef enum {
    TTHueRandomBrightnessLow = 0,
    TTHueRandomBrightnessVaried = 1,
    TTHueRandomBrightnessHigh = 2,
} TTHueRandomBrightness;

typedef enum {
    TTHueRandomSaturationLow = 0,
    TTHueRandomSaturationVaried = 1,
    TTHueRandomSaturationHigh = 2,
} TTHueRandomSaturation;


@protocol TTModeHueDelegate <NSObject>
@required

- (void)changeState:(TTHueState)hueState withMode:(TTModeHue *)modeHue showMessage:(id)message;

@end


@interface TTModeHue : TTMode <TTHueBridgeDiscoveryDelegate, TTHueBridgeAuthenticatorDelegate, TTHueEventStreamDelegate>

extern NSString *const kRandomColors;
extern NSString *const kRandomBrightness;
extern NSString *const kRandomSaturation;
extern NSString *const kDoubleTapRandomColors;
extern NSString *const kDoubleTapRandomBrightness;
extern NSString *const kDoubleTapRandomSaturation;

@property (nonatomic, weak) id <TTModeHueDelegate> delegate;
@property (nonatomic) TTHueState hueState;

// New API v2 properties
@property (class, nonatomic, strong, readonly) TTHueAPIClient *hueClient;
@property (class, nonatomic, strong, readonly) TTHueResourceCache *resourceCache;
@property (class, nonatomic, strong, readonly) TTHueEventStream *eventStream;

- (void)searchForBridgeLocal;
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andBridgeId:(NSString *)bridgeId;

// For legacy compatibility
+ (BOOL)isConnected;

@end
