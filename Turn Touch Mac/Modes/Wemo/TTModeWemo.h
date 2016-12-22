//
//  TTModeWemo.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "TTModeWemoMulticastServer.h"
#import "TTModeWemoDevice.h"

typedef enum TTWemoState : NSUInteger {
    WEMO_STATE_NOT_CONNECTED,
    WEMO_STATE_CONNECTING,
    WEMO_STATE_CONNECTED
} TTWemoState;

@class TTModeWemo;

@protocol TTModeWemoDelegate <NSObject>
@required
- (void)changeState:(TTWemoState)hueState withMode:(TTModeWemo *)modeWemo;
@end


@interface TTModeWemo : TTMode <TTModeWemoMulticastDelegate, TTModeWemoDeviceDelegate>

extern NSString *const kWemoDeviceLocation;
extern NSString *const kWemoFoundDevices;
extern NSString *const kWemoSeenDevices;

//@property (nonatomic) NSMutableArray *foundDevices;
//@property (nonatomic) TTModeWemoMulticastServer *multicastServer;
//@property (class) TTWemoState wemoState;
@property (nonatomic, weak) id <TTModeWemoDelegate> delegate;

+ (TTWemoState)wemoState;
+ (void)setWemoState:(TTWemoState)state;
+ (NSMutableArray *)foundDevices;
- (void)beginConnectingToWemo;
- (void)cancelConnectingToWemo;

@end
