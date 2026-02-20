//
//  TTModeHue.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/25/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTModeHueSceneOptions.h"
#import "TTModeHueSleepOptions.h"

#define MAX_HUE 65535
#define MAX_BRIGHTNESS_V1 255
#define MAX_BRIGHTNESS_V2 100.0
#define DEBUG_HUE YES

@interface TTModeHue()

@property (nonatomic, strong) TTHueBridgeDiscovery *bridgeDiscovery;
@property (nonatomic, strong) TTHueBridgeAuthenticator *bridgeAuthenticator;
@property (nonatomic, strong) TTHueDiscoveredBridge *latestBridge;
@property (nonatomic, strong) NSMutableArray<NSString *> *bridgesTried;
@property (nonatomic, strong) NSMutableArray<TTHueDiscoveredBridge *> *foundBridges;
@property (nonatomic, strong) NSMutableArray<NSString *> *foundScenes;
@property (nonatomic, strong) NSMutableArray<NSString *> *createdScenes;
@property (nonatomic, assign) BOOL waitingOnScenes;
@property (nonatomic, assign) BOOL ensuringScenes;
@property (nonatomic, strong) NSDate *connectionStartTime;
@property (nonatomic, strong) NSTimer *connectionTimeoutTimer;

@end

static const NSTimeInterval kConnectionTimeoutSeconds = 15.0;

@implementation TTModeHue

// Static class properties
static TTHueAPIClient *_hueClient = nil;
static TTHueResourceCache *_resourceCache = nil;
static TTHueEventStream *_eventStream = nil;

NSString *const kRandomColors = @"randomColors";
NSString *const kRandomBrightness = @"randomBrightness";
NSString *const kRandomSaturation = @"randomSaturation";
NSString *const kDoubleTapRandomColors = @"doubleTapRandomColors";
NSString *const kDoubleTapRandomBrightness = @"doubleTapRandomBrightness";
NSString *const kDoubleTapRandomSaturation = @"doubleTapRandomSaturation";

#pragma mark - Class Property Accessors

+ (TTHueAPIClient *)hueClient {
    return _hueClient;
}

+ (TTHueResourceCache *)resourceCache {
    return _resourceCache;
}

+ (TTHueEventStream *)eventStream {
    return _eventStream;
}

+ (BOOL)isConnected {
    return _hueClient != nil && _resourceCache != nil;
}

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        self.bridgesTried = [NSMutableArray array];
        self.foundBridges = [NSMutableArray array];
        self.foundScenes = [NSMutableArray array];
        self.createdScenes = [NSMutableArray array];
        [self initializeHue];
    }
    return self;
}

- (void)initializeHue {
    NSLog(@" ---> [TTModeHue] initializeHue called, _hueClient=%@", _hueClient);

    if (_hueClient != nil) {
        NSLog(@" ---> [TTModeHue] Already have hueClient, returning early");
        return;
    }

    // Register for event stream notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lightsUpdated:)
                                                 name:TTHueEventStreamLightsUpdatedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStreamConnected:)
                                                 name:TTHueEventStreamConnectedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStreamDisconnected:)
                                                 name:TTHueEventStreamDisconnectedNotification
                                               object:nil];

    self.hueState = STATE_CONNECTING;
    [self.delegate changeState:self.hueState withMode:self showMessage:@"Connecting..."];

    [self connectToBridgeWithReset:YES];
}

#pragma mark - Mode

+ (NSString *)title {
    return @"Hue";
}

+ (NSString *)description {
    return @"Lights and scenes";
}

+ (NSString *)imageName {
    return @"mode_hue.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeHueRaiseBrightness",
             @"TTModeHueLowerBrightness",
             @"TTModeHueShiftColorLeft",
             @"TTModeHueShiftColorRight",
             @"TTModeHueSceneEarlyEvening",
             @"TTModeHueSceneLateEvening",
             @"TTModeHueSleep",
             @"TTModeHueOff",
             @"TTModeHueRandom",
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeHueRaiseBrightness {
    return @"Raise brightness";
}
- (NSString *)titleTTModeHueLowerBrightness {
    return @"Lower brightness";
}
- (NSString *)titleTTModeHueShiftColorLeft {
    return @"Shift color left";
}
- (NSString *)titleTTModeHueShiftColorRight {
    return @"Shift color right";
}
- (NSString *)titleTTModeHueSceneEarlyEvening {
    return @"Early evening";
}
- (NSString *)doubleTitleTTModeHueSceneEarlyEvening {
    return @"Early evening 2";
}
- (NSString *)titleTTModeHueSceneLateEvening {
    return @"Late evening";
}
- (NSString *)doubleTitleTTModeHueSceneLateEvening {
    return @"Late evening 2";
}
- (NSString *)titleTTModeHueSleep {
    return @"Sleep";
}
- (NSString *)doubleTitleTTModeHueSleep {
    return @"Sleep fast";
}
- (NSString *)titleTTModeHueOff {
    return @"Lights off";
}
- (NSString *)titleTTModeHueRandom {
    return @"Random";
}
- (NSString *)doubleTitleTTModeHueRandom {
    return @"Random 2";
}

#pragma mark - Action Images

- (NSString *)imageTTModeHueRaiseBrightness {
    return @"hue_brightness_up.png";
}
- (NSString *)imageTTModeHueLowerBrightness {
    return @"hue_brightness_down.png";
}
- (NSString *)imageTTModeHueShiftColorLeft {
    return @"hue_shift_left.png";
}
- (NSString *)imageTTModeHueShiftColorRight {
    return @"hue_shift_right.png";
}
- (NSString *)imageTTModeHueSceneEarlyEvening {
    return @"hue_sunset.png";
}
- (NSString *)imageTTModeHueSceneLateEvening {
    return @"hue_evening.png";
}
- (NSString *)imageTTModeHueSleep {
    return @"hue_sleep.png";
}
- (NSString *)imageTTModeHueOff {
    return @"hue_sleep.png";
}
- (NSString *)imageTTModeHueRandom {
    return @"hue_random.png";
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeHueSceneEarlyEvening";
}
- (NSString *)defaultEast {
    return @"TTModeHueSceneLateEvening";
}
- (NSString *)defaultWest {
    return @"TTModeHueRandom";
}
- (NSString *)defaultSouth {
    return @"TTModeHueSleep";
}

#pragma mark - Action methods

- (void)runScene:(NSString *)sceneName inDirection:(TTModeDirection)direction doubleTap:(BOOL)doubleTap {
    if (self.hueState != STATE_CONNECTED) {
        [self connectToBridgeWithReset:NO];
        return;
    }

    if (!_hueClient) {
        NSLog(@" ---> No Hue client available");
        return;
    }

    NSString *sceneIdentifier = [self.action optionValue:(doubleTap ? kDoubleTapHueScene : kHueScene) inDirection:direction];

    if (!sceneIdentifier || [sceneIdentifier length] == 0) {
        // Try to find a scene by title
        NSString *sceneTitle = doubleTap ? [self doubleTitleForAction:sceneName] : [self titleForAction:sceneName];
        NSDictionary<NSString *, TTHueScene *> *scenes = _resourceCache.scenes;
        for (NSString *sceneId in scenes) {
            TTHueScene *scene = scenes[sceneId];
            if ([scene.metadata.name isEqualToString:sceneTitle]) {
                sceneIdentifier = sceneId;
                break;
            }
        }
    }

    if (!sceneIdentifier) {
        NSLog(@" ---> No scene identifier found for %@", sceneName);
        return;
    }

    [_hueClient recallSceneId:sceneIdentifier duration:nil brightness:nil completion:^(id result, NSError *error) {
        if (error) {
            NSLog(@" ---> Scene change error: %@", error);
            if ([error.localizedDescription containsString:@"scene"]) {
                [self ensureScenes];
            }
        } else {
            if (DEBUG_HUE) {
                NSLog(@" ---> Scene change: %@ (%@)", sceneName, sceneIdentifier);
            }
        }
    }];
}

- (NSString *)titleForAction:(NSString *)actionName {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"title%@", actionName]);
    if ([self respondsToSelector:selector]) {
        return [self performSelector:selector];
    }
    return actionName;
}

