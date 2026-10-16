//
//  TTModeNanoleaf.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTModeNanoleaf.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

NSString *const kNanoleafSavedDevices = @"nanoleafSavedDevices";
NSString *const kNanoleafScene = @"nanoleafScene";
NSString *const kDoubleTapNanoleafScene = @"doubleTapNanoleafScene";
NSString *const kNanoleafDuration = @"nanoleafDuration";
NSString *const kNanoleafDoubleTapDuration = @"nanoleafDoubleTapDuration";

NSInteger const kNanoleafApiPort = 16021;
NSInteger const kNanoleafBrightnessStep = 10;

static TTNanoleafState _nanoleafState = NANOLEAF_STATE_NOT_CONNECTED;
static NSString *_deviceIp = nil;
static NSString *_deviceName = nil;
static NSString *_authToken = nil;
static NSMutableArray<NSString *> *_cachedEffects = nil;

static nw_browser_t _nwBrowser = nil;
static NSMutableArray *_resolvedDevices = nil;
static NSTimer *_authTimer = nil;
static NSInteger _authAttempts = 0;
static const NSInteger kMaxAuthAttempts = 30;

@interface TTModeNanoleaf ()

@property (nonatomic, strong) NSTimer *discoveryTimeout;
@property (nonatomic) BOOL subnetScanInProgress;

@end

@implementation TTModeNanoleaf

#pragma mark - Class Property Accessors

+ (NSString *)deviceIp {
    return _deviceIp;
}

+ (NSString *)deviceName {
    return _deviceName;
}

+ (NSString *)authToken {
    return _authToken;
}

+ (NSArray<NSString *> *)cachedEffects {
    return _cachedEffects ?: @[];
}

+ (void)updateCachedEffects:(NSArray<NSString *> *)effects {
    if (!_cachedEffects) {
        _cachedEffects = [NSMutableArray array];
    }
    [_cachedEffects removeAllObjects];
    [_cachedEffects addObjectsFromArray:effects ?: @[]];
}

+ (TTNanoleafState)currentState {
    return _nanoleafState;
}

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        if (!_cachedEffects) {
            _cachedEffects = [NSMutableArray array];
        }
    }
    return self;
}

#pragma mark - Mode

+ (NSString *)title {
    return @"Nanoleaf";
}

+ (NSString *)description {
    return @"Light panels and effects";
}

+ (NSString *)imageName {
    return @"mode_nanoleaf.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeNanoleafToggle",
             @"TTModeNanoleafSceneCustom",
             @"TTModeNanoleafRaiseBrightness",
             @"TTModeNanoleafLowerBrightness",
             @"TTModeNanoleafSleep",
             ];
}

- (NSArray *)optionlessActions {
    return @[@"TTModeNanoleafToggle",
             @"TTModeNanoleafRaiseBrightness",
             @"TTModeNanoleafLowerBrightness",
             ];
}

- (BOOL)shouldUseModeOptionsForTTModeNanoleafToggle {
    return _nanoleafState != NANOLEAF_STATE_CONNECTED;
}

- (BOOL)shouldUseModeOptionsForTTModeNanoleafSceneCustom {
    return _nanoleafState != NANOLEAF_STATE_CONNECTED;
}

- (BOOL)shouldUseModeOptionsForTTModeNanoleafRaiseBrightness {
    return _nanoleafState != NANOLEAF_STATE_CONNECTED;
}

- (BOOL)shouldUseModeOptionsForTTModeNanoleafLowerBrightness {
    return _nanoleafState != NANOLEAF_STATE_CONNECTED;
}

- (BOOL)shouldUseModeOptionsForTTModeNanoleafSleep {
    return _nanoleafState != NANOLEAF_STATE_CONNECTED;
}

#pragma mark - Action Titles

- (NSString *)titleTTModeNanoleafToggle {
    return @"Toggle on/off";
}

- (NSString *)titleTTModeNanoleafSceneCustom {
    NSString *effectName = [self.action optionValue:kNanoleafScene inDirection:self.action.direction];
    if (effectName && [effectName length] > 0) {
        return effectName;
    }
    return @"Trigger effect";
}

- (NSString *)doubleTitleTTModeNanoleafSceneCustom {
    return @"Effect 2";
}

- (NSString *)titleTTModeNanoleafRaiseBrightness {
    return @"Raise brightness";
}

- (NSString *)titleTTModeNanoleafLowerBrightness {
    return @"Lower brightness";
}

- (NSString *)titleTTModeNanoleafSleep {
    return @"Sleep";
}

