//
//  TTHueAPIClient.m
//  Turn Touch Mac
//
//  REST client for Hue CLIP API v2
//

#import "TTHueAPIClient.h"

NSString * const TTHueAPIClientErrorDomain = @"TTHueAPIClientError";

@interface TTHueAPIClient ()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) NSDate *lastRequestTime;
@end

static const NSTimeInterval kMinRequestInterval = 0.1; // 100ms between requests (max ~10/sec)

@implementation TTHueAPIClient

- (instancetype)initWithBridgeIP:(NSString *)bridgeIP applicationKey:(NSString *)applicationKey {
    self = [super init];
    if (self) {
        _bridgeIP = [bridgeIP copy];
        _applicationKey = [applicationKey copy];
        _serialQueue = dispatch_queue_create("com.turntouch.hueapiclient", DISPATCH_QUEUE_SERIAL);

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 30.0;
        config.timeoutIntervalForResource = 60.0;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)dealloc {
    [_session invalidateAndCancel];
}

#pragma mark - Base URL

- (NSURL *)baseURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/clip/v2/resource", self.bridgeIP]];
}

#pragma mark - HTTP Methods

- (void)getPath:(NSString *)path completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    NSURL *url = [[self baseURL] URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:self.applicationKey forHTTPHeaderField:@"hue-application-key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [self performRequest:request completion:completion];
}

- (void)putPath:(NSString *)path body:(NSDictionary *)body completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    NSURL *url = [[self baseURL] URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    [request setValue:self.applicationKey forHTTPHeaderField:@"hue-application-key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSError *jsonError;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
    if (jsonError) {
        if (completion) {
            completion(nil, jsonError);
        }
        return;
    }

    [self performRequest:request completion:completion];
}

- (void)postPath:(NSString *)path body:(NSDictionary *)body completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    NSURL *url = [[self baseURL] URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:self.applicationKey forHTTPHeaderField:@"hue-application-key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSError *jsonError;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
    if (jsonError) {
        completion(nil, jsonError);
        return;
    }

    [self performRequest:request completion:completion];
}

- (void)deletePath:(NSString *)path completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    NSURL *url = [[self baseURL] URLByAppendingPathComponent:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"DELETE";
    [request setValue:self.applicationKey forHTTPHeaderField:@"hue-application-key"];

    [self performRequest:request completion:completion];
}

- (void)performRequest:(NSURLRequest *)request completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    dispatch_async(self.serialQueue, ^{
        // Throttle requests to avoid overwhelming the Hue bridge
        if (self.lastRequestTime) {
            NSTimeInterval elapsed = -[self.lastRequestTime timeIntervalSinceNow];
            if (elapsed < kMinRequestInterval) {
                usleep((useconds_t)((kMinRequestInterval - elapsed) * 1000000));
            }
        }
        self.lastRequestTime = [NSDate date];

        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self _executeRequest:request completion:^(NSDictionary *result, NSError *error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(result, error);
                });
            }
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    });
}