- (NSString *)doubleTitleForAction:(NSString *)actionName {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"doubleTitle%@", actionName]);
    if ([self respondsToSelector:selector]) {
        return [self performSelector:selector];
    }
    // Fall back to single title with " 2" suffix
    return [[self titleForAction:actionName] stringByAppendingString:@" 2"];
}

- (void)runTTModeHueSceneEarlyEvening:(TTModeDirection)direction {
    [self runScene:@"TTModeHueSceneEarlyEvening" inDirection:direction doubleTap:NO];
}

- (void)doubleRunTTModeHueSceneEarlyEvening:(TTModeDirection)direction {
    [self runScene:@"TTModeHueSceneEarlyEvening" inDirection:direction doubleTap:YES];
}

- (void)runTTModeHueSceneLateEvening:(TTModeDirection)direction {
    [self runScene:@"TTModeHueSceneLateEvening" inDirection:direction doubleTap:NO];
}

- (void)doubleRunTTModeHueSceneLateEvening:(TTModeDirection)direction {
    [self runScene:@"TTModeHueSceneLateEvening" inDirection:direction doubleTap:YES];
}

- (void)runTTModeHueOff:(TTModeDirection)direction {
    [self runTTModeHueSleep:direction duration:@(1)];
}

- (void)runTTModeHueSleep:(TTModeDirection)direction {
    NSNumber *sceneDuration = [self.action optionValue:kHueDuration inDirection:direction];
    [self runTTModeHueSleep:direction duration:sceneDuration];
}

- (void)doubleRunTTModeHueSleep:(TTModeDirection)direction {
    NSNumber *sceneDuration = [self.action optionValue:kHueDoubleTapDuration inDirection:direction];
    [self runTTModeHueSleep:direction duration:sceneDuration];
}

- (BOOL)shouldIgnoreSingleBeforeDoubleTTModeHueSceneEarlyEvening {
    return YES;
}

- (BOOL)shouldIgnoreSingleBeforeDoubleTTModeHueSceneLateEvening {
    return YES;
}

- (BOOL)shouldIgnoreSingleBeforeDoubleTTModeHueSleep {
    return YES;
}

- (BOOL)shouldIgnoreSingleBeforeDoubleTTModeHueRandom {
    return YES;
}

- (void)runTTModeHueSleep:(TTModeDirection)direction duration:(NSNumber *)sceneDuration {
    if (self.hueState != STATE_CONNECTED || !_hueClient || !_resourceCache) {
        NSLog(@" ---> Not running sleep, not connected");
        return;
    }

    NSInteger transitionMs = [sceneDuration integerValue] * 1000;  // API v2 uses milliseconds
    NSString *roomIdentifier = [self.action optionValue:kHueRoom inDirection:direction];
    NSArray<NSString *> *roomLights = [self roomLightsForRoom:roomIdentifier];

    NSDictionary<NSString *, TTHueLight *> *lights = _resourceCache.lights;
    if (lights.count == 0) {
        NSLog(@" ---> Not running sleep, no lights found");
        return;
    }

    for (NSString *lightId in lights) {
        if (roomIdentifier && ![roomIdentifier isEqualToString:@"all"] && roomLights) {
            if (![roomLights containsObject:lightId]) {
                continue;
            }
        }

        [_hueClient updateLightId:lightId
                               on:@NO
                       brightness:@(0)
                               xy:nil
                     transitionMs:@(transitionMs)
                           effect:nil
                       completion:^(id result, NSError *error) {
            if (error) {
                NSLog(@" ---> Sleep light error: %@", error);
            } else {
                NSLog(@" ---> Sleep light in %ldms", (long)transitionMs);
            }
        }];
    }
}

- (void)runTTModeHueRandom:(TTModeDirection)direction {
    [self runTTModeHueRandom:direction doubleTap:NO];
}

- (void)doubleRunTTModeHueRandom:(TTModeDirection)direction {
    [self runTTModeHueRandom:direction doubleTap:YES];
}

