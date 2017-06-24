//
//  TTModeIfttt.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/12/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTMode.h"

typedef enum TTIftttState : NSUInteger {
    IFTTT_STATE_NOT_CONNECTED,
    IFTTT_STATE_CONNECTING,
    IFTTT_STATE_CONNECTED
} TTIftttState;


@class TTModeIfttt;

@protocol TTModeIftttDelegate <NSObject>
@required
- (void)changeState:(TTIftttState)hueState withMode:(TTModeIfttt *)modeWemo;
@end

@interface TTModeIfttt : TTMode

extern NSString *const kIftttUserIdKey;
extern NSString *const kIftttDeviceIdKey;
extern NSString *const kIftttIsActionSetup;
extern NSString *const kIftttTapType;

@property (nonatomic, weak) id <TTModeIftttDelegate> delegate;

+ (TTIftttState)iftttState;
+ (void)setIftttState:(TTIftttState)state;
- (void)beginConnectingToIfttt:(void (^)())callback;
- (void)cancelConnectingToIfttt;
- (void)registerTriggers:(void (^)())callback;

@end