- (NSString *)doubleTitleTTModeNanoleafSleep {
    return @"Sleep fast";
}

#pragma mark - Action Images

- (NSString *)imageTTModeNanoleafToggle {
    return @"nanoleaf_toggle.png";
}

- (NSString *)imageTTModeNanoleafSceneCustom {
    return @"nanoleaf_scene.png";
}

- (NSString *)imageTTModeNanoleafRaiseBrightness {
    return @"nanoleaf_brightness_up.png";
}

- (NSString *)imageTTModeNanoleafLowerBrightness {
    return @"nanoleaf_brightness_down.png";
}

- (NSString *)imageTTModeNanoleafSleep {
    return @"nanoleaf_sleep.png";
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeNanoleafToggle";
}

- (NSString *)defaultEast {
    return @"TTModeNanoleafRaiseBrightness";
}

- (NSString *)defaultWest {
    return @"TTModeNanoleafLowerBrightness";
}

- (NSString *)defaultSouth {
    return @"TTModeNanoleafSleep";
}

#pragma mark - Activate / Deactivate

- (void)activate {
    if (_nanoleafState == NANOLEAF_STATE_NOT_CONNECTED) {
        [self connectToDevice];
    }
}

- (void)deactivate {
    if (_nwBrowser) {
        nw_browser_cancel(_nwBrowser);
        _nwBrowser = nil;
    }
    [_authTimer invalidate];
    _authTimer = nil;
    [self.discoveryTimeout invalidate];
    self.discoveryTimeout = nil;
}

#pragma mark - Action Methods

- (void)runTTModeNanoleafToggle {
    [self fetchDeviceInfoWithCompletion:^(NSDictionary *info, NSError *error) {
        if (error) {
            NSLog(@" ---> Nanoleaf toggle error: %@", error);
            return;
        }
        NSDictionary *state = info[@"state"];
        NSDictionary *on = state[@"on"];
        BOOL currentlyOn = [on[@"value"] boolValue];

        [self setPower:!currentlyOn completion:^(NSError *err) {
            if (err) {
                NSLog(@" ---> Nanoleaf toggle error: %@", err);
            } else {
                NSLog(@" ---> Nanoleaf toggled to %@", !currentlyOn ? @"on" : @"off");
            }
        }];
    }];
}

- (void)runTTModeNanoleafSceneCustom {
    NSString *effectName = [self.action optionValue:kNanoleafScene];
    if (!effectName || [effectName length] == 0) {
        NSLog(@" ---> No Nanoleaf effect selected");
        return;
    }
    [self setPower:YES completion:^(NSError *error) {
        [self setEffect:effectName completion:^(NSError *err) {
            if (err) {
                NSLog(@" ---> Nanoleaf scene error: %@", err);
            } else {
                NSLog(@" ---> Nanoleaf effect: %@", effectName);
            }
        }];
    }];
}

- (void)doubleRunTTModeNanoleafSceneCustom {
    NSString *effectName = [self.action optionValue:kDoubleTapNanoleafScene];
    if (!effectName || [effectName length] == 0) {
        NSLog(@" ---> No Nanoleaf double-tap effect selected");
        return;
    }
    [self setPower:YES completion:^(NSError *error) {
        [self setEffect:effectName completion:^(NSError *err) {
            if (err) {
                NSLog(@" ---> Nanoleaf double scene error: %@", err);
            } else {
                NSLog(@" ---> Nanoleaf double effect: %@", effectName);
            }
        }];
    }];
}

- (void)runTTModeNanoleafRaiseBrightness {
    [self changeBrightness:kNanoleafBrightnessStep];
}

- (void)doubleRunTTModeNanoleafRaiseBrightness {
    [self changeBrightness:kNanoleafBrightnessStep * 2];
}

- (void)runTTModeNanoleafLowerBrightness {
    [self changeBrightness:-kNanoleafBrightnessStep];
}

- (void)doubleRunTTModeNanoleafLowerBrightness {
    [self changeBrightness:-kNanoleafBrightnessStep * 2];
}