- (void)runTTModeHueRandom:(TTModeDirection)direction doubleTap:(BOOL)doubleTap {
    if (self.hueState != STATE_CONNECTED || !_hueClient || !_resourceCache) {
        NSLog(@" ---> Not running random, not connected");
        return;
    }

    TTHueRandomColors randomColors = (TTHueRandomColors)[[self.action
                                                          optionValue:(doubleTap ? kDoubleTapRandomColors : kRandomColors)
                                                          inDirection:direction] integerValue];
    TTHueRandomBrightness randomBrightnesses = (TTHueRandomBrightness)[[self.action
                                                                        optionValue:(doubleTap ? kDoubleTapRandomBrightness : kRandomBrightness)
                                                                        inDirection:direction] integerValue];
    TTHueRandomSaturation randomSaturation = (TTHueRandomSaturation)[[self.action
                                                                      optionValue:(doubleTap ? kDoubleTapRandomSaturation : kRandomSaturation)
                                                                      inDirection:direction] integerValue];

    NSInteger randomHue1 = arc4random() % MAX_HUE;
    NSInteger randomHue2 = arc4random() % MAX_HUE;

    NSString *roomIdentifier = [self.action optionValue:kHueRoom inDirection:direction];
    NSArray<NSString *> *roomLights = [self roomLightsForRoom:roomIdentifier];

    NSDictionary<NSString *, TTHueLight *> *lights = _resourceCache.lights;
    if (lights.count == 0) {
        NSLog(@" ---> Not running random, no lights found");
        return;
    }

    for (NSString *lightId in lights) {
        TTHueLight *light = lights[lightId];

        if (roomIdentifier && ![roomIdentifier isEqualToString:@"all"] && roomLights) {
            if (![roomLights containsObject:lightId]) {
                continue;
            }
        }

        // Calculate hue value
        NSInteger hue;
        if (randomColors == TTHueRandomColorsAllSame) {
            hue = randomHue1;
        } else if (randomColors == TTHueRandomColorsSomeDifferent) {
            hue = (arc4random() % 10 > 5) ? randomHue1 : randomHue2;
        } else {
            hue = arc4random() % MAX_HUE;
        }

        // Calculate brightness (convert to 0-100 scale for API v2)
        double brightness;
        if (randomBrightnesses == TTHueRandomBrightnessLow) {
            brightness = (double)(arc4random() % 100) / 255.0 * 100.0;
        } else if (randomBrightnesses == TTHueRandomBrightnessVaried) {
            brightness = (double)(arc4random() % MAX_BRIGHTNESS_V1) / 255.0 * 100.0;
        } else {
            brightness = 100.0;
        }

        // Calculate saturation
        NSInteger saturation;
        if (randomSaturation == TTHueRandomSaturationLow) {
            saturation = 174;
        } else if (randomSaturation == TTHueRandomSaturationVaried) {
            saturation = MAX_BRIGHTNESS_V1 - (arc4random() % 80);
        } else {
            saturation = MAX_BRIGHTNESS_V1;
        }

        // Convert hue/saturation to xy color space (only for color-capable lights)
        TTHueXY *xy = nil;
        if (light.color != nil) {
            CGFloat h = (CGFloat)hue / (CGFloat)MAX_HUE;
            CGFloat s = (CGFloat)saturation / 254.0;
            NSColor *color = [NSColor colorWithHue:h saturation:s brightness:1.0 alpha:1.0];
            NSString *modelId = light.metadata.archetype;
            xy = [TTHueColorUtilities calculateHueXYFromColor:color forModel:modelId];
        }

        [_hueClient updateLightId:lightId
                               on:@YES
                       brightness:@(brightness)
                               xy:xy
                     transitionMs:nil
                           effect:nil
                       completion:^(id result, NSError *error) {
            if (error) {
                NSLog(@" ---> Random light error: %@", error);
            } else if (DEBUG_HUE) {
                NSLog(@" ---> Finished random for light %@", lightId);
            }
        }];
    }
}

- (NSArray<NSString *> *)roomLightsForRoom:(NSString *)roomIdentifier {
    if (!_resourceCache) return nil;

    if (!roomIdentifier || [roomIdentifier isEqualToString:@"all"] || [roomIdentifier isEqualToString:@"0"] || [roomIdentifier length] == 0) {
        return [_resourceCache.lights allKeys];
    }

    TTHueRoom *room = _resourceCache.rooms[roomIdentifier];
    if (!room) return nil;

    NSMutableArray *lightIds = [NSMutableArray array];
    for (TTHueResourceLink *child in room.children) {
        if ([child.rtype isEqualToString:@"device"] || [child.rtype isEqualToString:@"light"]) {
            [lightIds addObject:child.rid];
        }
    }
    return lightIds;
}

- (void)runTTModeHueRaiseBrightness:(TTModeDirection)direction {
    [self changeBrightness:10.0];  // 10% in API v2 scale
}
- (void)doubleRunTTModeHueRaiseBrightness:(TTModeDirection)direction {
    [self changeBrightness:20.0];
}
- (void)runTTModeHueLowerBrightness:(TTModeDirection)direction {
    [self changeBrightness:-10.0];
}
- (void)doubleRunTTModeHueLowerBrightness:(TTModeDirection)direction {
    [self changeBrightness:-20.0];
}

- (void)changeBrightness:(double)amount {
    if (!_hueClient || !_resourceCache) {
        return;
    }

    NSString *roomIdentifier = [self.action optionValue:kHueRoom];
    NSArray<NSString *> *roomLights = [self roomLightsForRoom:roomIdentifier];

    // Check if we can use grouped light for efficiency
    NSDictionary<NSString *, TTHueGroupedLight *> *groupedLights = _resourceCache.groupedLights;
    if (groupedLights.count > 0 && (!roomIdentifier || [roomIdentifier isEqualToString:@"all"])) {
        // Use the first grouped light for all-room update
        NSString *groupId = [groupedLights allKeys].firstObject;
        if (groupId) {
            // Get current brightness from first light
            TTHueLight *firstLight = [_resourceCache.lights allValues].firstObject;
            double currentBrightness = firstLight.dimming ? firstLight.dimming.brightness : 50.0;
            double newBrightness = MAX(0, MIN(100, currentBrightness + amount));

            [_hueClient updateGroupedLightId:groupId
                                          on:@YES
                                  brightness:@(newBrightness)
                                  completion:^(id result, NSError *error) {
                if (error) {
                    NSLog(@" ---> Brightness change error: %@", error);
                } else {
                    NSLog(@" ---> Brightness: %.1f", newBrightness);
                }
            }];
            return;
        }
    }

    // Update each light individually
    for (NSString *lightId in _resourceCache.lights) {
        if (roomIdentifier && ![roomIdentifier isEqualToString:@"all"] && roomLights) {
            if (![roomLights containsObject:lightId]) {
                continue;
            }
        }

        TTHueLight *light = _resourceCache.lights[lightId];
        double currentBrightness = light.dimming ? light.dimming.brightness : 50.0;
        double newBrightness = MAX(0, MIN(100, currentBrightness + amount));

        [_hueClient updateLightId:lightId
                               on:@YES
                       brightness:@(newBrightness)
                               xy:nil
                     transitionMs:nil
                           effect:nil
                       completion:^(id result, NSError *error) {
            if (error) {
                NSLog(@" ---> Brightness change error: %@", error);
            } else {
                NSLog(@" ---> Brightness: %.1f", newBrightness);
            }
        }];
    }
}

