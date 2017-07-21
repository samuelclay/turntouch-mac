//
//  TTModeSonos.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/12/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeSonos.h"

@implementation TTModeSonos

NSString *const kSonosDeviceId = @"TT:Sonos:sonosDeviceUUID";
NSString *const kSonosCachedDevices = @"TT:Sonos:sonosCachedDevices";

static TTSonosState sonosState;
static SonosManager *sonosManager;

@synthesize delegate;

- (instancetype)init {
    if (self = [super init]) {
        [self.delegate changeState:TTModeSonos.sonosState withMode:self];
        
        sonosManager = [SonosManager sharedInstance];
    }
    
    return self;
}


#pragma mark - Mode

+ (NSString *)title {
    return @"Sonos";
}

+ (NSString *)description {
    return @"Connected wireless speakers";
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
    return @"TTModeSonosNextTrack";
}
- (NSString *)defaultWest {
    return @"TTModeSonosPlayPause";
}
- (NSString *)defaultSouth {
    return @"TTModeSonosVolumeDown";
}

#pragma mark - Action methods

- (void)activate {
    if ([self foundDevices].count == 0) {
        [self beginConnectingToSonos:nil];
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
    SonosController *device = [self selectedDevice];
    
    [device playbackStatus:^(BOOL playing, NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (!playing) {
            [device togglePlayback:^(BOOL playing, NSDictionary * _Nullable response, NSError * _Nullable error) {
                
            }];
        }
    }];
}

- (void)runTTModeSonosPause:(TTModeDirection)direction {
    SonosController *device = [self selectedDevice];
    
    [device playbackStatus:^(BOOL playing, NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (playing) {
            [device togglePlayback:^(BOOL playing, NSDictionary * _Nullable response, NSError * _Nullable error) {
                
            }];
        }
    }];
}

- (void)runTTModeSonosNextTrack:(TTModeDirection)direction {
    SonosController *device = [self selectedDevice];
    
    [device next:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        
    }];
}

- (void)runTTModeSonosPreviousTrack:(TTModeDirection)direction {
    SonosController *device = [self selectedDevice];

    [device previous:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        
    }];
}

#pragma mark - Sonos Devices

- (NSArray *)foundDevices {
    NSArray *devices = [sonosManager allDevices];
    if (devices.count == 0) {
        devices = [self cachedDevices];
    }
    
    devices = [devices sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [((SonosController *)obj1).name compare:((SonosController *)obj2).name];
    }];
    
    return devices;
}

- (SonosController *)selectedDevice {
    return [self selectedDevice:NO];
}

- (SonosController *)selectedDevice:(BOOL)coordinator {
    NSArray *devices = [self foundDevices];
    if (devices.count == 0) return nil;
    
    NSString *deviceId = [appDelegate.modeMap mode:self.action.mode optionValue:kSonosDeviceId];
    for (SonosController *foundDevice in devices) {
        if ([foundDevice.uuid isEqualToString:deviceId]) {
            // Find the coordinator in the same group as the device
            if (coordinator && !foundDevice.isCoordinator) {
                for (SonosController *coordinatorDevice in devices) {
                    if (coordinatorDevice.isCoordinator && [coordinatorDevice.group isEqualToString:foundDevice.group]) {
                        return coordinatorDevice;
                    }
                }
            }
            
            return foundDevice;
        }
    }
    
    return [devices objectAtIndex:0];
}

- (NSArray *)cachedDevices {
    NSMutableArray<SonosController *> *cachedDevices = [NSMutableArray array];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSArray *devices = [prefs arrayForKey:kSonosCachedDevices];
    if (!devices || devices.count == 0) return cachedDevices;
    
    for (NSDictionary *device in devices) {
        NSString *ip = device[@"ip"];
        int port = [device[@"port"] intValue];
        
        SonosController *cachedDevice = [[SonosController alloc] initWithIP:ip port:port];
        cachedDevice.group = device[@"group"];
        cachedDevice.coordinator = [device[@"isCoordinator"] boolValue];
        cachedDevice.name = device[@"name"];
        cachedDevice.uuid = device[@"uuid"];
        [cachedDevices addObject:cachedDevice];
        NSLog(@" ---> Loading cached Sonos: %@", cachedDevice);
    }
    
    return cachedDevices;
}

- (void)cacheDevices:(NSArray<SonosController *> *)devices {
    NSMutableArray *cachedDevices = [NSMutableArray array];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    for (SonosController *device in devices) {
        NSMutableDictionary *cachedDevice = [NSMutableDictionary dictionary];
        cachedDevice[@"ip"] = device.ip;
        cachedDevice[@"port"] = [NSNumber numberWithInt:device.port];
        cachedDevice[@"isCoordinator"] = [NSNumber numberWithBool:device.isCoordinator];
        cachedDevice[@"name"] = device.name;
        cachedDevice[@"group"] = device.group;
        cachedDevice[@"uuid"] = device.uuid;
        [cachedDevices addObject:cachedDevice];
    }
    
    [prefs setObject:cachedDevices forKey:kSonosCachedDevices];
    [prefs synchronize];
}

- (void)beginConnectingToSonos:(void (^)())callback {
    if (sonosState == SONOS_STATE_CONNECTING) {
        NSLog(@" ---> Already connecting to sonos...");
        return;
    }
    
    sonosState = SONOS_STATE_CONNECTING;
    [self.delegate changeState:sonosState withMode:self];
    
    [sonosManager discoverControllers:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *devices = [self foundDevices];
            for (SonosController *device in devices) {
                [self deviceReady:device];
            }
            [self cacheDevices:devices];
            if (devices.count == 0) {
                [self cancelConnectingToSonos];
            }
        });
    }];
    
}

- (void)cancelConnectingToSonos {
    sonosState = SONOS_STATE_CONNECTED;
    [self.delegate changeState:sonosState withMode:self];
}

- (void)deviceReady:(SonosController *)device {
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

- (void)resetKnownDevices {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kSonosCachedDevices];
    [prefs synchronize];
    
    [self beginConnectingToSonos:nil];
}

@end
