//
//  TTHueEventStream.m
//  Turn Touch Mac
//
//  Server-Sent Events (SSE) for real-time Hue resource updates
//

#import "TTHueEventStream.h"
#import "TTHueAPIClient.h"

NSNotificationName const TTHueEventStreamLightsUpdatedNotification = @"TTHueEventStream.lightsUpdated";
NSNotificationName const TTHueEventStreamScenesUpdatedNotification = @"TTHueEventStream.scenesUpdated";
NSNotificationName const TTHueEventStreamRoomsUpdatedNotification = @"TTHueEventStream.roomsUpdated";
NSNotificationName const TTHueEventStreamGroupsUpdatedNotification = @"TTHueEventStream.groupsUpdated";
NSNotificationName const TTHueEventStreamConfigUpdatedNotification = @"TTHueEventStream.configUpdated";
NSNotificationName const TTHueEventStreamConnectedNotification = @"TTHueEventStream.connected";
NSNotificationName const TTHueEventStreamDisconnectedNotification = @"TTHueEventStream.disconnected";

@interface TTHueEventStream ()
@property (nonatomic, copy) NSString *bridgeIP;
@property (nonatomic, copy) NSString *applicationKey;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableData *buffer;

@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) NSInteger reconnectAttempts;
@property (nonatomic, assign) NSInteger maxReconnectAttempts;
@property (nonatomic, assign) NSTimeInterval reconnectDelay;
@property (nonatomic, assign) NSInteger lastHTTPStatusCode;

// Polling fallback
@property (nonatomic, strong, nullable) NSTimer *pollTimer;
@property (nonatomic, strong, nullable) TTHueAPIClient *pollClient;
@property (nonatomic, assign) BOOL usePollingFallback;
@end

@implementation TTHueEventStream

- (instancetype)initWithBridgeIP:(NSString *)bridgeIP applicationKey:(NSString *)applicationKey {
    self = [super init];
    if (self) {
        _bridgeIP = [bridgeIP copy];
        _applicationKey = [applicationKey copy];
        _buffer = [NSMutableData data];
        _isConnected = NO;
        _reconnectAttempts = 0;
        _maxReconnectAttempts = 5;
        _reconnectDelay = 1.0;
        _usePollingFallback = NO;
    }
    return self;
}

- (void)dealloc {
    [self disconnect];
}

#pragma mark - Connection Management

- (void)connect {
    if (self.isConnected) {
        return;
    }

    self.lastHTTPStatusCode = 0;  // Reset status code for new connection attempt
    NSString *urlString = [NSString stringWithFormat:@"https://%@/eventstream/clip/v2", self.bridgeIP];
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:self.applicationKey forHTTPHeaderField:@"hue-application-key"];
    [request setValue:@"text/event-stream" forHTTPHeaderField:@"Accept"];
    request.timeoutInterval = INFINITY;  // Keep alive

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = INFINITY;
    config.timeoutIntervalForResource = INFINITY;

    self.session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];

    self.dataTask = [self.session dataTaskWithRequest:request];
    [self.dataTask resume];

    NSLog(@"[TTHueEventStream] Connecting to SSE stream...");
}

- (void)disconnect {
    self.isConnected = NO;
    [self.dataTask cancel];
    self.dataTask = nil;
    [self.session invalidateAndCancel];
    self.session = nil;
    [self.buffer setLength:0];
    [self stopPolling];
    NSLog(@"[TTHueEventStream] Disconnected");
}

- (void)reconnect {
    [self disconnect];
    self.reconnectAttempts = 0;
    self.usePollingFallback = NO;
    [self connect];
}

- (void)attemptReconnect {
    if (self.reconnectAttempts >= self.maxReconnectAttempts) {
        NSLog(@"[TTHueEventStream] Max reconnect attempts reached, falling back to polling");
        [self startPollingFallback];
        return;
    }

    self.reconnectAttempts++;
    NSTimeInterval delay = self.reconnectDelay * (double)self.reconnectAttempts;

    NSLog(@"[TTHueEventStream] Attempting reconnect in %.1fs (attempt %ld)", delay, (long)self.reconnectAttempts);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self connect];
    });
}

