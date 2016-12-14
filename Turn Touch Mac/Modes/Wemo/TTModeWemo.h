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

//@property (nonatomic) NSMutableArray *foundDevices;
//@property (nonatomic) TTModeWemoMulticastServer *multicastServer;
@property (nonatomic, weak) id <TTModeWemoDelegate> delegate;
@property (nonatomic) TTWemoState wemoState;

- (NSMutableArray *)sharedFoundDevices;
- (void)beginConnectingToWemo;
- (void)cancelConnectingToWemo;

@end