- (void)runTTModeHueShiftColorLeft:(TTModeDirection)direction {
    [self shiftColor:-0.05];
}
- (void)doubleRunTTModeHueShiftColorLeft:(TTModeDirection)direction {
    [self shiftColor:-0.1];
}
- (void)runTTModeHueShiftColorRight:(TTModeDirection)direction {
    [self shiftColor:0.05];
}
- (void)doubleRunTTModeHueShiftColorRight:(TTModeDirection)direction {
    [self shiftColor:0.1];
}

- (void)shiftColor:(double)amount {
    if (!_hueClient || !_resourceCache) {
        return;
    }

    NSString *roomIdentifier = [self.action optionValue:kHueRoom];
    NSArray<NSString *> *roomLights = [self roomLightsForRoom:roomIdentifier];

    for (NSString *lightId in _resourceCache.lights) {
        if (roomIdentifier && ![roomIdentifier isEqualToString:@"all"] && roomLights) {
            if (![roomLights containsObject:lightId]) {
                continue;
            }
        }

        TTHueLight *light = _resourceCache.lights[lightId];
        if (!light.color || !light.color.xy) {
            continue;
        }

        // Shift the x value (hue shift in xy space)
        double newX = light.color.xy.x + amount;
        if (newX < 0) newX = 1.0 + newX;
        if (newX > 1.0) newX = newX - 1.0;

        TTHueXY *newXY = [[TTHueXY alloc] init];
        newXY.x = newX;
        newXY.y = light.color.xy.y;

        [_hueClient updateLightId:lightId
                               on:@YES
                       brightness:nil
                               xy:newXY
                     transitionMs:nil
                           effect:nil
                       completion:^(id result, NSError *error) {
            if (error) {
                NSLog(@" ---> Color shift error: %@", error);
            } else {
                NSLog(@" ---> Color shift complete: (%.3f, %.3f)", newX, light.color.xy.y);
            }
        }];
    }
}

#pragma mark - Hue Init

- (void)activate {
    // Re-register for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lightsUpdated:)
                                                 name:TTHueEventStreamLightsUpdatedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStreamConnected:)
                                                 name:TTHueEventStreamConnectedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStreamDisconnected:)
                                                 name:TTHueEventStreamDisconnectedNotification
                                               object:nil];
}

- (void)deactivate {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Cancel any ongoing authentication to stop background polling
    if (self.bridgeAuthenticator) {
        [self.bridgeAuthenticator cancelAuthentication];
        self.bridgeAuthenticator = nil;
    }

    // Cancel any ongoing bridge discovery
    if (self.bridgeDiscovery) {
        [self.bridgeDiscovery cancelDiscovery];
        self.bridgeDiscovery = nil;
    }

    // Cancel connection timeout timer
    [self cancelConnectionTimeout];
}

#pragma mark - Connection Timeout

- (void)startConnectionTimeout {
    [self cancelConnectionTimeout];
    self.connectionStartTime = [NSDate date];
    self.connectionTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kConnectionTimeoutSeconds
                                                                   target:self
                                                                 selector:@selector(connectionTimedOut:)
                                                                 userInfo:nil
                                                                  repeats:NO];
    NSLog(@" ---> [TTModeHue] Started connection timeout timer (%.0f seconds)", kConnectionTimeoutSeconds);
}

- (void)cancelConnectionTimeout {
    if (self.connectionTimeoutTimer) {
        [self.connectionTimeoutTimer invalidate];
        self.connectionTimeoutTimer = nil;
        NSLog(@" ---> [TTModeHue] Cancelled connection timeout timer");
    }
}

- (void)connectionTimedOut:(NSTimer *)timer {
    self.connectionTimeoutTimer = nil;

    if (self.hueState == STATE_CONNECTING) {
        NSLog(@" ---> [TTModeHue] Connection timed out after %.0f seconds", kConnectionTimeoutSeconds);

        // Cancel any in-progress operations
        if (self.bridgeDiscovery) {
            [self.bridgeDiscovery cancelDiscovery];
            self.bridgeDiscovery = nil;
        }

        self.hueState = STATE_NOT_CONNECTED;
        [self.delegate changeState:self.hueState withMode:self showMessage:@"Connection timed out. Tap to retry."];
    }
}

#pragma mark - Connection Management