#pragma mark - Polling Fallback

- (void)startPollingFallback {
    self.usePollingFallback = YES;
    self.pollClient = [[TTHueAPIClient alloc] initWithBridgeIP:self.bridgeIP applicationKey:self.applicationKey];

    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                      target:self
                                                    selector:@selector(pollForUpdates)
                                                    userInfo:nil
                                                     repeats:YES];
    [self.pollTimer fire];  // Immediate first poll

    NSLog(@"[TTHueEventStream] Started polling fallback (every 10s)");
}

- (void)stopPolling {
    [self.pollTimer invalidate];
    self.pollTimer = nil;
    self.pollClient = nil;
    self.usePollingFallback = NO;
}

- (void)pollForUpdates {
    if (!self.pollClient) {
        return;
    }

    [self.pollClient fetchLightsWithCompletion:^(NSArray<TTHueLight *> *lights, NSError *error) {
        if (error) {
            NSLog(@"[TTHueEventStream] Polling error: %@", error);
            return;
        }

        if (lights.count > 0) {
            [self.delegate eventStreamReceivedLightUpdates:lights];
            [self postLightUpdateNotification:lights];
        }
    }];
}

#pragma mark - Event Parsing

- (void)processBuffer {
    // SSE format: each event is separated by double newlines
    // Events start with "data: " followed by JSON

    NSString *text = [[NSString alloc] initWithData:self.buffer encoding:NSUTF8StringEncoding];
    if (!text) {
        return;
    }

    // Split by double newlines
    NSArray<NSString *> *events = [text componentsSeparatedByString:@"\n\n"];

    // Keep the last incomplete event in the buffer
    if (![text hasSuffix:@"\n\n"]) {
        NSString *lastEvent = events.lastObject;
        if (lastEvent && lastEvent.length > 0) {
            self.buffer = [[lastEvent dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
        } else {
            [self.buffer setLength:0];
        }
    } else {
        [self.buffer setLength:0];
    }

    // Process complete events
    NSUInteger dropCount = [text hasSuffix:@"\n\n"] ? 0 : 1;
    NSArray<NSString *> *completeEvents = [events subarrayWithRange:NSMakeRange(0, events.count - dropCount)];

    for (NSString *event in completeEvents) {
        if (event.length == 0) {
            continue;
        }

        // Parse the event data
        NSArray<NSString *> *lines = [event componentsSeparatedByString:@"\n"];
        NSString *eventData = @"";

        for (NSString *line in lines) {
            if ([line hasPrefix:@"data: "]) {
                eventData = [line substringFromIndex:6];
            } else if ([line hasPrefix:@": "] || [line isEqualToString:@":"]) {
                // Comment or heartbeat - ignore
                continue;
            }
        }

        if (eventData.length > 0) {
            [self parseEventData:eventData];
        }
    }
}

- (void)parseEventData:(NSString *)jsonString {
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return;
    }

    NSError *jsonError;
    NSArray *events = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError || ![events isKindOfClass:[NSArray class]]) {
        NSLog(@"[TTHueEventStream] Failed to parse event: %@", jsonError);
        NSLog(@"[TTHueEventStream] Raw data: %@", [jsonString substringToIndex:MIN(500, jsonString.length)]);
        return;
    }

    for (NSDictionary *eventDict in events) {
        if ([eventDict isKindOfClass:[NSDictionary class]]) {
            TTHueSSEEvent *event = [[TTHueSSEEvent alloc] initWithDictionary:eventDict];
            [self processEvent:event];
        }
    }
}

