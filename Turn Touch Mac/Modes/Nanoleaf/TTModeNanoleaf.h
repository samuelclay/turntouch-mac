//
//  TTModeNanoleaf.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Network/Network.h>
#import "TTMode.h"
#import "TTModeProtocol.h"

@class TTModeNanoleaf;

typedef enum TTNanoleafState : NSUInteger {
    NANOLEAF_STATE_NOT_CONNECTED,
    NANOLEAF_STATE_CONNECTING,
    NANOLEAF_STATE_PUSHLINK,
    NANOLEAF_STATE_CONNECTED
} TTNanoleafState;

extern NSString *const kNanoleafSavedDevices;
extern NSString *const kNanoleafScene;
extern NSString *const kDoubleTapNanoleafScene;
extern NSString *const kNanoleafDuration;
extern NSString *const kNanoleafDoubleTapDuration;

extern NSInteger const kNanoleafApiPort;
extern NSInteger const kNanoleafBrightnessStep;

@protocol TTModeNanoleafDelegate <NSObject>
@required
- (void)changeState:(TTNanoleafState)state withMode:(TTModeNanoleaf *)mode showMessage:(id)message;
@end

@interface TTModeNanoleaf : TTMode

@property (nonatomic, weak) id<TTModeNanoleafDelegate> delegate;
@property (nonatomic) TTNanoleafState nanoleafState;

+ (NSString *)deviceIp;
+ (NSString *)deviceName;
+ (NSString *)authToken;
+ (NSArray<NSString *> *)cachedEffects;
+ (void)updateCachedEffects:(NSArray<NSString *> *)effects;
+ (TTNanoleafState)currentState;

- (void)connectToDevice;
- (void)findDevices;

- (void)fetchEffectsWithCompletion:(void (^)(NSArray<NSString *> *effects, NSError *error))completion;

@end