- (void)connectToBridgeWithReset:(BOOL)reset {
    NSLog(@" ---> [TTModeHue] connectToBridgeWithReset:%@ (current state=%ld)", reset ? @"YES" : @"NO", (long)self.hueState);

    if (self.hueState == STATE_CONNECTING && !reset) {
        NSLog(@" ---> [TTModeHue] Already connecting, returning early");
        return;
    }

    self.hueState = STATE_CONNECTING;
    [self startConnectionTimeout];
    [self.delegate changeState:self.hueState withMode:self showMessage:@"Connecting to Hue..."];

    if (reset) {
        [self.bridgesTried removeAllObjects];
    }

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray<NSDictionary *> *savedBridges = [prefs arrayForKey:@"TT:savedHueBridges"];

    // Check if any bridges are missing usernames
    BOOL needsMigration = (savedBridges.count == 0);
    if (!needsMigration) {
        for (NSDictionary *bridge in savedBridges) {
            NSString *username = bridge[@"username"];
            if (!username || username.length == 0) {
                needsMigration = YES;
                NSLog(@" ---> Bridge %@ is missing username, attempting migration", bridge[@"serialNumber"]);
                break;
            }
        }
    }

    // Try legacy PHHueSDK credentials if needed
    if (needsMigration) {
        if ([TTHueBridgeAuthenticator migrateLegacyCredentials]) {
            // Re-read after migration
            savedBridges = [prefs arrayForKey:@"TT:savedHueBridges"];
            NSLog(@" ---> After migration, bridges: %@", savedBridges);
        }
    }

    BOOL bridgeUntried = NO;
    for (NSDictionary *savedBridge in savedBridges) {
        NSString *serialNumber = savedBridge[@"serialNumber"];
        NSString *ip = savedBridge[@"ip"];
        NSString *username = savedBridge[@"username"];

        if (!serialNumber || !ip) continue;

        if ([self.bridgesTried containsObject:serialNumber]) {
            continue;
        }

        TTHueDiscoveredBridge *bridge = [[TTHueDiscoveredBridge alloc] init];
        bridge.bridgeId = serialNumber;
        bridge.internalIPAddress = ip;

        bridgeUntried = YES;
        self.latestBridge = bridge;
        [self.bridgesTried addObject:serialNumber];

        if (DEBUG_HUE) {
            NSLog(@" ---> Connecting to bridge: %@", savedBridge);
        }

        if (username && username.length > 0) {
            [self authenticateBridgeWithUsername:username];
        } else {
            // Need to pushlink
            self.bridgeAuthenticator = [[TTHueBridgeAuthenticator alloc] init];
            self.bridgeAuthenticator.delegate = self;
            [self.bridgeAuthenticator startAuthenticationWithBridgeIP:ip bridgeId:serialNumber];
        }

        break;
    }

    if (!bridgeUntried) {
        [self searchForBridgeLocal];
    }
}

- (void)authenticateBridgeWithUsername:(NSString *)username {
    NSLog(@" ---> [TTModeHue] authenticateBridgeWithUsername: %@ (bridge=%@)", username, self.latestBridge.internalIPAddress);

    if (!self.latestBridge) {
        NSLog(@" ---> No bridge to authenticate");
        return;
    }

    if (self.hueState != STATE_CONNECTED) {
        NSLog(@" ---> [TTModeHue] Setting state to CONNECTED and initializing API client");
        [self cancelConnectionTimeout];
        self.hueState = STATE_CONNECTED;
        [self saveRecentBridgeWithUsername:username];

        // Initialize the API client
        _hueClient = [[TTHueAPIClient alloc] initWithBridgeIP:self.latestBridge.internalIPAddress
                                               applicationKey:username];

        // Fetch initial resources
        [self fetchResources];

        // Start SSE event stream for real-time updates
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startEventStreamWithUsername:username];
        });

        [self.delegate changeState:self.hueState withMode:self showMessage:nil];
    }
}

- (void)tryAuthenticateWithPendingUsername:(NSString *)username bridgeIP:(NSString *)bridgeIP bridgeId:(NSString *)bridgeId {
    NSLog(@" ---> Trying legacy username: %@", username);

    // Create a temporary API client to test if the username works
    TTHueAPIClient *testClient = [[TTHueAPIClient alloc] initWithBridgeIP:bridgeIP applicationKey:username];

    [testClient fetchLightsWithCompletion:^(NSArray<TTHueLight *> *lights, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@" ---> Legacy username failed: %@", error);

                // Username doesn't work, fall back to pushlink
                self.bridgeAuthenticator = [[TTHueBridgeAuthenticator alloc] init];
                self.bridgeAuthenticator.delegate = self;
                [self.bridgeAuthenticator startAuthenticationWithBridgeIP:bridgeIP bridgeId:bridgeId];
            } else {
                NSLog(@" ---> Legacy username works! Found %lu lights", (unsigned long)lights.count);

                // Save the credentials and authenticate
                TTHueAuthResult *result = [[TTHueAuthResult alloc] initWithBridgeIP:bridgeIP
                                                                            bridgeId:bridgeId
                                                                      applicationKey:username
                                                                           clientKey:nil];
                [TTHueBridgeAuthenticator saveCredentials:result];
                [self authenticateBridgeWithUsername:username];
            }
        });
    }];
}

- (void)fetchResources {
    if (!_hueClient) return;

    self.waitingOnScenes = YES;

    [_hueClient fetchAllResourcesWithCompletion:^(TTHueResourceCache *cache, NSError *error) {
        if (error) {
            NSLog(@" ---> Failed to fetch resources: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                // Check if this is an authentication error
                if ([error.domain isEqualToString:TTHueAPIClientErrorDomain] &&
                    error.code == TTHueAPIClientErrorNotAuthenticated) {
                    // Clear invalid credentials - user will need to re-authenticate
                    if (self.latestBridge) {
                        NSLog(@" ---> Authentication failed, removing credentials for bridge: %@", self.latestBridge.bridgeId);
                        [self removeSavedBridge:self.latestBridge.bridgeId];
                    }
                    // Don't start pushlink automatically - wait for user to open Hue options
                    [self cancelConnectionTimeout];
                    self.hueState = STATE_NOT_CONNECTED;
                    [self.delegate changeState:self.hueState withMode:self showMessage:@"Hue authentication expired. Open Hue settings to reconnect."];
                } else {
                    [self showNoConnectionDialog];
                }
            });
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            _resourceCache = cache;
            self.waitingOnScenes = NO;

            if (DEBUG_HUE) {
                NSLog(@" ---> Fetched resources: %lu lights, %lu rooms, %lu scenes",
                      (unsigned long)cache.lights.count,
                      (unsigned long)cache.rooms.count,
                      (unsigned long)cache.scenes.count);
            }

            [self.delegate changeState:self.hueState withMode:self showMessage:nil];
            [self ensureScenes];
        });
    }];
}

- (void)startEventStreamWithUsername:(NSString *)username {
    if (!self.latestBridge) {
        NSLog(@" ---> Error: No latest bridge for event stream");
        return;
    }

    _eventStream = [[TTHueEventStream alloc] initWithBridgeIP:self.latestBridge.internalIPAddress
                                               applicationKey:username];
    _eventStream.delegate = self;
    [_eventStream connect];

    self.waitingOnScenes = YES;
}