- (void)changeBrightness:(NSInteger)amount {
    [self fetchDeviceInfoWithCompletion:^(NSDictionary *info, NSError *error) {
        if (error) {
            NSLog(@" ---> Nanoleaf brightness error: %@", error);
            return;
        }
        NSDictionary *state = info[@"state"];
        NSDictionary *bri = state[@"brightness"];
        NSInteger currentBri = [bri[@"value"] integerValue];
        NSInteger newBri = MAX(0, MIN(100, currentBri + amount));

        void (^setBri)(void) = ^{
            [self setBrightness:newBri duration:0 completion:^(NSError *err) {
                if (err) {
                    NSLog(@" ---> Nanoleaf brightness error: %@", err);
                } else {
                    NSLog(@" ---> Nanoleaf brightness: %ld -> %ld", (long)currentBri, (long)newBri);
                }
            }];
        };

        if (newBri > 0) {
            [self setPower:YES completion:^(NSError *err) {
                setBri();
            }];
        } else {
            setBri();
        }
    }];
}

- (void)runTTModeNanoleafSleep {
    NSNumber *duration = [self.action optionValue:kNanoleafDuration];
    NSInteger durationSec = duration ? [duration integerValue] : 30;
    [self runSleep:durationSec];
}

- (void)doubleRunTTModeNanoleafSleep {
    NSNumber *duration = [self.action optionValue:kNanoleafDoubleTapDuration];
    NSInteger durationSec = duration ? [duration integerValue] : 2;
    [self runSleep:durationSec];
}

- (void)runSleep:(NSInteger)duration {
    // transTime is in 1/10th seconds for the Nanoleaf API
    [self setBrightness:0 duration:duration * 10 completion:^(NSError *error) {
        if (error) {
            NSLog(@" ---> Nanoleaf sleep error: %@", error);
            return;
        }
        NSLog(@" ---> Nanoleaf sleeping over %lds", (long)duration);
        // After the transition completes, turn off
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setPower:NO completion:nil];
        });
    }];
}

- (BOOL)shouldIgnoreSingleBeforeDoubleTTModeNanoleafSceneCustom {
    return YES;
}

- (BOOL)shouldIgnoreSingleBeforeDoubleTTModeNanoleafSleep {
    return YES;
}

#pragma mark - Connection

- (void)connectToDevice {
    _nanoleafState = NANOLEAF_STATE_NOT_CONNECTED;
    self.nanoleafState = _nanoleafState;

    // Try saved device first
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray<NSDictionary *> *savedDevices = [prefs arrayForKey:kNanoleafSavedDevices];

    if (savedDevices.count > 0) {
        NSDictionary *saved = savedDevices.firstObject;
        NSString *ip = saved[@"ip"];
        NSString *token = saved[@"token"];
        NSString *name = saved[@"name"];

        if (ip && token) {
            _deviceIp = ip;
            _authToken = token;
            _deviceName = name;

            _nanoleafState = NANOLEAF_STATE_CONNECTING;
            self.nanoleafState = _nanoleafState;
            [self.delegate changeState:_nanoleafState withMode:self
                           showMessage:[NSString stringWithFormat:@"Connecting to %@...", name ?: @"Nanoleaf"]];

            // Verify the saved device is reachable
            [self fetchDeviceInfoWithCompletion:^(NSDictionary *info, NSError *error) {
                if (error) {
                    NSLog(@" ---> Saved Nanoleaf unreachable, discovering: %@", error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self findDevices];
                    });
                    return;
                }

                NSString *deviceName = info[@"name"] ?: name;
                [self fetchEffectsWithCompletion:^(NSArray<NSString *> *effects, NSError *err) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _deviceName = deviceName;
                        [_cachedEffects removeAllObjects];
                        [_cachedEffects addObjectsFromArray:effects ?: @[]];
                        _nanoleafState = NANOLEAF_STATE_CONNECTED;
                        self.nanoleafState = _nanoleafState;
                        [self.delegate changeState:_nanoleafState withMode:self showMessage:nil];
                        NSLog(@" ---> Nanoleaf connected: %@ with %lu effects", deviceName, (unsigned long)effects.count);
                    });
                }];
            }];
            return;
        }
    }

    [self findDevices];
}

