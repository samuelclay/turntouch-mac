//
//  TTModeHue.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/25/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HueSDK_OSX/HueSDK.h>
#import "TTMode.h"
#import "TTModeProtocol.h"
#import "TTModeHueSceneOptions.h"

@class TTModeHue;
@class TTModeHueSceneOptions;

typedef enum TTHueState : NSUInteger {
    STATE_NOT_CONNECTED,
    STATE_CONNECTING,
    STATE_PUSHLINK,
    STATE_CONNECTED
} TTHueState;

typedef enum {
    TTHueRandomColorsAllDifferent = 1,
    TTHueRandomColorsSomeDifferent = 2,
    TTHueRandomColorsAllSame = 3,
} TTHueRandomColors;

typedef enum {
    TTHueRandomBrightnessLow = 1,
    TTHueRandomBrightnessVaried = 2,
    TTHueRandomBrightnessHigh = 3,
} TTHueRandomBrightness;

@protocol TTModeHueDelegate <NSObject>

@required

- (void)changeState:(TTHueState)hueState withMode:(TTModeHue *)modeHue showMessage:(id)message;

@end

@interface TTModeHue : TTMode

extern NSString *const kRandomColors;
extern NSString *const kRandomBrightness;

@property (strong, nonatomic) PHHueSDK *phHueSDK;
@property (nonatomic, weak) id <TTModeHueDelegate> delegate;
@property (nonatomic) TTHueState hueState;

- (void)searchForBridgeLocal;

@end