- (void)saveRecentBridgeWithUsername:(NSString *)username {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    if (!self.latestBridge) {
        NSLog(@" ---> ERROR: No latest bridge to save");
        return;
    }

    [self.bridgesTried removeAllObjects];

    NSMutableArray *previouslyFoundBridges = [[prefs arrayForKey:@"TT:savedHueBridges"] mutableCopy] ?: [NSMutableArray array];

    // Remove old entry if exists
    NSInteger oldIndex = -1;
    NSString *oldUsername = nil;
    for (NSInteger i = 0; i < previouslyFoundBridges.count; i++) {
        NSDictionary *bridge = previouslyFoundBridges[i];
        if ([bridge[@"serialNumber"] isEqualToString:self.latestBridge.bridgeId]) {
            oldIndex = i;
            oldUsername = bridge[@"username"];
            break;
        }
    }

    if (oldIndex >= 0) {
        [previouslyFoundBridges removeObjectAtIndex:oldIndex];
    }

    NSMutableDictionary *newBridge = [NSMutableDictionary dictionary];
    newBridge[@"ip"] = self.latestBridge.internalIPAddress;
    newBridge[@"deviceType"] = @"Hue Bridge";
    newBridge[@"serialNumber"] = self.latestBridge.bridgeId;

    if (username) {
        newBridge[@"username"] = username;
    } else if (oldUsername) {
        newBridge[@"username"] = oldUsername;
    }

    [previouslyFoundBridges insertObject:newBridge atIndex:0];

    [prefs setObject:previouslyFoundBridges forKey:@"TT:savedHueBridges"];
    [prefs synchronize];

    if (DEBUG_HUE) {
        NSLog(@" ---> Saved bridges (username: %@): %@", username, previouslyFoundBridges);
    }
}

- (void)removeSavedBridge:(NSString *)serialNumber {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSMutableArray *savedBridges = [[prefs arrayForKey:@"TT:savedHueBridges"] mutableCopy] ?: [NSMutableArray array];
    NSMutableArray *filteredBridges = [NSMutableArray array];

    for (NSDictionary *bridge in savedBridges) {
        if (![bridge[@"serialNumber"] isEqualToString:serialNumber]) {
            [filteredBridges addObject:bridge];
        }
    }

    [prefs setObject:filteredBridges forKey:@"TT:savedHueBridges"];
    [prefs synchronize];

    NSLog(@" ---> Removed bridge %@: %@", serialNumber, filteredBridges);
}

#pragma mark - Event Stream Notifications

- (void)lightsUpdated:(NSNotification *)notification {
    NSArray<TTHueLight *> *lights = notification.userInfo[@"lights"];
    if (!lights || !_resourceCache) return;

    // Update cache with new light states
    for (TTHueLight *light in lights) {
        [_resourceCache updateLight:light];
    }
}

- (void)eventStreamConnected:(NSNotification *)notification {
    if (DEBUG_HUE) {
        NSLog(@" ---> Event stream connected");
    }
}

- (void)eventStreamDisconnected:(NSNotification *)notification {
    NSError *error = notification.userInfo[@"error"];
    NSLog(@" ---> Event stream disconnected: %@", error.localizedDescription ?: @"unknown");
}

#pragma mark - TTHueEventStreamDelegate

- (void)eventStreamConnected {
    if (DEBUG_HUE) {
        NSLog(@" ---> Event stream delegate: connected");
    }
}

- (void)eventStreamDisconnectedWithError:(NSError *)error {
    NSLog(@" ---> Event stream delegate: disconnected - %@", error.localizedDescription ?: @"unknown");
}

- (void)eventStreamAuthenticationFailed {
    NSLog(@" ---> Event stream authentication failed - need to re-authenticate");
    // The API key is invalid - clear saved credentials so user must re-authenticate via pushlink
    if (self.latestBridge) {
        NSLog(@" ---> Removing invalid credentials for bridge: %@", self.latestBridge.bridgeId);
        [self removeSavedBridge:self.latestBridge.bridgeId];
    }

    // Don't start pushlink automatically - wait for user to open Hue options
    // This prevents background polling that wastes resources and hits rate limits
    [self cancelConnectionTimeout];
    self.hueState = STATE_NOT_CONNECTED;
    [self.delegate changeState:self.hueState withMode:self showMessage:@"Hue authentication expired. Open Hue settings to reconnect."];
}

- (void)eventStreamReceivedLightUpdates:(NSArray<TTHueLight *> *)lights {
    if (!_resourceCache) return;

    for (TTHueLight *light in lights) {
        [_resourceCache updateLight:light];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:TTHueEventStreamLightsUpdatedNotification
                                                        object:self
                                                      userInfo:@{@"lights": lights}];
}

- (void)eventStreamReceivedSceneUpdates:(NSArray<TTHueScene *> *)scenes {
    if (!_resourceCache) return;

    for (TTHueScene *scene in scenes) {
        [_resourceCache updateScene:scene];
    }
}

- (void)eventStreamReceivedRoomUpdates:(NSArray<TTHueRoom *> *)rooms {
    if (!_resourceCache) return;

    for (TTHueRoom *room in rooms) {
        [_resourceCache updateRoom:room];
    }
}

#pragma mark - Bridge searching and selection

- (void)searchForBridgeLocal {
    NSLog(@" ---> [TTModeHue] searchForBridgeLocal starting");
    self.hueState = STATE_CONNECTING;
    [self.delegate changeState:self.hueState withMode:self showMessage:@"Searching for a Hue bridge..."];

    self.bridgeDiscovery = [[TTHueBridgeDiscovery alloc] init];
    self.bridgeDiscovery.delegate = self;
    [self.bridgeDiscovery startDiscovery];
}

- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andBridgeId:(NSString *)bridgeId {
    self.hueState = STATE_CONNECTING;
    [self.delegate changeState:self.hueState withMode:self showMessage:@"Found Hue bridge..."];

    TTHueDiscoveredBridge *bridge = [[TTHueDiscoveredBridge alloc] init];
    bridge.bridgeId = bridgeId;
    bridge.internalIPAddress = ipAddress;
    self.latestBridge = bridge;

    [self saveRecentBridgeWithUsername:nil];

    // Check if there's a pending username from legacy credential migration
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pendingUsername = [defaults stringForKey:@"TT:pendingHueUsername"];

    if (pendingUsername && pendingUsername.length > 0) {
        NSLog(@" ---> Found pending username from legacy migration, trying to authenticate directly");
        // Remove the pending username
        [defaults removeObjectForKey:@"TT:pendingHueUsername"];
        [defaults synchronize];

        // Try to authenticate with the legacy username
        [self tryAuthenticateWithPendingUsername:pendingUsername bridgeIP:ipAddress bridgeId:bridgeId];
        return;
    }

    // Start pushlink authentication
    self.bridgeAuthenticator = [[TTHueBridgeAuthenticator alloc] init];
    self.bridgeAuthenticator.delegate = self;
    [self.bridgeAuthenticator startAuthenticationWithBridgeIP:ipAddress bridgeId:bridgeId];
}