+ (NSString *)mdnsHostname:(NSString *)serviceName {
    NSString *hostname = [serviceName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    hostname = [hostname stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    return [hostname stringByAppendingString:@".local"];
}

- (void)findDevices {
    _nanoleafState = NANOLEAF_STATE_CONNECTING;
    self.nanoleafState = _nanoleafState;
    [self.delegate changeState:_nanoleafState withMode:self showMessage:@"Searching for Nanoleaf..."];

    if (!_resolvedDevices) {
        _resolvedDevices = [NSMutableArray array];
    }
    [_resolvedDevices removeAllObjects];

    // Cancel any existing browser
    if (_nwBrowser) {
        nw_browser_cancel(_nwBrowser);
        _nwBrowser = nil;
    }

    // Create NWBrowser for Nanoleaf mDNS discovery (uses Network framework, no multicast entitlement needed)
    nw_browse_descriptor_t descriptor = nw_browse_descriptor_create_bonjour_service("_nanoleafapi._tcp", NULL);
    nw_parameters_t params = nw_parameters_create();
    nw_parameters_set_include_peer_to_peer(params, true);
    _nwBrowser = nw_browser_create(descriptor, params);

    __weak typeof(self) weakSelf = self;

    nw_browser_set_browse_results_changed_handler(_nwBrowser, ^(nw_browse_result_t oldResult, nw_browse_result_t newResult, bool batchComplete) {
        if (!newResult) return;

        nw_browse_result_change_t change = nw_browse_result_get_changes(oldResult, newResult);
        if (change & nw_browse_result_change_result_added) {
            nw_endpoint_t endpoint = nw_browse_result_copy_endpoint(newResult);
            if (!endpoint) return;
            const char *nameStr = nw_endpoint_get_bonjour_service_name(endpoint);
            if (!nameStr) return;
            NSString *serviceName = [NSString stringWithUTF8String:nameStr];

            // Check if already found
            for (NSDictionary *device in _resolvedDevices) {
                if ([device[@"name"] isEqualToString:serviceName]) return;
            }

            // Resolve by making a TCP connection to get the IP address
            nw_connection_t connection = nw_connection_create(endpoint, nw_parameters_create_secure_tcp(NW_PARAMETERS_DISABLE_PROTOCOL, NW_PARAMETERS_DEFAULT_CONFIGURATION));
            nw_connection_set_queue(connection, dispatch_get_main_queue());

            nw_connection_set_state_changed_handler(connection, ^(nw_connection_state_t state, nw_error_t error) {
                if (state == nw_connection_state_ready) {
                    nw_path_t path = nw_connection_copy_current_path(connection);
                    NSString *ip = nil;

                    if (path) {
                        nw_endpoint_t remoteEndpoint = nw_path_copy_effective_remote_endpoint(path);
                        if (remoteEndpoint) {
                            const char *host = nw_endpoint_get_hostname(remoteEndpoint);
                            if (host) {
                                NSString *rawHost = [NSString stringWithUTF8String:host];
                                if ([rawHost containsString:@":"]) {
                                    // IPv6 - use .local hostname instead
                                    ip = [TTModeNanoleaf mdnsHostname:serviceName];
                                } else {
                                    ip = rawHost;
                                }
                            }
                        }
                    }

                    if (!ip) {
                        ip = [TTModeNanoleaf mdnsHostname:serviceName];
                    }

                    NSLog(@" ---> Nanoleaf discovered: %@ at %@", serviceName, ip);

                    // Check again for duplicates on main queue
                    BOOL duplicate = NO;
                    for (NSDictionary *device in _resolvedDevices) {
                        if ([device[@"name"] isEqualToString:serviceName]) {
                            duplicate = YES;
                            break;
                        }
                    }

                    if (!duplicate) {
                        [_resolvedDevices addObject:@{@"name": serviceName, @"ip": ip}];

                        if (_resolvedDevices.count == 1) {
                            [weakSelf.discoveryTimeout invalidate];
                            weakSelf.discoveryTimeout = nil;
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                if (_resolvedDevices.count >= 1 && _nanoleafState == NANOLEAF_STATE_CONNECTING) {
                                    if (_nwBrowser) {
                                        nw_browser_cancel(_nwBrowser);
                                        _nwBrowser = nil;
                                    }
                                    [weakSelf deviceSelectedWithName:_resolvedDevices[0][@"name"] ip:_resolvedDevices[0][@"ip"]];
                                }
                            });
                        }
                    }

                    nw_connection_cancel(connection);
                } else if (state == nw_connection_state_failed) {
                    // Connection failed - use .local hostname as fallback
                    NSString *hostname = [TTModeNanoleaf mdnsHostname:serviceName];
                    NSLog(@" ---> Nanoleaf discovered (via hostname): %@ at %@", serviceName, hostname);

                    BOOL duplicate = NO;
                    for (NSDictionary *device in _resolvedDevices) {
                        if ([device[@"name"] isEqualToString:serviceName]) {
                            duplicate = YES;
                            break;
                        }
                    }

                    if (!duplicate) {
                        [_resolvedDevices addObject:@{@"name": serviceName, @"ip": hostname}];

                        if (_resolvedDevices.count == 1) {
                            [weakSelf.discoveryTimeout invalidate];
                            weakSelf.discoveryTimeout = nil;
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                if (_resolvedDevices.count >= 1 && _nanoleafState == NANOLEAF_STATE_CONNECTING) {
                                    if (_nwBrowser) {
                                        nw_browser_cancel(_nwBrowser);
                                        _nwBrowser = nil;
                                    }
                                    [weakSelf deviceSelectedWithName:_resolvedDevices[0][@"name"] ip:_resolvedDevices[0][@"ip"]];
                                }
                            });
                        }
                    }

                    nw_connection_cancel(connection);
                }
            });

            nw_connection_start(connection);
        }
    });

    nw_browser_set_state_changed_handler(_nwBrowser, ^(nw_browser_state_t state, nw_error_t error) {
        if (state == nw_browser_state_failed) {
            NSLog(@" ---> Nanoleaf NWBrowser failed (likely missing multicast entitlement): %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                // NWBrowser failed - fall back to subnet scan
                [weakSelf.discoveryTimeout invalidate];
                weakSelf.discoveryTimeout = nil;
                if (_nwBrowser) {
                    nw_browser_cancel(_nwBrowser);
                    _nwBrowser = nil;
                }
                [weakSelf scanSubnetForDevices];
            });
        }
    });

    nw_browser_set_queue(_nwBrowser, dispatch_get_main_queue());
    nw_browser_start(_nwBrowser);

    // Timeout after 10 seconds
    [self.discoveryTimeout invalidate];
    self.discoveryTimeout = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                             target:self
                                                           selector:@selector(discoveryTimedOut)
                                                           userInfo:nil
                                                            repeats:NO];
}

