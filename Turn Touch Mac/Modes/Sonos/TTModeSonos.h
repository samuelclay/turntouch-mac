//
//  TTModeSonos.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/12/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "SonosController.h"
#import "SonosManager.h"

typedef enum TTSonosState : NSUInteger {
    SONOS_STATE_NOT_CONNECTED,
    SONOS_STATE_CONNECTING,
    SONOS_STATE_CONNECTED
} TTSonosState;

@class TTModeSonos;

@protocol TTModeSonosDelegate <NSObject>
@required
- (void)changeState:(TTSonosState)sonosState withMode:(TTModeSonos *)modeSonos;
@end

@interface TTModeSonos : TTMode

extern NSString *const kSonosDeviceId;
extern NSString *const kSonosCachedDevices;

@property (nonatomic, weak) id <TTModeSonosDelegate> delegate;

+ (TTSonosState)sonosState;
+ (void)setSonosState:(TTSonosState)state;
- (NSArray *)foundDevices;
- (void)beginConnectingToSonos:(void (^)())callback;
- (void)cancelConnectingToSonos;
- (void)resetKnownDevices;

@end