- (void)processEvent:(TTHueSSEEvent *)event {
    if (![event.type isEqualToString:@"update"] && ![event.type isEqualToString:@"add"]) {
        return;
    }

    NSMutableArray<TTHueLight *> *lights = [NSMutableArray array];

    for (TTHueSSEEventData *eventData in event.data) {
        if ([eventData.type isEqualToString:@"light"]) {
            TTHueLight *light = [self convertEventDataToLight:eventData];
            if (light) {
                [lights addObject:light];
            }
        }
        // Could add handling for scene, room, grouped_light updates here
    }

    if (lights.count > 0) {
        [self.delegate eventStreamReceivedLightUpdates:lights];
        [self postLightUpdateNotification:lights];
    }
}

- (TTHueLight *)convertEventDataToLight:(TTHueSSEEventData *)eventData {
    // Create a partial TTHueLight from the event data
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"id"] = eventData.eventId;
    if (eventData.idV1) {
        dict[@"id_v1"] = eventData.idV1;
    }
    dict[@"type"] = eventData.type;
    if (eventData.on) {
        dict[@"on"] = @{@"on": @(eventData.on.on)};
    }
    if (eventData.dimming) {
        dict[@"dimming"] = @{@"brightness": @(eventData.dimming.brightness)};
    }
    if (eventData.color && eventData.color.xy) {
        dict[@"color"] = @{@"xy": @{@"x": @(eventData.color.xy.x), @"y": @(eventData.color.xy.y)}};
    }
    if (eventData.colorTemperature && eventData.colorTemperature.mirek) {
        dict[@"color_temperature"] = @{@"mirek": eventData.colorTemperature.mirek};
    }
    if (eventData.metadata) {
        dict[@"metadata"] = @{@"name": eventData.metadata.name ?: @"Light"};
    }
    if (eventData.owner) {
        dict[@"owner"] = [eventData.owner toDictionary];
    }

    return [[TTHueLight alloc] initWithDictionary:dict];
}

#pragma mark - Notifications

- (void)postLightUpdateNotification:(NSArray<TTHueLight *> *)lights {
    [[NSNotificationCenter defaultCenter] postNotificationName:TTHueEventStreamLightsUpdatedNotification
                                                        object:self
                                                      userInfo:@{@"lights": lights}];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.buffer appendData:data];
    [self processBuffer];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.lastHTTPStatusCode = httpResponse.statusCode;
    if (httpResponse.statusCode == 200) {
        self.isConnected = YES;
        self.reconnectAttempts = 0;
        [self.delegate eventStreamConnected];
        [[NSNotificationCenter defaultCenter] postNotificationName:TTHueEventStreamConnectedNotification
                                                            object:self];
    } else if (httpResponse.statusCode == 403) {
        NSLog(@"[TTHueEventStream] Authentication failed (403 Forbidden) - will not retry");
    } else if (httpResponse.statusCode == 401) {
        NSLog(@"[TTHueEventStream] Unauthorized (401) - will not retry");
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    self.isConnected = NO;

    if (error && error.code == NSURLErrorCancelled) {
        // Intentional cancellation
        return;
    }

    NSLog(@"[TTHueEventStream] Connection ended: %@", error.localizedDescription ?: @"unknown");
    [self.delegate eventStreamDisconnectedWithError:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:TTHueEventStreamDisconnectedNotification
                                                        object:self
                                                      userInfo:error ? @{@"error": error} : nil];

    // Don't reconnect on 4xx client errors (authentication failures won't resolve by retrying)
    if (self.lastHTTPStatusCode >= 400 && self.lastHTTPStatusCode < 500) {
        NSLog(@"[TTHueEventStream] HTTP %ld error - not retrying (authentication/authorization issue)",
              (long)self.lastHTTPStatusCode);
        // Notify delegate of permanent failure so UI can show re-authentication
        [self.delegate eventStreamAuthenticationFailed];
        return;
    }

    // Attempt to reconnect for transient errors
    if (!self.usePollingFallback) {
        [self attemptReconnect];
    }
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

@end