- (void)discoveryTimedOut {
    if (_nwBrowser) {
        nw_browser_cancel(_nwBrowser);
        _nwBrowser = nil;
    }

    if (_resolvedDevices.count == 0) {
        _nanoleafState = NANOLEAF_STATE_NOT_CONNECTED;
        self.nanoleafState = _nanoleafState;
        [self.delegate changeState:_nanoleafState withMode:self showMessage:@"No Nanoleaf devices found"];
    } else {
        [self deviceSelectedWithName:_resolvedDevices[0][@"name"] ip:_resolvedDevices[0][@"ip"]];
    }
}

#pragma mark - Subnet Scan Fallback

- (void)scanSubnetForDevices {
    if (self.subnetScanInProgress) return;
    self.subnetScanInProgress = YES;

    NSLog(@" ---> Nanoleaf: Starting subnet scan fallback for port %ld", (long)kNanoleafApiPort);
    [self.delegate changeState:_nanoleafState withMode:self showMessage:@"Scanning local network..."];

    // Collect all local /24 subnets from non-loopback IPv4 interfaces
    NSMutableSet<NSString *> *subnets = [NSMutableSet set];

    struct ifaddrs *interfaces = NULL;
    if (getifaddrs(&interfaces) == 0) {
        struct ifaddrs *temp = interfaces;
        while (temp != NULL) {
            if (temp->ifa_addr && temp->ifa_addr->sa_family == AF_INET) {
                // Skip loopback, point-to-point (VPN/Tailscale), and down interfaces
                if (!(temp->ifa_flags & IFF_LOOPBACK) &&
                    !(temp->ifa_flags & IFF_POINTOPOINT) &&
                    (temp->ifa_flags & IFF_UP)) {
                    char addrBuf[INET_ADDRSTRLEN];
                    struct sockaddr_in *addr = (struct sockaddr_in *)temp->ifa_addr;
                    inet_ntop(AF_INET, &addr->sin_addr, addrBuf, sizeof(addrBuf));
                    NSString *ip = [NSString stringWithUTF8String:addrBuf];

                    // Check subnet mask - skip /32 and other unusable masks
                    if (temp->ifa_netmask && temp->ifa_netmask->sa_family == AF_INET) {
                        struct sockaddr_in *mask = (struct sockaddr_in *)temp->ifa_netmask;
                        uint32_t maskBits = ntohl(mask->sin_addr.s_addr);
                        if (maskBits == 0xFFFFFFFF) {
                            // /32 mask - single host, skip
                            temp = temp->ifa_next;
                            continue;
                        }
                    }

                    // Extract /24 subnet prefix (first 3 octets)
                    NSArray *octets = [ip componentsSeparatedByString:@"."];
                    if (octets.count == 4) {
                        NSString *subnet = [NSString stringWithFormat:@"%@.%@.%@", octets[0], octets[1], octets[2]];
                        [subnets addObject:subnet];
                        NSLog(@" ---> Nanoleaf: Found subnet %@.0/24 on interface %s", subnet, temp->ifa_name);
                    }
                }
            }
            temp = temp->ifa_next;
        }
        freeifaddrs(interfaces);
    }

    if (subnets.count == 0) {
        NSLog(@" ---> Nanoleaf: No suitable network interfaces found for subnet scan");
        self.subnetScanInProgress = NO;
        _nanoleafState = NANOLEAF_STATE_NOT_CONNECTED;
        self.nanoleafState = _nanoleafState;
        [self.delegate changeState:_nanoleafState withMode:self showMessage:@"No network interfaces found"];
        return;
    }

    // Build list of all IPs to scan
    NSMutableArray<NSString *> *ipsToScan = [NSMutableArray array];
    for (NSString *subnet in subnets) {
        for (int i = 1; i <= 254; i++) {
            [ipsToScan addObject:[NSString stringWithFormat:@"%@.%d", subnet, i]];
        }
    }

    NSLog(@" ---> Nanoleaf: Scanning %lu IPs across %lu subnet(s)", (unsigned long)ipsToScan.count, (unsigned long)subnets.count);

    __weak typeof(self) weakSelf = self;

    // Use NSURLSession with short timeouts to probe each IP on port 16021
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.timeoutIntervalForRequest = 2.0;
    config.timeoutIntervalForResource = 3.0;
    config.HTTPMaximumConnectionsPerHost = 1;
    NSURLSession *scanSession = [NSURLSession sessionWithConfiguration:config];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_t group = dispatch_group_create();
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(40);
        NSMutableArray<NSDictionary *> *foundDevices = [NSMutableArray array];
        NSObject *lock = [[NSObject alloc] init];

        for (NSString *ip in ipsToScan) {
            dispatch_group_enter(group);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

            // Make an HTTP request to port 16021 - any HTTP response means Nanoleaf
            NSString *urlStr = [NSString stringWithFormat:@"http://%@:%ld/", ip, (long)kNanoleafApiPort];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSURLSessionDataTask *task = [scanSession dataTaskWithURL:url
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse) {
                    // Any HTTP response on port 16021 means it's a Nanoleaf
                    NSLog(@" ---> Nanoleaf: HTTP %ld from %@:%ld - found device!",
                          (long)httpResponse.statusCode, ip, (long)kNanoleafApiPort);
                    @synchronized(lock) {
                        [foundDevices addObject:@{@"name": @"Nanoleaf", @"ip": ip}];
                    }
                }
                dispatch_semaphore_signal(semaphore);
                dispatch_group_leave(group);
            }];
            [task resume];
        }

        // Wait for all scans to complete
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)));
        [scanSession invalidateAndCancel];

        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.subnetScanInProgress = NO;

            if (foundDevices.count == 0) {
                NSLog(@" ---> Nanoleaf: Subnet scan found no devices");
                _nanoleafState = NANOLEAF_STATE_NOT_CONNECTED;
                weakSelf.nanoleafState = _nanoleafState;
                [weakSelf.delegate changeState:_nanoleafState withMode:weakSelf showMessage:@"No Nanoleaf devices found"];
                return;
            }

            NSLog(@" ---> Nanoleaf: Subnet scan found %lu device(s)", (unsigned long)foundDevices.count);

            // Add to _resolvedDevices and select the first one
            if (!_resolvedDevices) {
                _resolvedDevices = [NSMutableArray array];
            }
            for (NSDictionary *device in foundDevices) {
                BOOL duplicate = NO;
                for (NSDictionary *existing in _resolvedDevices) {
                    if ([existing[@"ip"] isEqualToString:device[@"ip"]]) {
                        duplicate = YES;
                        break;
                    }
                }
                if (!duplicate) {
                    [_resolvedDevices addObject:device];
                }
            }

            [weakSelf deviceSelectedWithName:foundDevices[0][@"name"] ip:foundDevices[0][@"ip"]];
        });
    });
}

