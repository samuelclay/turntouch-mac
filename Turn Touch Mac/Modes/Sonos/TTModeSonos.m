//
//  TTModeSonos.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/12/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeSonos.h"

@implementation TTModeSonos

NSString *const kSonos = @"TT:Sonos";

static TTSonosState sonosState;

@synthesize delegate;

- (instancetype)init {
    if (self = [super init]) {
        [self.delegate changeState:TTModeSonos.sonosState withMode:self];
    }
    
    return self;
}


#pragma mark - Mode

+ (NSString *)title {
    return @"Sonos";
}

+ (NSString *)description {
    return @"Connected Wireless Speakers";
}

+ (NSString *)imageName {
    return @"mode_sonos.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeSonosVolumeUp",
             @"TTModeSonosVolumeDown",
             @"TTModeSonosVolumeMute",
             @"TTModeSonosPlayPause",
             @"TTModeSonosPlay",
             @"TTModeSonosPause",
             @"TTModeSonosNextTrack",
             @"TTModeSonosPreviousTrack",
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeSonosVolumeUp {
    return @"Volume up";
}

- (NSString *)titleTTModeSonosVolumeDown {
    return @"Volume down";
}

- (NSString *)titleTTModeSonosVolumeMute {
    return @"Mute";
}

- (NSString *)titleTTModeSonosPlayPause {
    return @"Play/pause";
}

- (NSString *)titleTTModeSonosPlay {
    return @"Play";
}

- (NSString *)titleTTModeSonosPause {
    return @"Pause";
}

- (NSString *)titleTTModeSonosNextTrack {
    return @"Next Track";
}

- (NSString *)titleTTModeSonosPreviousTrack {
    return @"Previous Track";
}

#pragma mark - Action Images

- (NSString *)imageTTModeSonosVolumeUp {
    return @"volume_up";
}

- (NSString *)imageTTModeSonosVolumeDown {
    return @"volume_down";
}

- (NSString *)imageTTModeSonosVolumeMute {
    return @"mute";
}

- (NSString *)imageTTModeSonosPlayPause {
    return @"play_pause";
}

- (NSString *)imageTTModeSonosPlay {
    return @"play";
}

- (NSString *)imageTTModeSonosPause {
    return @"pause";
}

- (NSString *)imageTTModeSonosNextTrack {
    return @"next_track";
}

- (NSString *)imageTTModeSonosPreviousTrack {
    return @"previous_track";
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeSonosVolumeUp";
}
- (NSString *)defaultEast {
    return @"TTModeSonosPlayPause";
}
- (NSString *)defaultWest {
    return @"TTModeSonosNextTrack";
}
- (NSString *)defaultSouth {
    return @"TTModeSonosVolumeDown";
}

#pragma mark - Action methods

- (void)activate {
    if ([self foundDevices].count == 0) {
        self beginConnectingToSonos:nil];
    } else {
        TTModeSonos.sonosState = SONOS_STATE_CONNECTED;
    }
    
    [delegate changeState:TTModeSonos.sonosState withMode:self];
}

- (void)adjustVolume:(SonosController *)device volume:(NSInteger)volume left:(NSInteger)left {
    if (left == 0) return;
    
    NSInteger adjust = left > 0 ? 1 : -1;
    
    __weak SonosController *_device = device;
    [device setVolume:volume+adjust mergeRequests:YES completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        NSLog(@" ---> Turned volume: %ld+%ld (%@)", (long)volume, (long)adjust, error);
        [self adjustVolume:_device volume:volume+adjust left:left-adjust];
    }];
}

- (void)runTTModeSonosVolumeUp:(TTModeDirection)direction {
    SonosController *device = [self selectedDevice];
    if (device) {
        [device getVolume:60*60 completion:^(NSInteger volume, NSDictionary * _Nullable response, NSError * _Nullable error) {
            [self adjustVolume:device volume:volume left:2];
        }];
    } else {
        [self beginConnectingToSonos:nil];
    }
}

- (void)runTTModeSonosVolumeDown:(TTModeDirection)direction {
    SonosController *device = [self selectedDevice];
    if (device) {
        [device getVolume:60*60 completion:^(NSInteger volume, NSDictionary * _Nullable response, NSError * _Nullable error) {
            [self adjustVolume:device volume:volume left:-2];
        }];
    } else {
        [self beginConnectingToSonos:nil];
    }
}

- (void)runTTModeSonosVolumeMute:(TTModeDirection)direction {
    SonosController *device = [self selectedDevice];
    if (device) {
        [device getMute:^(BOOL mute, NSDictionary * _Nullable response, NSError * _Nullable error) {
            [device setMute:!mute completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
                
            }];
        }];
    } else {
        [self beginConnectingToSonos:nil];
    }
}

- (void)runTTModeSonosPlayPause:(TTModeDirection)direction {
    SonosController *device = [self selectedDevice];
    if (device) {
        [device togglePlayback:^(BOOL playing, NSDictionary * _Nullable response, NSError * _Nullable error) {
            
        }];
    } else {
        [self beginConnectingToSonos:nil];
    }
}

- (void)doubleRunTTModeSonosPlayPause:(TTModeDirection)direction {
    [self runTTModeSonosPreviousTrack:direction];
}

- (void)runTTModeSonosPlay:(TTModeDirection)direction {
    
}

- (void)runTTModeSonosPause:(TTModeDirection)direction {
    
}

- (void)runTTModeSonosNextTrack:(TTModeDirection)direction {
    
}

- (void)runTTModeSonosPreviousTrack:(TTModeDirection)direction {
    
}

#pragma mark - Sonos Devices

- (NSArray *)foundDevices {
    
}

- (void)beginConnectingToSonos:(void (^)())callback {
    sonosState = SONOS_STATE_CONNECTING;
    [self.delegate changeState:sonosState withMode:self];
    
}

- (void)cancelConnectingToSonos {
    sonosState = SONOS_STATE_CONNECTED;
    [self.delegate changeState:sonosState withMode:self];
}

+ (TTSonosState)sonosState {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sonosState = SONOS_STATE_NOT_CONNECTED;
    });
    return sonosState;
}

+ (void)setSonosState:(TTSonosState)state {
    @synchronized (self) {
        sonosState = state;
    }
}

@end
