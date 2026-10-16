#import "TTHueBridge.h"
#import <Security/Security.h>
#import <arpa/inet.h>

static NSError *HueError(NSInteger code, NSString *text) {
    return [NSError errorWithDomain:SDK_ERROR_DOMAIN code:code userInfo:@{NSLocalizedDescriptionKey: text}];
}
static void HuePost(NSString *name, NSDictionary *info) {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:info];
}
@implementation TTHueLightState
- (NSDictionary *)JSON {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    NSDictionary *map = @{@"on": @"on", @"brightness": @"bri", @"saturation": @"sat", @"hue": @"hue", @"transitionTime": @"transitiontime", @"brightnessIncrement": @"bri_inc", @"hueIncrement": @"hue_inc"};
    for (NSString *key in map) { id value = [self valueForKey:key]; if (value) json[map[key]] = value; }
    if (json[@"bri"]) json[@"bri"] = @(MAX(1, MIN(254, [json[@"bri"] integerValue])));
    if (json[@"sat"]) json[@"sat"] = @(MAX(0, MIN(254, [json[@"sat"] integerValue])));
    if (self.x && self.y) { json[@"xy"] = @[self.x, self.y]; [json removeObjectForKey:@"hue"]; [json removeObjectForKey:@"sat"]; }
    if (self.effect == EFFECT_COLORLOOP) json[@"effect"] = @"colorloop";
    if (self.alert) json[@"alert"] = @"select";
    return json;
}
@end
@implementation TTHueLight @end
@implementation TTHueGroup @end
@implementation TTHueScene @end
@implementation TTHueBridgeConfiguration @end
@implementation TTHueBridgeResources
- (instancetype)init { if ((self = [super init])) { _lights = @{}; _groups = @{}; _scenes = @{}; _bridgeConfiguration = [TTHueBridgeConfiguration new]; } return self; }
@end
@implementation TTHueResourcesReader
+ (TTHueBridgeResources *)readBridgeResourcesCache { static id cache; static dispatch_once_t once; dispatch_once(&once, ^{ cache = [TTHueBridgeResources new]; }); return cache; }
@end
@implementation TTHueNotifications
+ (instancetype)defaultManager { static id manager; static dispatch_once_t once; dispatch_once(&once, ^{ manager = [self new]; }); return manager; }
- (void)registerObject:(id)object withSelector:(SEL)selector forNotification:(NSString *)name {
    [[NSNotificationCenter defaultCenter] removeObserver:object name:name object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:object selector:selector name:name object:nil];
}
- (void)deregisterObjectForAllNotifications:(id)object { [[NSNotificationCenter defaultCenter] removeObserver:object]; }
@end
@interface TTHueClient ()
@property (nonatomic, readwrite) BOOL localConnected;
@property NSString *address, *bridgeID, *username;
@property NSURLSession *session;
@property NSTimer *heartbeat, *pairing;
@property NSDate *pairingDeadline;
@property BOOL pairingInFlight, refreshing;
@property NSUInteger generation;
@property NSMutableArray *requests;
@property BOOL sending;
@end
@implementation TTHueClient
+ (instancetype)sharedClient { static id client; static dispatch_once_t once; dispatch_once(&once, ^{ client = [self new]; }); return client; }
- (instancetype)init {
    if ((self = [super init])) {
        _requests = [NSMutableArray array];
        NSURLSessionConfiguration *config = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        config.timeoutIntervalForRequest = 8; config.timeoutIntervalForResource = 12;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return self;
}
- (NSDictionary *)keychainQuery {
    return @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrService: @"com.turntouch.hue", (__bridge id)kSecAttrAccount: self.bridgeID ?: @""};
}
- (void)startUpSDK {
    NSUserDefaults *prefs = NSUserDefaults.standardUserDefaults;
    NSString *address = [prefs stringForKey:@"TT:Hue:address"], *bridge = [prefs stringForKey:@"TT:Hue:bridgeID"];
    if (address.length && bridge.length) [self setBridgeToUseWithId:bridge ipAddress:address];
}
- (void)enableLogging:(BOOL)enabled { /* Credentials are never logged. */ }
- (void)setBridgeToUseWithId:(NSString *)bridgeId ipAddress:(NSString *)address {
    [self disableLocalConnection]; [self.pairing invalidate]; self.pairing = nil; self.generation++;
    self.address = address; self.bridgeID = bridgeId; self.username = nil; self.localConnected = NO;
    TTHueBridgeResources *cache = TTHueResourcesReader.readBridgeResourcesCache;
    cache.lights = @{}; cache.groups = @{}; cache.scenes = @{};
    cache.bridgeConfiguration.ipaddress = address; cache.bridgeConfiguration.bridgeId = bridgeId;
    NSMutableDictionary *query = [[self keychainQuery] mutableCopy]; query[(__bridge id)kSecReturnData] = @YES;
    CFTypeRef value = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, &value) == errSecSuccess) self.username = [[NSString alloc] initWithData:CFBridgingRelease(value) encoding:NSUTF8StringEncoding];
    [NSUserDefaults.standardUserDefaults setObject:address forKey:@"TT:Hue:address"];
    [NSUserDefaults.standardUserDefaults setObject:bridgeId forKey:@"TT:Hue:bridgeID"];
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completion {
    completion(nil); // Never forward the bridge credential to another endpoint.
}
- (void)request:(NSString *)path method:(NSString *)method body:(NSDictionary *)body authenticated:(BOOL)authenticated completion:(void (^)(id, NSError *))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.address.length || (authenticated && !self.username.length)) { completion(nil, HueError(1, @"Pair this Mac with your Hue bridge first.")); return; }
        NSURLComponents *url = [NSURLComponents new]; url.scheme = @"http";
        // address may include a port for bridge emulators; discovery supplies a local IPv4 or DNS host.
        NSURLComponents *base = [NSURLComponents componentsWithString:[@"http://" stringByAppendingString:self.address]];
        url.host = base.host; url.port = base.port;
        url.path = authenticated ? [NSString stringWithFormat:@"/api/%@%@", self.username, path] : @"/api";
        if (!url.URL) { completion(nil, HueError(1, @"Invalid Hue bridge address.")); return; }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url.URL];
        request.HTTPMethod = method;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        if (body) request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
        [self.requests addObject:@{@"request": request, @"completion": [completion copy], @"generation": @(self.generation)}];
        [self sendNext];
    });
}
- (void)sendNext {
    if (self.sending || !self.requests.count) return;
    self.sending = YES;
    NSDictionary *entry = self.requests.firstObject; [self.requests removeObjectAtIndex:0];
    void (^completion)(id, NSError *) = entry[@"completion"];
    if ([entry[@"generation"] unsignedIntegerValue] != self.generation) {
        self.sending = NO; completion(nil, HueError(1, @"Hue bridge changed.")); [self sendNext]; return;
    }
    [[self.session dataTaskWithRequest:entry[@"request"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        id result = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
        NSInteger status = [(NSHTTPURLResponse *)response statusCode];
        if (!error && (status < 200 || status >= 300 || !result)) error = HueError(status, @"The Hue bridge did not return a successful response.");
        if ([result isKindOfClass:NSArray.class]) for (id item in result) {
            if ([item isKindOfClass:NSDictionary.class] && [item[@"error"] isKindOfClass:NSDictionary.class]) { error = HueError([item[@"error"][@"type"] integerValue], item[@"error"][@"description"] ?: @"Hue action failed."); break; }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *failure = [entry[@"generation"] unsignedIntegerValue] == self.generation ? error : HueError(1, @"Hue bridge changed.");
            completion(result, failure);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 120 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ self.sending = NO; [self sendNext]; });
        });
    }] resume];
}
- (void)refresh:(void (^)(NSError *))completion {
    if (self.refreshing) { if (completion) completion(nil); return; }
    self.refreshing = YES;
    [self request:@"" method:@"GET" body:nil authenticated:YES completion:^(id json, NSError *error) {
        self.refreshing = NO;
        if (!error && (![json isKindOfClass:NSDictionary.class] || ![json[@"lights"] isKindOfClass:NSDictionary.class])) error = HueError(1, @"Hue returned an invalid resource catalog.");
        self.localConnected = error == nil;
        if (!error) {
            TTHueBridgeResources *cache = TTHueResourcesReader.readBridgeResourcesCache;
            NSMutableDictionary *lights = [NSMutableDictionary dictionary], *groups = [NSMutableDictionary dictionary], *scenes = [NSMutableDictionary dictionary];
            for (NSString *key in json[@"lights"]) {
                NSDictionary *item = json[@"lights"][key]; TTHueLight *light = [TTHueLight new];
                light.identifier = key; light.name = item[@"name"] ?: key; light.modelNumber = item[@"modelid"] ?: @"";
                light.stateKeys = [NSSet setWithArray:[item[@"state"] allKeys] ?: @[]]; lights[key] = light;
            }
            for (NSString *key in json[@"groups"]) {
                NSDictionary *item = json[@"groups"][key]; TTHueGroup *group = [TTHueGroup new];
                group.identifier = key; group.name = item[@"name"] ?: key; group.lightIdentifiers = item[@"lights"] ?: @[]; groups[key] = group;
            }
            for (NSString *key in json[@"scenes"]) {
                NSDictionary *item = json[@"scenes"][key]; TTHueScene *scene = [TTHueScene new];
                scene.identifier = key; scene.name = item[@"name"] ?: key; scene.lightIdentifiers = item[@"lights"] ?: @[]; scenes[key] = scene;
            }
            cache.lights = lights; cache.groups = groups; cache.scenes = scenes;
            HuePost(LOCAL_CONNECTION_NOTIFICATION, nil);
        } else HuePost(error.code == 1 ? NO_LOCAL_AUTHENTICATION_NOTIFICATION : NO_LOCAL_CONNECTION_NOTIFICATION, nil);
        if (completion) completion(error);
    }];
}
- (void)enableLocalConnection {
    [self.heartbeat invalidate];
    [self refresh:nil];
    __weak typeof(self) weakSelf = self;
    self.heartbeat = [NSTimer scheduledTimerWithTimeInterval:10 repeats:YES block:^(NSTimer *timer) { [weakSelf refresh:nil]; }];
}
- (void)disableLocalConnection { [self.heartbeat invalidate]; self.heartbeat = nil; }
- (void)startPushlinkAuthentication {
    if (self.pairing) return;
    if (!self.address.length) { HuePost(PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION, nil); return; }
    if (self.username.length) { [self refresh:^(NSError *error) { if (!error) HuePost(PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION, nil); else { self.username = nil; [self startPushlinkAuthentication]; } }]; return; }
    self.pairingDeadline = [NSDate dateWithTimeIntervalSinceNow:30];
    __weak typeof(self) weakSelf = self;
    self.pairing = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) { [weakSelf pair]; }];
    [self pair];
}
- (void)pair {
    if (self.pairingInFlight) return;
    if (self.pairingDeadline.timeIntervalSinceNow <= 0) { [self.pairing invalidate]; self.pairing = nil; HuePost(PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION, nil); return; }
    self.pairingInFlight = YES;
    [self request:@"" method:@"POST" body:@{@"devicetype": @"TurnTouch#Mac"} authenticated:NO completion:^(id result, NSError *error) {
        self.pairingInFlight = NO;
        NSString *username = [result isKindOfClass:NSArray.class] && [result count] ? result[0][@"success"][@"username"] : nil;
        if (!error && username.length) {
            NSData *data = [username dataUsingEncoding:NSUTF8StringEncoding]; NSDictionary *query = [self keychainQuery];
            OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)@{(__bridge id)kSecValueData: data});
            if (status == errSecItemNotFound) { NSMutableDictionary *item = [query mutableCopy]; item[(__bridge id)kSecValueData] = data; item[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly; status = SecItemAdd((__bridge CFDictionaryRef)item, NULL); }
            [self.pairing invalidate]; self.pairing = nil;
            if (status != errSecSuccess) { HuePost(PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION, nil); return; }
            self.username = username;
            HuePost(PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION, nil);
        } else if (error.code == 101) {
            HuePost(PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION, @{@"progressPercentage": @(100 * (1 - self.pairingDeadline.timeIntervalSinceNow / 30))});
        } else { [self.pairing invalidate]; self.pairing = nil; HuePost(PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION, nil); }
    }];
}
@end
@interface TTHueBridgeSearch ()
@property NSNetServiceBrowser *browser;
@property NSMutableArray *services;
@property NSMutableDictionary *found;
@property (copy) void (^completion)(NSDictionary *);
@end
@implementation TTHueBridgeSearch
- (instancetype)initWithUpnpSearch:(BOOL)upnp andPortalSearch:(BOOL)portal andIpAddressSearch:(BOOL)ip { return [super init]; }
- (void)startSearchWithCompletionHandler:(void (^)(NSDictionary *))completion {
    self.completion = completion; self.services = [NSMutableArray array]; self.found = [NSMutableDictionary dictionary];
    self.browser = [NSNetServiceBrowser new]; self.browser.delegate = self;
    [self.browser searchForServicesOfType:@"_hue._tcp." inDomain:@"local."];
    // Official discovery is a fallback for bridges whose mDNS is blocked on the LAN.
    [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:@"https://discovery.meethue.com/"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        id items = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
        if (![items isKindOfClass:NSArray.class]) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSDictionary *item in items) if ([item[@"id"] isKindOfClass:NSString.class] && [item[@"internalipaddress"] isKindOfClass:NSString.class]) self.found[item[@"id"]] = item[@"internalipaddress"];
        });
    }] resume];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.browser stop]; for (NSNetService *service in self.services) [service stop];
        if (self.completion) self.completion([self.found copy]); self.completion = nil;
    });
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    [self.services addObject:service]; service.delegate = self; [service resolveWithTimeout:3];
}
- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSDictionary *txt = [NSNetService dictionaryFromTXTRecordData:service.TXTRecordData ?: NSData.data];
    NSString *bridge = [[NSString alloc] initWithData:txt[@"bridgeid"] ?: NSData.data encoding:NSUTF8StringEncoding];
    for (NSData *data in service.addresses) {
        const struct sockaddr *sa = data.bytes;
        if (sa->sa_family != AF_INET) continue;
        char buffer[INET_ADDRSTRLEN]; inet_ntop(AF_INET, &((const struct sockaddr_in *)sa)->sin_addr, buffer, sizeof(buffer));
        NSString *host = [NSString stringWithUTF8String:buffer];
        // mDNS advertises HTTPS on 443; this v1 client uses the bridge's HTTP endpoint on 80.
        self.found[bridge.length ? bridge : service.name] = (service.port == 80 || service.port == 443) ? host : [NSString stringWithFormat:@"%@:%ld", host, (long)service.port]; break;
    }
}
- (void)dealloc { [self.browser stop]; }
@end
@implementation TTHueCommands
- (void)send:(NSString *)path body:(NSDictionary *)body completion:(void (^)(NSArray *))completion {
    [TTHueClient.sharedClient request:path method:@"PUT" body:body authenticated:YES completion:^(id result, NSError *error) { if (completion) completion(error ? @[error] : @[]); }];
}
- (void)activateSceneWithIdentifier:(NSString *)scene onGroup:(NSString *)group completionHandler:(void (^)(NSArray *))completion {
    if (!scene.length) { if (completion) completion(@[HueError(1, @"Choose a Hue scene first.")]); return; }
    [self send:[NSString stringWithFormat:@"/groups/%@/action", group ?: @"0"] body:@{@"scene": scene} completion:completion];
}
- (void)updateLightStateForId:(NSString *)identifier withLightState:(TTHueLightState *)state completionHandler:(void (^)(NSArray *))completion {
    NSMutableDictionary *body = [state.JSON mutableCopy];
    TTHueLight *light = TTHueResourcesReader.readBridgeResourcesCache.lights[identifier];
    if (light.stateKeys.count) for (NSString *key in @[@"bri", @"hue", @"sat", @"xy", @"effect"]) if (![light.stateKeys containsObject:key]) [body removeObjectForKey:key];
    [self send:[NSString stringWithFormat:@"/lights/%@/state", identifier] body:body completion:completion];
}
- (void)setLightStateForGroupWithId:(NSString *)identifier lightState:(TTHueLightState *)state completionHandler:(void (^)(NSArray *))completion {
    [self send:[NSString stringWithFormat:@"/groups/%@/action", identifier ?: @"0"] body:state.JSON completion:completion];
}
- (void)getAllScenesWithCompletionHandler:(void (^)(NSDictionary *, NSArray *))completion {
    [TTHueClient.sharedClient refresh:^(NSError *error) { completion(TTHueResourcesReader.readBridgeResourcesCache.scenes, error ? @[error] : @[]); }];
}
- (void)saveSceneWithCurrentLightStates:(TTHueScene *)scene completionHandler:(void (^)(NSArray *))completion {
    [self send:[NSString stringWithFormat:@"/scenes/%@", scene.identifier] body:@{@"name": scene.name, @"lights": scene.lightIdentifiers ?: @[], @"recycle": @NO} completion:completion];
}
- (void)saveLightState:(TTHueLightState *)state forLightIdentifier:(NSString *)light inSceneWithIdentifier:(NSString *)scene completionHandler:(void (^)(NSArray *))completion {
    NSMutableDictionary *body = [state.JSON mutableCopy]; [body removeObjectForKey:@"alert"]; [body removeObjectForKey:@"bri_inc"]; [body removeObjectForKey:@"hue_inc"];
    [self send:[NSString stringWithFormat:@"/scenes/%@/lightstates/%@", scene, light] body:body completion:completion];
}
@end
@implementation TTHueColor
+ (CGPoint)calculateXY:(NSColor *)color forModel:(NSString *)model {
    NSColor *rgb = [color colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
    double r = rgb.redComponent, g = rgb.greenComponent, b = rgb.blueComponent;
    r = r > .04045 ? pow((r + .055)/1.055, 2.4) : r/12.92;
    g = g > .04045 ? pow((g + .055)/1.055, 2.4) : g/12.92;
    b = b > .04045 ? pow((b + .055)/1.055, 2.4) : b/12.92;
    double x = r*.664511 + g*.154324 + b*.162028;
    double y = r*.283881 + g*.668433 + b*.047685;
    double z = r*.000088 + g*.072310 + b*.986039;
    return x+y+z > 0 ? CGPointMake(x/(x+y+z), y/(x+y+z)) : CGPointMake(0, 0);
}
@end