#pragma mark - Device Selection and Authentication

- (void)deviceSelectedWithName:(NSString *)name ip:(NSString *)ip {
    _deviceIp = ip;
    _deviceName = name;

    // Check if we have a saved token for this IP
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray<NSDictionary *> *savedDevices = [prefs arrayForKey:kNanoleafSavedDevices];
    for (NSDictionary *saved in savedDevices) {
        if ([saved[@"ip"] isEqualToString:ip]) {
            NSString *token = saved[@"token"];
            if (token) {
                _authToken = token;
                [self authenticateDevice];
                return;
            }
        }
    }

    // No saved token, start auth flow
    [self startAuthentication:ip];
}

- (void)startAuthentication:(NSString *)ip {
    _nanoleafState = NANOLEAF_STATE_PUSHLINK;
    self.nanoleafState = _nanoleafState;
    _authAttempts = 0;
    [self.delegate changeState:_nanoleafState withMode:self showMessage:@100];

    [_authTimer invalidate];
    _authTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(authTimerFired:)
                                                userInfo:ip
                                                 repeats:YES];
}

- (void)authTimerFired:(NSTimer *)timer {
    NSString *ip = timer.userInfo;
    _authAttempts++;
    NSInteger remaining = kMaxAuthAttempts - _authAttempts;

    if (remaining <= 0) {
        [timer invalidate];
        _authTimer = nil;
        _nanoleafState = NANOLEAF_STATE_NOT_CONNECTED;
        self.nanoleafState = _nanoleafState;
        [self.delegate changeState:_nanoleafState withMode:self showMessage:@"Authentication timed out"];
        return;
    }

    NSNumber *progress = @((NSInteger)((double)remaining / (double)kMaxAuthAttempts * 100));
    [self.delegate changeState:_nanoleafState withMode:self showMessage:progress];

    [self attemptAuth:ip];
}

