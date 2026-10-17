#import "TTHomeAssistantClient.h"
#import <Security/Security.h>

NSString * const TTHAConnectionChanged = @"TTHAConnectionChanged";
NSString * const TTHAKeychainInteractionChanged = @"TTHAKeychainInteractionChanged";
static NSUInteger pendingKeychainInteractions;
static void HAKeychainInteraction(BOOL active) {
    if (active) pendingKeychainInteractions++;
    else if (pendingKeychainInteractions) pendingKeychainInteractions--;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTHAKeychainInteractionChanged object:nil];
}
NSString * const TTHAClientID = @"https://turntouch.com";
NSString * const TTHARedirectURI = @"https://turntouch.com/home-assistant/callback";
static NSString * const TTHAKeychainService = @"com.turntouch.homeassistant";
static NSError *HAError(NSString *message) {
    return [NSError errorWithDomain:@"TurnTouch.HomeAssistant" code:1 userInfo:@{NSLocalizedDescriptionKey: message}];
}
@interface TTHomeAssistantClient ()
@property (nonatomic, readwrite) NSString *serverURL;
@property (nonatomic, readwrite) NSArray<NSDictionary *> *entities;
@property (nonatomic, readwrite) NSDictionary *services;
@property (nonatomic, readwrite) NSString *lastError;
@property (nonatomic) NSDictionary *credentials;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSMutableArray *tokenWaiters;
@property (nonatomic) NSUInteger generation;
@property (nonatomic, readwrite) BOOL restoringConnection;
@property (nonatomic) NSMutableArray *restoreWaiters;
@end
@implementation TTHomeAssistantClient
+ (BOOL)isAwaitingKeychainAuthorization { return pendingKeychainInteractions > 0; }
+ (instancetype)sharedClient {
    static id client; static dispatch_once_t once;
    dispatch_once(&once, ^{ client = [[self alloc] init]; });
    return client;
}
- (instancetype)init {
    if ((self = [super init])) {
        _serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"TT:HomeAssistant:URL"] ?: @"";
        _entities = @[]; _services = @{}; _lastError = @"";
        _tokenWaiters = [NSMutableArray array];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        config.timeoutIntervalForRequest = 15;
        config.timeoutIntervalForResource = 25;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        _restoreWaiters = [NSMutableArray array];
        if (_serverURL.length) [self restoreConnectionToURL:_serverURL completion:^(id result, NSError *error) {}];
    }
    return self;
}
- (NSDictionary *)keychainQuery:(NSString *)url {
    return @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
             (__bridge id)kSecAttrService: TTHAKeychainService,
             (__bridge id)kSecAttrAccount: url};
}
- (BOOL)connected { return self.serverURL.length && [self.credentials[@"access_token"] length]; }
+ (NSString *)normalizedURL:(NSString *)input {
    NSString *value = [input stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (![value containsString:@"://"]) value = [@"http://" stringByAppendingString:value];
    NSURLComponents *parts = [NSURLComponents componentsWithString:value];
    if (!parts.host.length || ![@[@"http", @"https"] containsObject:parts.scheme.lowercaseString] ||
        parts.user || parts.password || parts.query || parts.fragment || (parts.port && (parts.port.integerValue < 1 || parts.port.integerValue > 65535))) return nil;
    parts.scheme = parts.scheme.lowercaseString;
    parts.host = parts.host.lowercaseString;
    while ([parts.path hasSuffix:@"/"]) parts.path = [parts.path substringToIndex:parts.path.length - 1];
    return parts.URL.absoluteString;
}
// Never follow redirects with credentials or replay a physical action at a different endpoint.
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    completionHandler(nil);
}
- (void)requestURL:(NSString *)url method:(NSString *)method token:(NSString *)token body:(NSData *)body contentType:(NSString *)type completion:(TTHACompletion)completion {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = method; request.HTTPBody = body;
    if (token.length) [request setValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    [request setValue:type forHTTPHeaderField:@"Content-Type"];
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger status = [(NSHTTPURLResponse *)response statusCode];
        id object = data.length ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:nil] : @{};
        if (!error && (status < 200 || status >= 300)) {
            NSString *message = status == 401 ? TTText(@"Your Home Assistant session expired or the token is invalid. Connect again.") :
                status == 403 ? TTText(@"This Home Assistant user does not have permission for that action.") :
                [NSString stringWithFormat:TTText(@"Home Assistant returned HTTP %ld. Check the action and its required fields."), (long)status];
            error = HAError(message);
        }
        if (!error && !object) error = HAError(TTText(@"The server did not return Home Assistant JSON. Check its address."));
        dispatch_async(dispatch_get_main_queue(), ^{ completion(object, error); });
    }] resume];
}
- (void)tokenRequest:(NSDictionary *)fields url:(NSString *)url completion:(TTHACompletion)completion {
    NSMutableArray *pairs = [NSMutableArray array];
    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"];
    for (NSString *key in fields) [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [fields[key] stringByAddingPercentEncodingWithAllowedCharacters:allowed]]];
    [self requestURL:[url stringByAppendingString:@"/auth/token"] method:@"POST" token:nil body:[[pairs componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding] contentType:@"application/x-www-form-urlencoded" completion:completion];
}
- (NSError *)saveCredentials:(NSDictionary *)credentials url:(NSString *)url {
    NSDictionary *query = [self keychainQuery:url];
    NSData *data = [NSJSONSerialization dataWithJSONObject:credentials options:0 error:nil];
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)@{(__bridge id)kSecValueData: data});
    if (status == errSecItemNotFound) {
        NSMutableDictionary *item = [query mutableCopy];
        item[(__bridge id)kSecValueData] = data;
        item[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
        status = SecItemAdd((__bridge CFDictionaryRef)item, NULL);
    }
    if (status != errSecSuccess) return HAError(TTText(@"Could not save the Home Assistant credentials in Keychain. Please unlock your keychain and try again."));
    if (![self.serverURL isEqual:url]) { self.entities = @[]; self.services = @{}; }
    self.credentials = credentials; self.serverURL = url;
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"TT:HomeAssistant:URL"];
    return nil;
}
- (void)connectToURL:(NSString *)url token:(NSString *)token completion:(TTHACompletion)completion {
    NSString *normalized = [self.class normalizedURL:url];
    token = [token stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!normalized || !token.length) { completion(nil, HAError(TTText(@"Enter a Home Assistant address and access token."))); return; }
    NSUInteger generation = ++self.generation;
    [self requestURL:[normalized stringByAppendingString:@"/api/"] method:@"GET" token:token body:nil contentType:@"application/json" completion:^(id result, NSError *error) {
        if (generation != self.generation) { completion(nil, HAError(TTText(@"Connection cancelled."))); return; }
        if (!error) error = [self saveCredentials:@{@"access_token": token} url:normalized];
        if (error) { completion(nil, error); return; }
        [self refreshCatalog:completion];
    }];
}
- (void)exchangeCode:(NSString *)code serverURL:(NSString *)url completion:(TTHACompletion)completion {
    NSString *normalized = [self.class normalizedURL:url];
    if (!normalized || !code.length) { completion(nil, HAError(TTText(@"Invalid sign-in response."))); return; }
    NSUInteger generation = ++self.generation;
    [self tokenRequest:@{@"grant_type": @"authorization_code", @"code": code, @"client_id": TTHAClientID} url:normalized completion:^(id result, NSError *error) {
        if (generation != self.generation) { completion(nil, HAError(TTText(@"Connection cancelled."))); return; }
        if (!error && (![result isKindOfClass:NSDictionary.class] || ![result[@"access_token"] isKindOfClass:NSString.class] || ![result[@"refresh_token"] isKindOfClass:NSString.class])) error = HAError(TTText(@"Home Assistant returned an invalid sign-in response."));
        if (!error) {
            NSMutableDictionary *credentials = [result mutableCopy];
            credentials[@"expires_at"] = @([NSDate date].timeIntervalSince1970 + [result[@"expires_in"] doubleValue] - 60);
            error = [self saveCredentials:credentials url:normalized];
        }
        if (error) { completion(nil, error); return; }
        [self refreshCatalog:completion];
    }];
}
- (void)withToken:(TTHACompletion)completion {
    if (self.restoringConnection) {
        __weak typeof(self) weakSelf = self;
        [self.restoreWaiters addObject:[^(id result, NSError *error) {
            [weakSelf withToken:completion];
        } copy]];
        return;
    }
    if (!self.connected) { completion(nil, HAError(TTText(@"Connect to Home Assistant first."))); return; }
    if (!self.credentials[@"refresh_token"] || [self.credentials[@"expires_at"] doubleValue] > NSDate.date.timeIntervalSince1970) { completion(self.credentials[@"access_token"], nil); return; }
    [self.tokenWaiters addObject:[completion copy]];
    if (self.tokenWaiters.count > 1) return;
    NSUInteger generation = self.generation;
    [self tokenRequest:@{@"grant_type": @"refresh_token", @"refresh_token": self.credentials[@"refresh_token"], @"client_id": TTHAClientID} url:self.serverURL completion:^(id result, NSError *error) {
        if (generation != self.generation) error = HAError(TTText(@"Connection changed. Please try again."));
        if (!error && (![result isKindOfClass:NSDictionary.class] || ![result[@"access_token"] isKindOfClass:NSString.class])) error = HAError(TTText(@"Please sign in to Home Assistant again."));
        if (!error) {
            NSMutableDictionary *credentials = [self.credentials mutableCopy];
            credentials[@"access_token"] = result[@"access_token"];
            credentials[@"expires_at"] = @(NSDate.date.timeIntervalSince1970 + [result[@"expires_in"] doubleValue] - 60);
            error = [self saveCredentials:credentials url:self.serverURL];
        }
        NSArray *waiters = [self.tokenWaiters copy]; [self.tokenWaiters removeAllObjects];
        for (TTHACompletion waiter in waiters) waiter(error ? nil : self.credentials[@"access_token"], error);
    }];
}
- (NSDictionary *)readCredentialsForURL:(NSString *)url {
    NSMutableDictionary *query = [[self keychainQuery:url] mutableCopy];
    query[(__bridge id)kSecReturnData] = @YES;
    CFTypeRef result = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, &result) != errSecSuccess) return nil;
    NSData *data = CFBridgingRelease(result);
    NSDictionary *credentials = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [credentials isKindOfClass:NSDictionary.class] && [credentials[@"access_token"] isKindOfClass:NSString.class] ? credentials : nil;
}
- (void)restoreConnectionToURL:(NSString *)url completion:(TTHACompletion)completion {
    NSString *normalized = [self.class normalizedURL:url];
    if (!normalized || self.restoringConnection) { completion(nil, nil); return; }
    self.restoringConnection = YES;
    HAKeychainInteraction(YES);
    NSUInteger generation = ++self.generation;
    [self.restoreWaiters addObject:[completion copy]];
    // A Keychain authorization alert can remain open indefinitely. Never wait
    // for it on AppKit's main thread, including during singleton construction.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSDictionary *credentials = [self readCredentialsForURL:normalized];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation == self.generation && credentials) {
                self.credentials = credentials;
                if (![self.serverURL isEqual:normalized]) { self.entities = @[]; self.services = @{}; }
                self.serverURL = normalized;
                [NSUserDefaults.standardUserDefaults setObject:normalized forKey:@"TT:HomeAssistant:URL"];
            }
            self.restoringConnection = NO;
            HAKeychainInteraction(NO);
            NSArray *waiters = [self.restoreWaiters copy]; [self.restoreWaiters removeAllObjects];
            for (TTHACompletion waiter in waiters) waiter(self.connected ? @YES : nil, nil);
            [[NSNotificationCenter defaultCenter] postNotificationName:TTHAConnectionChanged object:self];
        });
    });
}
- (void)refreshCatalog:(TTHACompletion)completion {
    NSUInteger generation = self.generation;
    [self withToken:^(NSString *token, NSError *error) {
        if (error) { completion(nil, error); return; }
        NSString *url = self.serverURL;
        [self requestURL:[url stringByAppendingString:@"/api/states"] method:@"GET" token:token body:nil contentType:@"application/json" completion:^(id states, NSError *error) {
            if (generation != self.generation) { completion(nil, HAError(TTText(@"Connection changed."))); return; }
            if (error || ![states isKindOfClass:NSArray.class]) { completion(nil, error ?: HAError(TTText(@"Could not read entities."))); return; }
            [self requestURL:[url stringByAppendingString:@"/api/services"] method:@"GET" token:token body:nil contentType:@"application/json" completion:^(id groups, NSError *error) {
                if (generation != self.generation) { completion(nil, HAError(TTText(@"Connection changed."))); return; }
                if (error || ![groups isKindOfClass:NSArray.class]) { completion(nil, error ?: HAError(TTText(@"Could not read actions."))); return; }
                NSMutableDictionary *services = [NSMutableDictionary dictionary];
                for (NSDictionary *group in groups) if ([group[@"domain"] isKindOfClass:NSString.class] && [group[@"services"] isKindOfClass:NSDictionary.class]) services[group[@"domain"]] = group[@"services"];
                self.services = services;
                self.entities = [states sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
                    return [(a[@"attributes"][@"friendly_name"] ?: a[@"entity_id"]) localizedCaseInsensitiveCompare:(b[@"attributes"][@"friendly_name"] ?: b[@"entity_id"])];
                }];
                self.lastError = @"";
                [[NSNotificationCenter defaultCenter] postNotificationName:TTHAConnectionChanged object:self];
                completion(self.entities, nil);
                [self enrichEntitiesWithToken:token generation:generation];
            }];
        }];
    }];
}
// Registry data supplies device and area search without requiring a custom HA integration.
- (void)enrichEntitiesWithToken:(NSString *)token generation:(NSUInteger)generation {
    if (@available(macOS 10.15, *)) {
        NSURLComponents *url = [NSURLComponents componentsWithString:[self.serverURL stringByAppendingString:@"/api/websocket"]];
        url.scheme = [url.scheme isEqualToString:@"https"] ? @"wss" : @"ws";
        NSURLSessionWebSocketTask *socket = [self.session webSocketTaskWithURL:url.URL];
        [socket resume];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 12 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ [socket cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil]; });
        [socket receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage *message, NSError *error) {
            if (error) { [socket cancel]; return; }
            NSData *auth = [NSJSONSerialization dataWithJSONObject:@{@"type": @"auth", @"access_token": token} options:0 error:nil];
            [socket sendMessage:[[NSURLSessionWebSocketMessage alloc] initWithString:[[NSString alloc] initWithData:auth encoding:NSUTF8StringEncoding]] completionHandler:^(NSError *error) {
                if (error) { [socket cancel]; return; }
                [socket receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage *message, NSError *error) {
                    NSDictionary *reply = [NSJSONSerialization JSONObjectWithData:[message.string dataUsingEncoding:NSUTF8StringEncoding] ?: NSData.data options:0 error:nil];
                    if (error || ![reply[@"type"] isEqual:@"auth_ok"]) { [socket cancel]; return; }
                    [self readRegistries:socket index:0 results:[NSMutableArray array] generation:generation];
                }];
            }];
        }];
    }
}
- (void)readRegistries:(NSURLSessionWebSocketTask *)socket index:(NSInteger)index results:(NSMutableArray *)results generation:(NSUInteger)generation API_AVAILABLE(macos(10.15)) {
    NSArray *commands = @[@"config/entity_registry/list", @"config/device_registry/list", @"config/area_registry/list"];
    if (index == commands.count) {
        [socket cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation != self.generation) return;
            NSMutableDictionary *registry = [NSMutableDictionary dictionary], *devices = [NSMutableDictionary dictionary], *areas = [NSMutableDictionary dictionary];
            for (NSDictionary *item in results[0]) if (item[@"entity_id"]) registry[item[@"entity_id"]] = item;
            for (NSDictionary *item in results[1]) if (item[@"id"]) devices[item[@"id"]] = item;
            for (NSDictionary *item in results[2]) if (item[@"area_id"]) areas[item[@"area_id"]] = item[@"name"] ?: @"";
            NSMutableArray *enriched = [NSMutableArray array];
            for (NSDictionary *entity in self.entities) {
                NSMutableDictionary *item = [entity mutableCopy];
                NSDictionary *entry = registry[entity[@"entity_id"]];
                NSDictionary *device = [entry[@"device_id"] isKindOfClass:NSString.class] ? devices[entry[@"device_id"]] : nil;
                id area = [entry[@"area_id"] isKindOfClass:NSString.class] ? entry[@"area_id"] : device[@"area_id"];
                item[@"tt_area"] = [area isKindOfClass:NSString.class] ? (areas[area] ?: @"") : @"";
                item[@"tt_device"] = [device[@"name_by_user"] isKindOfClass:NSString.class] ? device[@"name_by_user"] : ([device[@"name"] isKindOfClass:NSString.class] ? device[@"name"] : @"");
                [enriched addObject:item];
            }
            self.entities = enriched;
            [[NSNotificationCenter defaultCenter] postNotificationName:TTHAConnectionChanged object:self];
        });
        return;
    }
    NSString *command = [NSString stringWithFormat:@"{\"id\":%ld,\"type\":\"%@\"}", (long)index + 1, commands[index]];
    [socket sendMessage:[[NSURLSessionWebSocketMessage alloc] initWithString:command] completionHandler:^(NSError *error) {
        if (error) { [socket cancel]; return; }
        [socket receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage *message, NSError *error) {
            NSDictionary *reply = [NSJSONSerialization JSONObjectWithData:[message.string dataUsingEncoding:NSUTF8StringEncoding] ?: NSData.data options:0 error:nil];
            if (error || ![reply[@"success"] boolValue] || ![reply[@"result"] isKindOfClass:NSArray.class]) { [socket cancel]; return; }
            [results addObject:reply[@"result"]];
            [self readRegistries:socket index:index + 1 results:results generation:generation];
        }];
    }];
}
+ (NSArray<NSDictionary *> *)actionsForEntity:(NSDictionary *)entity services:(NSDictionary *)services {
    NSString *domain = [entity[@"entity_id"] componentsSeparatedByString:@"."].firstObject;
    NSDictionary *available = services[domain];
    NSMutableArray *actions = [NSMutableArray array];
    NSArray *preferred = @[@"toggle", @"turn_on", @"turn_off", @"press", @"trigger", @"open_cover", @"close_cover", @"stop_cover", @"media_play_pause", @"volume_up", @"volume_down"];
    NSMutableArray *keys = [NSMutableArray array];
    for (NSString *key in preferred) if (available[key]) [keys addObject:key];
    for (NSString *key in [[available allKeys] sortedArrayUsingSelector:@selector(compare:)]) if (![keys containsObject:key]) [keys addObject:key];
    for (NSString *key in keys) {
        NSDictionary *metadata = available[key];
        // Exclude domain maintenance services (reload, create, etc.) from entity actions.
        if (!metadata[@"target"] && !metadata[@"fields"][@"entity_id"] && ![preferred containsObject:key]) continue;
        NSString *name = metadata[@"name"];
        if (!name.length) name = [[key stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
        if ([domain isEqual:@"scene"] && [key isEqual:@"turn_on"]) name = TTText(@"Activate scene");
        if ([domain isEqual:@"script"] && [key isEqual:@"turn_on"]) name = TTText(@"Run script");
        if ([domain isEqual:@"automation"] && [key isEqual:@"trigger"]) name = TTText(@"Run automation (check conditions)");
        [actions addObject:@{@"id": [NSString stringWithFormat:@"%@.%@", domain, key], @"name": name, @"metadata": metadata}];
    }
    return actions;
}
+ (NSDictionary *)serviceBodyForEntity:(NSString *)entityID data:(NSString *)json error:(NSError **)error {
    if (entityID.length == 0 || [entityID componentsSeparatedByString:@"."].count != 2) { if (error) *error = HAError(TTText(@"Choose an entity first.")); return nil; }
    NSData *data = [(json.length ? json : @"{}") dataUsingEncoding:NSUTF8StringEncoding];
    id parsed = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![parsed isKindOfClass:NSDictionary.class]) { if (error) *error = HAError(TTText(@"Action data must be a JSON object, for example {\"brightness_pct\": 50}.")); return nil; }
    NSMutableDictionary *body = [parsed mutableCopy];
    for (NSString *key in @[@"entity_id", @"device_id", @"area_id", @"floor_id", @"label_id", @"target"]) {
        if (body[key]) { if (error) *error = HAError(TTText(@"Choose the target in the entity list, not in action data.")); return nil; }
    }
    body[@"entity_id"] = entityID;
    return body;
}
- (void)callAction:(NSString *)service entity:(NSString *)entityID data:(NSString *)json completion:(TTHACompletion)completion {
    NSArray *parts = [service componentsSeparatedByString:@"."];
    NSCharacterSet *invalid = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789_"] invertedSet];
    if (parts.count != 2 || ![parts[0] length] || ![parts[1] length] || [parts[0] rangeOfCharacterFromSet:invalid].location != NSNotFound || [parts[1] rangeOfCharacterFromSet:invalid].location != NSNotFound) { completion(nil, HAError(TTText(@"Choose a valid Home Assistant action."))); return; }
    NSError *error; NSMutableDictionary *body = [[self.class serviceBodyForEntity:entityID data:json error:&error] mutableCopy];
    if (!body) { completion(nil, error); return; }
    if ([service isEqual:@"automation.trigger"] && !body[@"skip_condition"]) body[@"skip_condition"] = @NO;
    NSData *data = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    [self withToken:^(NSString *token, NSError *error) {
        if (error) { completion(nil, error); return; }
        NSString *url = [NSString stringWithFormat:@"%@/api/services/%@/%@", self.serverURL, parts[0], parts[1]];
        NSDictionary *metadata = self.services[parts[0]][parts[1]];
        if ([metadata[@"response"][@"optional"] isEqual:@NO]) url = [url stringByAppendingString:@"?return_response"];
        [self requestURL:url method:@"POST" token:token body:data contentType:@"application/json" completion:^(id result, NSError *error) {
            self.lastError = error.localizedDescription ?: @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:TTHAConnectionChanged object:self];
            completion(result, error);
        }];
    }];
}
- (void)disconnect {
    self.generation++;
    SecItemDelete((__bridge CFDictionaryRef)[self keychainQuery:self.serverURL]);
    self.credentials = nil; self.entities = @[]; self.services = @{}; self.lastError = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:TTHAConnectionChanged object:self];
}
@end
