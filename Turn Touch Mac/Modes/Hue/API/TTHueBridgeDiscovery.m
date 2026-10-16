//
//  TTHueBridgeDiscovery.m
//  Turn Touch Mac
//
//  Bridge discovery via discovery.meethue.com (NUPNP)
//

#import "TTHueBridgeDiscovery.h"

NSString * const TTHueBridgeDiscoveryErrorDomain = @"TTHueBridgeDiscoveryError";

@interface TTHueBridgeDiscovery ()
@property (nonatomic, strong) NSURLSessionDataTask *discoveryTask;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation TTHueBridgeDiscovery

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 10.0;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)dealloc {
    [self cancelDiscovery];
    [_session invalidateAndCancel];
}

#pragma mark - Discovery

- (void)startDiscovery {
    [self discoverBridgesWithCompletion:^(NSArray<TTHueDiscoveredBridge *> *bridges, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self.delegate bridgeDiscoveryError:error];
            } else if (bridges.count == 0) {
                NSError *noBridgesError = [NSError errorWithDomain:TTHueBridgeDiscoveryErrorDomain
                                                              code:TTHueBridgeDiscoveryErrorNoBridgesFound
                                                          userInfo:@{NSLocalizedDescriptionKey: @"No Hue Bridges found on the network"}];
                [self.delegate bridgeDiscoveryError:noBridgesError];
            } else {
                [self.delegate bridgeDiscoveryFinished:bridges];
            }
        });
    }];
}

- (void)cancelDiscovery {
    [self.discoveryTask cancel];
    self.discoveryTask = nil;
}

- (void)discoverBridgesWithCompletion:(void (^)(NSArray<TTHueDiscoveredBridge *> * _Nullable, NSError * _Nullable))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate bridgeDiscoveryStarted];
    });

    NSURL *discoveryURL = [NSURL URLWithString:@"https://discovery.meethue.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:discoveryURL];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 10.0;

    self.discoveryTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (error.code == NSURLErrorCancelled) {
                NSError *cancelError = [NSError errorWithDomain:TTHueBridgeDiscoveryErrorDomain
                                                           code:TTHueBridgeDiscoveryErrorCancelled
                                                       userInfo:@{NSLocalizedDescriptionKey: @"Discovery was cancelled"}];
                completion(nil, cancelError);
            } else {
                NSError *networkError = [NSError errorWithDomain:TTHueBridgeDiscoveryErrorDomain
                                                            code:TTHueBridgeDiscoveryErrorNetwork
                                                        userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Network error: %@", error.localizedDescription],
                                                                   NSUnderlyingErrorKey: error}];
                completion(nil, networkError);
            }
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            NSError *httpError;
            if (httpResponse.statusCode == 429) {
                httpError = [NSError errorWithDomain:TTHueBridgeDiscoveryErrorDomain
                                                code:TTHueBridgeDiscoveryErrorRateLimited
                                            userInfo:@{NSLocalizedDescriptionKey: @"Philips Hue is rate-limiting requests. Please wait a moment and try again."}];
            } else {
                httpError = [NSError errorWithDomain:TTHueBridgeDiscoveryErrorDomain
                                                code:TTHueBridgeDiscoveryErrorInvalidResponse
                                            userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP error %ld", (long)httpResponse.statusCode]}];
            }
            completion(nil, httpError);
            return;
        }

        // Parse JSON response
        NSError *jsonError;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError || ![jsonArray isKindOfClass:[NSArray class]]) {
            NSLog(@"[TTHueBridgeDiscovery] Failed to decode response: %@", jsonError);
            if (data) {
                NSLog(@"[TTHueBridgeDiscovery] Response data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
            NSError *parseError = [NSError errorWithDomain:TTHueBridgeDiscoveryErrorDomain
                                                      code:TTHueBridgeDiscoveryErrorInvalidResponse
                                                  userInfo:@{NSLocalizedDescriptionKey: @"Invalid response from discovery service"}];
            completion(nil, parseError);
            return;
        }

        // Convert to bridge objects
        NSMutableArray<TTHueDiscoveredBridge *> *bridges = [NSMutableArray array];
        for (NSDictionary *dict in jsonArray) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                TTHueDiscoveredBridge *bridge = [[TTHueDiscoveredBridge alloc] initWithDictionary:dict];
                [bridges addObject:bridge];
            }
        }

        NSLog(@"[TTHueBridgeDiscovery] Discovered %lu bridges", (unsigned long)bridges.count);
        completion(bridges, nil);
    }];

    [self.discoveryTask resume];
}

#pragma mark - Validation

- (void)validateBridgeIP:(NSString *)ip completion:(void (^)(BOOL))completion {
    NSString *urlString = [NSString stringWithFormat:@"https://%@/api/0/config", ip];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 5.0;

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"[TTHueBridgeDiscovery] Bridge validation failed for %@: %@", ip, error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        BOOL valid = (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300);

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(valid);
        });
    }];

    [task resume];
}

- (void)getBridgeInfoForIP:(NSString *)ip completion:(void (^)(NSString * _Nullable, NSString * _Nullable))completion {
    NSString *urlString = [NSString stringWithFormat:@"https://%@/api/0/config", ip];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 5.0;

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"[TTHueBridgeDiscovery] Failed to get bridge info for %@: %@", ip, error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
            return;
        }

        NSError *jsonError;
        NSDictionary *config = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError || ![config isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
            return;
        }

        NSString *name = config[@"name"] ?: @"Hue Bridge";
        NSString *bridgeId = config[@"bridgeid"] ?: @"";

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(name, bridgeId);
        });
    }];

    [task resume];
}

#pragma mark - NSURLSessionDelegate (SSL)

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    // Trust self-signed certificates from Hue Bridge
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end