- (void)attemptAuth:(NSString *)ip {
    NSString *host = [TTModeNanoleaf formatHostForURL:ip];
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%ld/api/v1/new", host, (long)kNanoleafApiPort];
    NSURL *url = [NSURL URLWithString:urlStr];
    if (!url) return;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 2;

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) return; // Expected - button not pressed yet

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200 || !data) return;

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *token = json[@"auth_token"];
        if (!token) return;

        dispatch_async(dispatch_get_main_queue(), ^{
            [_authTimer invalidate];
            _authTimer = nil;
            _authToken = token;
            [self saveDeviceWithIp:ip token:token name:_deviceName];
            [self authenticateDevice];
            NSLog(@" ---> Nanoleaf auth token received: %@...", [token substringToIndex:MIN(8, token.length)]);
        });
    }];
    [task resume];
}

- (void)authenticateDevice {
    _nanoleafState = NANOLEAF_STATE_CONNECTING;
    self.nanoleafState = _nanoleafState;
    [self.delegate changeState:_nanoleafState withMode:self showMessage:@"Loading effects..."];

    [self fetchDeviceInfoWithCompletion:^(NSDictionary *info, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _nanoleafState = NANOLEAF_STATE_NOT_CONNECTED;
                self.nanoleafState = _nanoleafState;
                [self.delegate changeState:_nanoleafState withMode:self
                               showMessage:[NSString stringWithFormat:@"Connection failed: %@", error.localizedDescription]];
            });
            return;
        }

        NSString *name = info[@"name"] ?: _deviceName ?: @"Nanoleaf";

        [self fetchEffectsWithCompletion:^(NSArray<NSString *> *effects, NSError *err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _deviceName = name;
                [_cachedEffects removeAllObjects];
                [_cachedEffects addObjectsFromArray:effects ?: @[]];
                _nanoleafState = NANOLEAF_STATE_CONNECTED;
                self.nanoleafState = _nanoleafState;

                // Update saved name
                if (_deviceIp && _authToken) {
                    [self saveDeviceWithIp:_deviceIp token:_authToken name:name];
                }

                [self.delegate changeState:_nanoleafState withMode:self showMessage:nil];
                NSLog(@" ---> Nanoleaf connected: %@, %lu effects", name, (unsigned long)effects.count);
            });
        }];
    }];
}

#pragma mark - API Client

+ (NSString *)formatHostForURL:(NSString *)host {
    if (!host) return @"";
    // If it's a .local hostname or plain IPv4, pass through
    if (![host containsString:@":"] || [host containsString:@".local"]) {
        return host;
    }
    // IPv6 address - wrap in brackets, URL-encode % as %25 for scope ID
    NSString *encoded = [host stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
    return [NSString stringWithFormat:@"[%@]", encoded];
}

- (NSString *)baseURL {
    if (!_deviceIp || !_authToken) return nil;
    NSString *host = [TTModeNanoleaf formatHostForURL:_deviceIp];
    return [NSString stringWithFormat:@"http://%@:%ld/api/v1/%@", host, (long)kNanoleafApiPort, _authToken];
}

- (void)fetchDeviceInfoWithCompletion:(void (^)(NSDictionary *info, NSError *error))completion {
    NSString *base = [self baseURL];
    if (!base) {
        if (completion) completion(nil, [NSError errorWithDomain:@"TTNanoleaf" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Not connected"}]);
        return;
    }

    NSURL *url = [NSURL URLWithString:base];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) completion(nil, error);
            return;
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            if (completion) completion(nil, [NSError errorWithDomain:@"TTNanoleaf" code:httpResponse.statusCode userInfo:@{NSLocalizedDescriptionKey: @"Invalid response"}]);
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (completion) completion(json, nil);
    }];
    [task resume];
}

