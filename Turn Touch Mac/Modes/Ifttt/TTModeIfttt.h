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
- (void)changeState:(TTIftttState)sonosState withMode:(TTModeIfttt *)modeIfttt;
@end

@interface TTModeIfttt : TTMode

extern NSString *const kIftttUserIdKey;
extern NSString *const kIftttDeviceIdKey;
extern NSString *const kIftttIsActionSetup;
extern NSString *const kIftttTapType;
extern NSString *const kIftttAuthorized;

@property (nonatomic, weak) id <TTModeIftttDelegate> delegate;

+ (TTIftttState)iftttState;
+ (void)setIftttState:(TTIftttState)state;
- (void)beginConnectingToIfttt:(void (^)(void))callback;
- (void)cancelConnectingToIfttt;
- (void)registerTriggers:(void (^)(void))callback;
- (void)purgeRecipe:(TTModeDirection)actionDirection callback:(void (^)(void))callback;

@end