- (void)_executeRequest:(NSURLRequest *)request completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSError *networkError = [NSError errorWithDomain:TTHueAPIClientErrorDomain
                                                        code:TTHueAPIClientErrorNetwork
                                                    userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Network error: %@", error.localizedDescription],
                                                               NSUnderlyingErrorKey: error}];
            if (completion) {
                completion(nil, networkError);
            }
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        // Log non-success responses for debugging
        if (data && (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300)) {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"[HueAPI] Response (%ld): %@", (long)httpResponse.statusCode, [dataString substringToIndex:MIN(500, dataString.length)]);
        }

        if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            NSString *message = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;

            // Use specific error code for authentication failures
            TTHueAPIClientErrorCode errorCode = TTHueAPIClientErrorHTTP;
            NSString *errorMessage;
            if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                errorCode = TTHueAPIClientErrorNotAuthenticated;
                errorMessage = @"Authentication failed. Please reconnect to your Hue bridge.";
                NSLog(@"[HueAPI] Authentication failed (%ld) - API key may be invalid", (long)httpResponse.statusCode);
            } else {
                errorMessage = [NSString stringWithFormat:@"HTTP error %ld: %@", (long)httpResponse.statusCode, message ?: @"Unknown error"];
            }

            NSError *httpError = [NSError errorWithDomain:TTHueAPIClientErrorDomain
                                                     code:errorCode
                                                 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            if (completion) {
                completion(nil, httpError);
            }
            return;
        }

        // Handle empty response (PUT/DELETE often return empty)
        if (!data || data.length == 0) {
            if (completion) {
                completion(@{}, nil);
            }
            return;
        }

        NSError *jsonError;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSError *decodeError = [NSError errorWithDomain:TTHueAPIClientErrorDomain
                                                       code:TTHueAPIClientErrorDecoding
                                                   userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to decode response: %@", jsonError.localizedDescription],
                                                              NSUnderlyingErrorKey: jsonError}];
            if (completion) {
                completion(nil, decodeError);
            }
            return;
        }

        if (completion) {
            completion(json, nil);
        }
    }];

    [task resume];
}

#pragma mark - NSURLSessionDelegate (SSL)

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

#pragma mark - Resource Fetching

- (void)fetchLightsWithCompletion:(TTHueAPILightsHandler)completion {
    [self getPath:@"/light" completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }

        NSArray *dataArray = response[@"data"];
        if (![dataArray isKindOfClass:[NSArray class]]) {
            completion(@[], nil);
            return;
        }

        NSMutableArray<TTHueLight *> *lights = [NSMutableArray array];
        for (NSDictionary *dict in dataArray) {
            TTHueLight *light = [[TTHueLight alloc] initWithDictionary:dict];
            [lights addObject:light];
        }
        completion(lights, nil);
    }];
}

- (void)fetchRoomsWithCompletion:(TTHueAPIRoomsHandler)completion {
    [self getPath:@"/room" completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }

        NSArray *dataArray = response[@"data"];
        if (![dataArray isKindOfClass:[NSArray class]]) {
            completion(@[], nil);
            return;
        }

        NSMutableArray<TTHueRoom *> *rooms = [NSMutableArray array];
        for (NSDictionary *dict in dataArray) {
            TTHueRoom *room = [[TTHueRoom alloc] initWithDictionary:dict];
            [rooms addObject:room];
        }
        completion(rooms, nil);
    }];
}

- (void)fetchGroupedLightsWithCompletion:(TTHueAPIGroupedLightsHandler)completion {
    [self getPath:@"/grouped_light" completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }

        NSArray *dataArray = response[@"data"];
        if (![dataArray isKindOfClass:[NSArray class]]) {
            completion(@[], nil);
            return;
        }

        NSMutableArray<TTHueGroupedLight *> *groupedLights = [NSMutableArray array];
        for (NSDictionary *dict in dataArray) {
            TTHueGroupedLight *groupedLight = [[TTHueGroupedLight alloc] initWithDictionary:dict];
            [groupedLights addObject:groupedLight];
        }
        completion(groupedLights, nil);
    }];
}

- (void)fetchScenesWithCompletion:(TTHueAPIScenesHandler)completion {
    [self getPath:@"/scene" completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }

        NSArray *dataArray = response[@"data"];
        if (![dataArray isKindOfClass:[NSArray class]]) {
            completion(@[], nil);
            return;
        }

        NSMutableArray<TTHueScene *> *scenes = [NSMutableArray array];
        for (NSDictionary *dict in dataArray) {
            TTHueScene *scene = [[TTHueScene alloc] initWithDictionary:dict];
            [scenes addObject:scene];
        }
        completion(scenes, nil);
    }];
}

- (void)fetchDevicesWithCompletion:(TTHueAPIDevicesHandler)completion {
    [self getPath:@"/device" completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }

        NSArray *dataArray = response[@"data"];
        if (![dataArray isKindOfClass:[NSArray class]]) {
            completion(@[], nil);
            return;
        }

        NSMutableArray<TTHueDevice *> *devices = [NSMutableArray array];
        for (NSDictionary *dict in dataArray) {
            TTHueDevice *device = [[TTHueDevice alloc] initWithDictionary:dict];
            [devices addObject:device];
        }
        completion(devices, nil);
    }];
}