#pragma mark - TTHueBridgeDiscoveryDelegate

- (void)bridgeDiscoveryStarted {
    if (DEBUG_HUE) {
        NSLog(@" ---> Bridge discovery started");
    }
}

- (void)bridgeDiscoveryFinished:(NSArray<TTHueDiscoveredBridge *> *)bridges {
    [self cancelConnectionTimeout];
    if (bridges.count > 0) {
        self.hueState = STATE_BRIDGE_SELECT;
        [self.foundBridges removeAllObjects];
        [self.foundBridges addObjectsFromArray:bridges];

        // Convert to dictionary format for delegate
        NSMutableDictionary *bridgesDict = [NSMutableDictionary dictionary];
        for (TTHueDiscoveredBridge *bridge in bridges) {
            bridgesDict[bridge.bridgeId] = bridge.internalIPAddress;
        }

        // If only one bridge found, auto-connect
        if (bridges.count == 1) {
            TTHueDiscoveredBridge *bridge = bridges.firstObject;
            [self bridgeSelectedWithIpAddress:bridge.internalIPAddress andBridgeId:bridge.bridgeId];
        } else {
            [self.delegate changeState:self.hueState withMode:self showMessage:bridgesDict];
        }
    } else {
        [self showNoBridgesFoundDialog];
    }
}

- (void)bridgeDiscoveryError:(NSError *)error {
    NSLog(@" ---> Bridge discovery error: %@", error);
    [self cancelConnectionTimeout];

    if (error.code == TTHueBridgeDiscoveryErrorRateLimited) {
        self.hueState = STATE_NOT_CONNECTED;
        [self.delegate changeState:self.hueState withMode:self showMessage:@"Philips Hue is rate-limiting requests. Please wait a moment and try again."];
    } else {
        [self showNoBridgesFoundDialog];
    }
}

#pragma mark - TTHueBridgeAuthenticatorDelegate

- (void)authenticationStarted {
    if (DEBUG_HUE) {
        NSLog(@" ---> Authentication started");
    }

    [self cancelConnectionTimeout];
    self.hueState = STATE_PUSHLINK;
    [self.delegate changeState:self.hueState withMode:self showMessage:nil];
}

- (void)authenticationProgressWithRemainingSeconds:(NSInteger)remainingSeconds {
    self.hueState = STATE_PUSHLINK;
    NSNumber *progress = @((NSInteger)(remainingSeconds * (100.0/30.0)));
    [self.delegate changeState:self.hueState withMode:self showMessage:progress];
}

- (void)authenticationSucceededWithResult:(TTHueAuthResult *)result {
    [self authenticateBridgeWithUsername:result.applicationKey];
}

- (void)authenticationFailedWithError:(NSError *)error {
    NSLog(@" ---> Authentication failed: %@ (domain: %@, code: %ld)", error.localizedDescription, error.domain, (long)error.code);
    [self cancelConnectionTimeout];

    // Handle our custom authenticator errors
    if ([error.domain isEqualToString:TTHueBridgeAuthenticatorErrorDomain]) {
        if (error.code == TTHueBridgeAuthenticatorErrorTimeout) {
            // Pushlink button not pressed within 30 seconds
            if (self.latestBridge) {
                [self removeSavedBridge:self.latestBridge.bridgeId];
            }
            self.hueState = STATE_NOT_CONNECTED;
            [self.delegate changeState:self.hueState withMode:self showMessage:@"Pushlink button not pressed within 30 seconds"];
        } else if (error.code == TTHueBridgeAuthenticatorErrorNetwork) {
            // Network error - could be local network permission
            NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
            if (underlyingError && underlyingError.code == -1009) {
                self.hueState = STATE_NOT_CONNECTED;
                [self.delegate changeState:self.hueState withMode:self showMessage:@"Local network access required. Please grant permission in System Settings."];
            } else {
                self.hueState = STATE_NOT_CONNECTED;
                [self.delegate changeState:self.hueState withMode:self showMessage:@"Could not connect to Hue bridge. Check your network connection."];
            }
        } else {
            // Other authenticator errors (invalid response, auth failed, etc.)
            self.hueState = STATE_NOT_CONNECTED;
            [self.delegate changeState:self.hueState withMode:self showMessage:[NSString stringWithFormat:@"Authentication failed: %@", error.localizedDescription]];
        }
        return;
    }

    // Handle NSURLError domain errors (for legacy compatibility)
    if (error.code == -1009) {
        // Network offline / Local network prohibited
        self.hueState = STATE_NOT_CONNECTED;
        [self.delegate changeState:self.hueState withMode:self showMessage:@"Local network access required. Please grant permission in System Settings."];
    } else if (error.code == -1001 || error.code == -1004) {
        // Timeout or could not connect to server
        self.hueState = STATE_NOT_CONNECTED;
        [self.delegate changeState:self.hueState withMode:self showMessage:@"Could not connect to Hue bridge"];
    } else {
        // Unknown error - don't retry to avoid infinite loop
        self.hueState = STATE_NOT_CONNECTED;
        [self.delegate changeState:self.hueState withMode:self showMessage:[NSString stringWithFormat:@"Connection error: %@", error.localizedDescription]];
    }
}

#pragma mark - Dialog methods

- (void)showNoConnectionDialog {
    NSLog(@"Connection to bridge lost!");
    [self cancelConnectionTimeout];
    self.hueState = STATE_NOT_CONNECTED;
    [self.delegate changeState:self.hueState withMode:self showMessage:@"Connection to Hue bridge lost"];
}

- (void)showNoBridgesFoundDialog {
    NSLog(@"Could not find bridge!");
    [self cancelConnectionTimeout];
    self.hueState = STATE_NOT_CONNECTED;
    [self.delegate changeState:self.hueState withMode:self showMessage:@"Could not find any Hue bridges"];
}