- (void)fetchEffectsWithCompletion:(void (^)(NSArray<NSString *> *effects, NSError *error))completion {
    NSString *base = [self baseURL];
    if (!base) {
        if (completion) completion(nil, [NSError errorWithDomain:@"TTNanoleaf" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Not connected"}]);
        return;
    }

    NSString *urlStr = [NSString stringWithFormat:@"%@/effects/effectsList", base];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) completion(nil, error);
            return;
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            if (completion) completion(nil, [NSError errorWithDomain:@"TTNanoleaf" code:httpResponse.statusCode userInfo:@{NSLocalizedDescriptionKey: @"Invalid response"}]);
            return;
        }
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (completion) completion(json, nil);
    }];
    [task resume];
}

- (void)setPower:(BOOL)on completion:(void (^)(NSError *error))completion {
    NSString *base = [self baseURL];
    if (!base) {
        if (completion) completion([NSError errorWithDomain:@"TTNanoleaf" code:-1 userInfo:nil]);
        return;
    }

    NSString *urlStr = [NSString stringWithFormat:@"%@/state", base];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"on": @{@"value": @(on)}} options:0 error:nil];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) completion(error);
            return;
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 204 && httpResponse.statusCode != 200) {
            if (completion) completion([NSError errorWithDomain:@"TTNanoleaf" code:httpResponse.statusCode userInfo:nil]);
            return;
        }
        if (completion) completion(nil);
    }];
    [task resume];
}

- (void)setBrightness:(NSInteger)value duration:(NSInteger)duration completion:(void (^)(NSError *error))completion {
    NSString *base = [self baseURL];
    if (!base) {
        if (completion) completion([NSError errorWithDomain:@"TTNanoleaf" code:-1 userInfo:nil]);
        return;
    }

    NSString *urlStr = [NSString stringWithFormat:@"%@/state", base];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSMutableDictionary *briDict = [NSMutableDictionary dictionary];
    briDict[@"value"] = @(MAX(0, MIN(100, value)));
    if (duration > 0) {
        briDict[@"duration"] = @(duration);
    }
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"brightness": briDict} options:0 error:nil];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) completion(error);
            return;
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 204 && httpResponse.statusCode != 200) {
            if (completion) completion([NSError errorWithDomain:@"TTNanoleaf" code:httpResponse.statusCode userInfo:nil]);
            return;
        }
        if (completion) completion(nil);
    }];
    [task resume];
}

- (void)setEffect:(NSString *)effectName completion:(void (^)(NSError *error))completion {
    NSString *base = [self baseURL];
    if (!base) {
        if (completion) completion([NSError errorWithDomain:@"TTNanoleaf" code:-1 userInfo:nil]);
        return;
    }

    NSString *urlStr = [NSString stringWithFormat:@"%@/effects", base];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"select": effectName} options:0 error:nil];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) completion(error);
            return;
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 204 && httpResponse.statusCode != 200) {
            if (completion) completion([NSError errorWithDomain:@"TTNanoleaf" code:httpResponse.statusCode userInfo:nil]);
            return;
        }
        if (completion) completion(nil);
    }];
    [task resume];
}

#pragma mark - Device Persistence

- (void)saveDeviceWithIp:(NSString *)ip token:(NSString *)token name:(NSString *)name {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedDevices = [([prefs arrayForKey:kNanoleafSavedDevices] ?: @[]) mutableCopy];

    // Remove existing entry for this IP
    NSMutableArray *filtered = [NSMutableArray array];
    for (NSDictionary *d in savedDevices) {
        if (![d[@"ip"] isEqualToString:ip]) {
            [filtered addObject:d];
        }
    }

    NSDictionary *device = @{
        @"ip": ip,
        @"token": token,
        @"name": name ?: _deviceName ?: @"Nanoleaf"
    };
    [filtered insertObject:device atIndex:0];

    [prefs setObject:filtered forKey:kNanoleafSavedDevices];
    [prefs synchronize];
}

@end