- (void)fetchAllResourcesWithCompletion:(TTHueAPIResourceCacheHandler)completion {
    TTHueResourceCache *cache = [[TTHueResourceCache alloc] init];

    dispatch_group_t group = dispatch_group_create();
    __block NSError *firstError = nil;

    dispatch_group_enter(group);
    [self fetchLightsWithCompletion:^(NSArray<TTHueLight *> *lights, NSError *error) {
        if (error && !firstError) firstError = error;
        for (TTHueLight *light in lights) {
            cache.lights[light.lightId] = light;
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self fetchRoomsWithCompletion:^(NSArray<TTHueRoom *> *rooms, NSError *error) {
        if (error && !firstError) firstError = error;
        for (TTHueRoom *room in rooms) {
            cache.rooms[room.roomId] = room;
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self fetchGroupedLightsWithCompletion:^(NSArray<TTHueGroupedLight *> *groupedLights, NSError *error) {
        if (error && !firstError) firstError = error;
        for (TTHueGroupedLight *groupedLight in groupedLights) {
            cache.groupedLights[groupedLight.groupedLightId] = groupedLight;
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self fetchScenesWithCompletion:^(NSArray<TTHueScene *> *scenes, NSError *error) {
        if (error && !firstError) firstError = error;
        for (TTHueScene *scene in scenes) {
            cache.scenes[scene.sceneId] = scene;
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self fetchDevicesWithCompletion:^(NSArray<TTHueDevice *> *devices, NSError *error) {
        if (error && !firstError) firstError = error;
        for (TTHueDevice *device in devices) {
            cache.devices[device.deviceId] = device;
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (firstError) {
            completion(nil, firstError);
        } else {
            completion(cache, nil);
        }
    });
}

#pragma mark - Light Control

- (void)updateLightId:(NSString *)lightId
                   on:(NSNumber *)on
           brightness:(NSNumber *)brightness
                   xy:(TTHueXY *)xy
         transitionMs:(NSNumber *)transitionMs
               effect:(NSString *)effect
           completion:(TTHueAPICompletionHandler)completion {
    NSMutableDictionary *update = [NSMutableDictionary dictionary];

    if (on) {
        update[@"on"] = @{@"on": on};
    }
    if (brightness) {
        double clampedBrightness = MAX(0.0, MIN(100.0, brightness.doubleValue));
        update[@"dimming"] = @{@"brightness": @(clampedBrightness)};
    }
    if (xy) {
        update[@"color"] = @{@"xy": [xy toDictionary]};
    }
    if (transitionMs) {
        update[@"dynamics"] = @{@"duration": transitionMs};
    }
    if (effect) {
        update[@"effects"] = @{@"effect": effect};
    }

    NSString *path = [NSString stringWithFormat:@"/light/%@", lightId];
    [self putPath:path body:update completion:^(NSDictionary *response, NSError *error) {
        if (completion) {
            completion(response, error);
        }
    }];
}

- (void)updateGroupedLightId:(NSString *)groupedLightId
                          on:(NSNumber *)on
                  brightness:(NSNumber *)brightness
                  completion:(TTHueAPICompletionHandler)completion {
    NSMutableDictionary *update = [NSMutableDictionary dictionary];

    if (on) {
        update[@"on"] = @{@"on": on};
    }
    if (brightness) {
        double clampedBrightness = MAX(0.0, MIN(100.0, brightness.doubleValue));
        update[@"dimming"] = @{@"brightness": @(clampedBrightness)};
    }

    NSString *path = [NSString stringWithFormat:@"/grouped_light/%@", groupedLightId];
    [self putPath:path body:update completion:^(NSDictionary *response, NSError *error) {
        if (completion) {
            completion(response, error);
        }
    }];
}

#pragma mark - Scene Control

- (void)recallSceneId:(NSString *)sceneId
             duration:(NSNumber *)duration
           brightness:(NSNumber *)brightness
           completion:(TTHueAPICompletionHandler)completion {
    NSMutableDictionary *action = [NSMutableDictionary dictionary];
    action[@"action"] = @"active";

    if (duration) {
        action[@"duration"] = duration;
    }
    if (brightness) {
        action[@"dimming"] = @{@"brightness": brightness};
    }

    NSDictionary *recall = @{@"recall": action};
    NSString *path = [NSString stringWithFormat:@"/scene/%@", sceneId];

    [self putPath:path body:recall completion:^(NSDictionary *response, NSError *error) {
        if (completion) {
            completion(response, error);
        }
    }];
}

- (void)createSceneWithName:(NSString *)name
                     roomId:(NSString *)roomId
                    actions:(NSArray<TTHueSceneAction *> *)actions
                 completion:(TTHueAPICompletionHandler)completion {
    NSMutableDictionary *scene = [NSMutableDictionary dictionary];

    scene[@"metadata"] = @{
        @"name": name,
        @"appdata": @"TurnTouch"
    };
    scene[@"group"] = @{
        @"rid": roomId,
        @"rtype": @"room"
    };
    scene[@"type"] = @"scene";

    NSMutableArray *actionDicts = [NSMutableArray array];
    for (TTHueSceneAction *action in actions) {
        [actionDicts addObject:[action toDictionary]];
    }
    scene[@"actions"] = actionDicts;

    [self postPath:@"/scene" body:scene completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }

        // Extract created scene ID from response
        NSArray *data = response[@"data"];
        if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
            NSDictionary *first = data.firstObject;
            NSString *sceneId = first[@"rid"];
            completion(sceneId, nil);
        } else {
            NSError *invalidError = [NSError errorWithDomain:TTHueAPIClientErrorDomain
                                                        code:TTHueAPIClientErrorInvalidResponse
                                                    userInfo:@{NSLocalizedDescriptionKey: @"Invalid response from scene creation"}];
            completion(nil, invalidError);
        }
    }];
}

- (void)updateSceneId:(NSString *)sceneId
              actions:(NSArray<TTHueSceneAction *> *)actions
           completion:(TTHueAPICompletionHandler)completion {
    NSMutableArray *actionDicts = [NSMutableArray array];
    for (TTHueSceneAction *action in actions) {
        [actionDicts addObject:[action toDictionary]];
    }

    NSDictionary *update = @{@"actions": actionDicts};
    NSString *path = [NSString stringWithFormat:@"/scene/%@", sceneId];

    [self putPath:path body:update completion:^(NSDictionary *response, NSError *error) {
        if (completion) {
            completion(response, error);
        }
    }];
}

- (void)deleteSceneId:(NSString *)sceneId completion:(TTHueAPICompletionHandler)completion {
    NSString *path = [NSString stringWithFormat:@"/scene/%@", sceneId];
    [self deletePath:path completion:^(NSDictionary *response, NSError *error) {
        if (completion) {
            completion(response, error);
        }
    }];
}

#pragma mark - Helper Methods

+ (TTHueSceneAction *)createSceneActionWithLightId:(NSString *)lightId
                                                on:(BOOL)on
                                        brightness:(NSNumber *)brightness
                                                xy:(TTHueXY *)xy {
    TTHueResourceLink *target = [[TTHueResourceLink alloc] initWithRid:lightId rtype:@"light"];

    TTHueSceneActionState *actionState = [[TTHueSceneActionState alloc] init];
    actionState.on = [[TTHueOnState alloc] initWithOn:on];

    if (brightness) {
        actionState.dimming = [[TTHueDimming alloc] initWithBrightness:brightness.doubleValue];
    }
    if (xy) {
        TTHueColor *color = [[TTHueColor alloc] init];
        color.xy = xy;
        actionState.color = color;
    }

    return [[TTHueSceneAction alloc] initWithTarget:target action:actionState];
}

@end
