//
//  TTModeHue.h
//  Turn Touch App
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

@protocol TTModeHueDelegate <NSObject>

@required

- (void)changeState:(TTHueState)hueState withMode:(TTModeHue *)modeHue showMessage:(id)message;

@end

@interface TTModeHue : TTMode

@property (strong, nonatomic) PHHueSDK *phHueSDK;
@property (nonatomic, weak) id <TTModeHueDelegate> delegate;
@property (nonatomic) TTHueState hueState;

- (void)searchForBridgeLocal;

@end