- (void)showNotAuthenticatedDialog {
    [self cancelConnectionTimeout];
    self.hueState = STATE_NOT_CONNECTED;
    [self.delegate changeState:self.hueState withMode:self showMessage:@"Pushlink button not pressed within 30 seconds"];
    NSLog(@"Pushlink button not pressed within 30 sec!");
}

#pragma mark - Scene Management

- (void)ensureScenes {
    if (!_resourceCache || _resourceCache.scenes.count == 0 || _resourceCache.lights.count == 0) {
        NSLog(@" ---> Scenes/lights not ready yet for scene creation");
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.ensuringScenes) {
            NSLog(@" ---> Already ensuring scenes...");
            return;
        }
        self.ensuringScenes = YES;

        // Collect existing scene names
        [self.foundScenes removeAllObjects];
        for (NSString *sceneId in _resourceCache.scenes) {
            TTHueScene *scene = _resourceCache.scenes[sceneId];
            [self.foundScenes addObject:scene.metadata.name];
        }

        // Create scenes that don't exist
        [self ensureSceneWithName:@"Early evening" actionName:@"TTModeHueSceneEarlyEvening" isDouble:NO
                     colorHandler:^NSColor *(TTHueLight *light, NSUInteger index) {
            return [NSColor colorWithRed:235/255.0 green:206/255.0 blue:146/255.0 alpha:1.0];
        } brightnessHandler:^double(NSUInteger index) {
            return 100.0;
        }];

        [self ensureSceneWithName:@"Early evening 2" actionName:@"TTModeHueSceneEarlyEvening" isDouble:YES
                     colorHandler:^NSColor *(TTHueLight *light, NSUInteger index) {
            if (index % 3 == 2) {
                return [NSColor colorWithRed:44/255.0 green:56/255.0 blue:225/255.0 alpha:1.0];
            }
            return [NSColor colorWithRed:245/255.0 green:176/255.0 blue:116/255.0 alpha:1.0];
        } brightnessHandler:^double(NSUInteger index) {
            return 78.0;
        }];

        [self ensureSceneWithName:@"Late evening" actionName:@"TTModeHueSceneLateEvening" isDouble:NO
                     colorHandler:^NSColor *(TTHueLight *light, NSUInteger index) {
            return [NSColor colorWithRed:95/255.0 green:76/255.0 blue:36/255.0 alpha:1.0];
        } brightnessHandler:^double(NSUInteger index) {
            return 60.0;
        }];

        [self ensureSceneWithName:@"Late evening 2" actionName:@"TTModeHueSceneLateEvening" isDouble:YES
                     colorHandler:^NSColor *(TTHueLight *light, NSUInteger index) {
            if (index % 3 == 2) {
                return [NSColor colorWithRed:134/255.0 green:56/255.0 blue:205/255.0 alpha:1.0];
            }
            return [NSColor colorWithRed:145/255.0 green:76/255.0 blue:16/255.0 alpha:1.0];
        } brightnessHandler:^double(NSUInteger index) {
            return (index % 3 == 2) ? 80.0 : 60.0;
        }];

        [self ensureSceneWithName:@"All Lights Off" actionName:@"TTModeHueOff" isDouble:NO
                     colorHandler:nil brightnessHandler:^double(NSUInteger index) {
            return 0.0;
        }];

        self.ensuringScenes = NO;
    });
}

- (void)ensureSceneWithName:(NSString *)sceneName
                 actionName:(NSString *)actionName
                   isDouble:(BOOL)isDouble
               colorHandler:(NSColor * (^)(TTHueLight *light, NSUInteger index))colorHandler
          brightnessHandler:(double (^)(NSUInteger index))brightnessHandler {

    // Check if scene already exists
    if ([self.foundScenes containsObject:sceneName]) {
        if (DEBUG_HUE) {
            NSLog(@" ---> Scene '%@' already exists", sceneName);
        }
        return;
    }

    if ([self.createdScenes containsObject:sceneName]) {
        return;
    }
    [self.createdScenes addObject:sceneName];

    if (!_hueClient || !_resourceCache || _resourceCache.lights.count == 0) {
        return;
    }

    NSLog(@" ---> Creating scene '%@'", sceneName);

    // Find a room and scope lights to that room
    NSString *roomId = [_resourceCache.rooms allKeys].firstObject ?: @"";
    TTHueRoom *room = _resourceCache.rooms[roomId];

    // Get device IDs that belong to this room
    NSMutableSet<NSString *> *roomDeviceIds = [NSMutableSet set];
    for (TTHueResourceLink *child in room.children) {
        if ([child.rtype isEqualToString:@"device"]) {
            [roomDeviceIds addObject:child.rid];
        }
    }

    // Build scene actions only for lights in the room
    NSMutableArray<TTHueSceneAction *> *actions = [NSMutableArray array];
    NSArray<NSString *> *lightIds = [_resourceCache.lights allKeys];
    NSUInteger index = 0;

    for (NSString *lightId in lightIds) {
        TTHueLight *light = _resourceCache.lights[lightId];

        // Only include lights whose owner device is in the room
        if (room && roomDeviceIds.count > 0 && light.owner) {
            if (![roomDeviceIds containsObject:light.owner.rid]) {
                continue;
            }
        }

        BOOL isOn = brightnessHandler(index) > 0;
        double brightness = brightnessHandler(index);
        TTHueXY *xy = nil;

        // Only set color on lights that support it
        if (colorHandler && light.color != nil) {
            NSColor *color = colorHandler(light, index);
            if (color) {
                xy = [TTHueColorUtilities calculateHueXYFromColor:color forModel:light.metadata.archetype];
            }
        }

        TTHueSceneAction *action = [TTHueAPIClient createSceneActionWithLightId:lightId
                                                                             on:isOn
                                                                     brightness:@(brightness)
                                                                             xy:xy];
        [actions addObject:action];
        index++;
    }

    [_hueClient createSceneWithName:sceneName
                             roomId:roomId
                            actions:actions
                         completion:^(id result, NSError *error) {
        if (error) {
            NSLog(@" ---> Error creating scene '%@': %@", sceneName, error);
        } else {
            NSLog(@" ---> Created scene '%@': %@", sceneName, result);

            // Refresh scenes
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchResources];
            });
        }
    }];
}

@end
