//
//  TTHueBridgeAuthenticator.m
//  Turn Touch Mac
//
//  Pushlink authentication flow for Hue Bridge
//

#import "TTHueBridgeAuthenticator.h"
#import <IOKit/IOKitLib.h>

NSString * const TTHueBridgeAuthenticatorErrorDomain = @"TTHueBridgeAuthenticatorError";

static NSString * const kSavedBridgesKey = @"TT:savedHueBridges";
static NSString * const kRecentBridgeIdKey = @"TT:recentHueBridgeId";
static NSString * const kRecentBridgeIPKey = @"TT:recentHueBridgeIP";

@interface TTHueBridgeAuthenticator ()
@property (nonatomic, assign) NSInteger timeoutSeconds;
@property (nonatomic, assign) NSTimeInterval pollingInterval;
@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, copy) NSString *currentBridgeIP;
@property (nonatomic, copy) NSString *currentBridgeId;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSTimer *pollingTimer;
@property (nonatomic, strong) NSDate *startTime;
@end

@implementation TTHueBridgeAuthenticator

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeoutSeconds = 30;
        _pollingInterval = 1.0;
        _isCancelled = NO;

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 10.0;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)dealloc {
    [self cancelAuthentication];
    [_session invalidateAndCancel];
}

#pragma mark - Device Type

- (NSString *)deviceType {
    NSString *deviceName = [[NSHost currentHost] localizedName] ?: @"Mac";
    // Remove spaces and limit to 19 characters
    deviceName = [deviceName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    if (deviceName.length > 19) {
        deviceName = [deviceName substringToIndex:19];
    }
    return [NSString stringWithFormat:@"TurnTouch#%@", deviceName];
}

#pragma mark - Authentication

- (void)startAuthenticationWithBridgeIP:(NSString *)bridgeIP bridgeId:(NSString *)bridgeId {
    self.isCancelled = NO;
    self.currentBridgeIP = bridgeIP;
    self.currentBridgeId = bridgeId;
    self.startTime = [NSDate date];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate authenticationStarted];
    });

    // Start polling timer
    [self scheduleNextPoll];
}

- (void)cancelAuthentication {
    self.isCancelled = YES;
    [self.pollingTimer invalidate];
    self.pollingTimer = nil;
}

- (void)scheduleNextPoll {
    if (self.isCancelled) {
        return;
    }

    // Check timeout
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.startTime];
    NSInteger remainingSeconds = self.timeoutSeconds - (NSInteger)elapsed;

    if (remainingSeconds <= 0) {
        NSError *timeoutError = [NSError errorWithDomain:TTHueBridgeAuthenticatorErrorDomain
                                                    code:TTHueBridgeAuthenticatorErrorTimeout
                                                userInfo:@{NSLocalizedDescriptionKey: @"Authentication timed out"}];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate authenticationFailedWithError:timeoutError];
        });
        return;
    }

    // Notify delegate of progress
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate authenticationProgressWithRemainingSeconds:remainingSeconds];
    });

    // Attempt authentication
    [self attemptAuthenticationWithCompletion:^(TTHueAuthResult *result, NSError *error) {
        if (self.isCancelled) {
            return;
        }

        if (result) {
            // Success!
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate authenticationSucceededWithResult:result];
            });
            return;
        }

        if (error && error.code != TTHueBridgeAuthenticatorErrorLinkButtonNotPressed) {
            // Real error, not just waiting for button press
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate authenticationFailedWithError:error];
            });
            return;
        }

        // Schedule next poll
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.pollingInterval * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self scheduleNextPoll];
        });
    }];
}

- (void)attemptAuthenticationWithCompletion:(void (^)(TTHueAuthResult * _Nullable, NSError * _Nullable))completion {
    NSString *urlString = [NSString stringWithFormat:@"https://%@/api", self.currentBridgeIP];
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"[TTHueBridgeAuthenticator] Attempting pushlink auth at: %@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // Request body - ask for an entertainment client key as well
    NSDictionary *body = @{
        @"devicetype": [self deviceType],
        @"generateclientkey": @YES
    };
    NSError *jsonError;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
    if (jsonError) {
        completion(nil, jsonError);
        return;
    }

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"[TTHueBridgeAuthenticator] Network error: %@", error);
            NSError *networkError = [NSError errorWithDomain:TTHueBridgeAuthenticatorErrorDomain
                                                        code:TTHueBridgeAuthenticatorErrorNetwork
                                                    userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Network error: %@", error.localizedDescription],
                                                               NSUnderlyingErrorKey: error}];
            completion(nil, networkError);
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"[TTHueBridgeAuthenticator] Response status: %ld", (long)httpResponse.statusCode);

        // Parse response
        NSError *parseError;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError || ![jsonArray isKindOfClass:[NSArray class]] || jsonArray.count == 0) {
            if (data) {
                NSLog(@"[TTHueBridgeAuthenticator] Unexpected response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
            NSError *invalidError = [NSError errorWithDomain:TTHueBridgeAuthenticatorErrorDomain
                                                        code:TTHueBridgeAuthenticatorErrorInvalidResponse
                                                    userInfo:@{NSLocalizedDescriptionKey: @"Invalid response from bridge"}];
            completion(nil, invalidError);
            return;
        }

        NSDictionary *firstItem = jsonArray.firstObject;
        if (![firstItem isKindOfClass:[NSDictionary class]]) {
            NSError *invalidError = [NSError errorWithDomain:TTHueBridgeAuthenticatorErrorDomain
                                                        code:TTHueBridgeAuthenticatorErrorInvalidResponse
                                                    userInfo:@{NSLocalizedDescriptionKey: @"Invalid response from bridge"}];
            completion(nil, invalidError);
            return;
        }

        // Check for success
        NSDictionary *success = firstItem[@"success"];
        if (success && [success isKindOfClass:[NSDictionary class]]) {
            NSString *username = success[@"username"];
            NSString *clientKey = success[@"clientkey"];

            if (username) {
                TTHueAuthResult *result = [[TTHueAuthResult alloc] initWithBridgeIP:self.currentBridgeIP
                                                                           bridgeId:self.currentBridgeId
                                                                     applicationKey:username
                                                                          clientKey:clientKey];
                completion(result, nil);
                return;
            }
        }

        // Check for error
        NSDictionary *errorDict = firstItem[@"error"];
        if (errorDict && [errorDict isKindOfClass:[NSDictionary class]]) {
            NSInteger type = [errorDict[@"type"] integerValue];
            NSString *description = errorDict[@"description"] ?: @"Unknown error";

            if (type == 101) {
                // Link button not pressed - this is expected, waiting for user
                NSLog(@"[TTHueBridgeAuthenticator] Waiting for link button press...");
                NSError *linkError = [NSError errorWithDomain:TTHueBridgeAuthenticatorErrorDomain
                                                         code:TTHueBridgeAuthenticatorErrorLinkButtonNotPressed
                                                     userInfo:@{NSLocalizedDescriptionKey: @"Link button not pressed"}];
                completion(nil, linkError);
                return;
            }

            NSError *authError = [NSError errorWithDomain:TTHueBridgeAuthenticatorErrorDomain
                                                     code:TTHueBridgeAuthenticatorErrorAuthenticationFailed
                                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Authentication failed: %@", description]}];
            completion(nil, authError);
            return;
        }

        NSError *invalidError = [NSError errorWithDomain:TTHueBridgeAuthenticatorErrorDomain
                                                    code:TTHueBridgeAuthenticatorErrorInvalidResponse
                                                userInfo:@{NSLocalizedDescriptionKey: @"Invalid response from bridge"}];
        completion(nil, invalidError);
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

#pragma mark - Credential Storage

+ (void)saveCredentials:(TTHueAuthResult *)result {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedBridges = [[prefs arrayForKey:kSavedBridgesKey] mutableCopy] ?: [NSMutableArray array];

    // Remove existing entry for this bridge
    NSInteger existingIndex = -1;
    for (NSInteger i = 0; i < savedBridges.count; i++) {
        NSDictionary *bridge = savedBridges[i];
        if ([bridge[@"serialNumber"] isEqualToString:result.bridgeId]) {
            existingIndex = i;
            break;
        }
    }
    if (existingIndex >= 0) {
        [savedBridges removeObjectAtIndex:existingIndex];
    }

    // Add new entry at front (format matches TTModeHue expectations)
    NSDictionary *newBridge = @{
        @"ip": result.bridgeIP,
        @"serialNumber": result.bridgeId,
        @"username": result.applicationKey,
        @"clientKey": result.clientKey ?: @"",
        @"deviceType": @"Hue Bridge"
    };
    [savedBridges insertObject:newBridge atIndex:0];

    [prefs setObject:savedBridges forKey:kSavedBridgesKey];
    [prefs synchronize];
}

+ (TTHueAuthResult *)loadCredentialsForBridgeId:(NSString *)bridgeId {
    NSArray *savedBridges = [[NSUserDefaults standardUserDefaults] arrayForKey:kSavedBridgesKey];
    if (!savedBridges) {
        return nil;
    }

    for (NSDictionary *bridgeData in savedBridges) {
        if (![bridgeData isKindOfClass:[NSDictionary class]]) continue;

        NSString *serialNumber = bridgeData[@"serialNumber"];
        if ([serialNumber isEqualToString:bridgeId]) {
            NSString *ip = bridgeData[@"ip"];
            NSString *username = bridgeData[@"username"];

            if (!ip || !username) {
                return nil;
            }

            return [[TTHueAuthResult alloc] initWithBridgeIP:ip
                                                    bridgeId:bridgeId
                                              applicationKey:username
                                                   clientKey:bridgeData[@"clientKey"]];
        }
    }

    return nil;
}

+ (NSArray<NSDictionary *> *)loadAllCredentials {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    // First try to load as array (new format)
    NSArray *arrayResult = [prefs arrayForKey:kSavedBridgesKey];
    if (arrayResult) {
        return arrayResult;
    }

    // Check if it's in old dictionary format and migrate
    NSDictionary *dictResult = [prefs dictionaryForKey:kSavedBridgesKey];
    if (dictResult && dictResult.count > 0) {
        NSLog(@"[TTHueBridgeAuthenticator] Migrating %lu bridges from dictionary to array format", (unsigned long)dictResult.count);

        NSMutableArray *migratedBridges = [NSMutableArray array];
        for (NSString *bridgeId in dictResult) {
            NSDictionary *oldBridge = dictResult[bridgeId];
            if (![oldBridge isKindOfClass:[NSDictionary class]]) continue;

            NSString *ip = oldBridge[@"ip"];
            NSString *username = oldBridge[@"username"];
            NSString *clientKey = oldBridge[@"clientKey"];

            if (ip && username) {
                NSDictionary *newBridge = @{
                    @"ip": ip,
                    @"serialNumber": bridgeId,
                    @"username": username,
                    @"clientKey": clientKey ?: @"",
                    @"deviceType": @"Hue Bridge"
                };
                [migratedBridges addObject:newBridge];
                NSLog(@"[TTHueBridgeAuthenticator] Migrated bridge: %@ at %@", bridgeId, ip);
            }
        }

        // Save in new format
        if (migratedBridges.count > 0) {
            [prefs setObject:migratedBridges forKey:kSavedBridgesKey];
            [prefs synchronize];
            return migratedBridges;
        }
    }

    return @[];
}

+ (void)removeCredentialsForBridgeId:(NSString *)bridgeId {
    NSMutableArray *savedBridges = [[self loadAllCredentials] mutableCopy];

    NSInteger indexToRemove = -1;
    for (NSInteger i = 0; i < savedBridges.count; i++) {
        NSDictionary *bridge = savedBridges[i];
        if ([bridge[@"serialNumber"] isEqualToString:bridgeId]) {
            indexToRemove = i;
            break;
        }
    }

    if (indexToRemove >= 0) {
        [savedBridges removeObjectAtIndex:indexToRemove];
    }

    [[NSUserDefaults standardUserDefaults] setObject:savedBridges forKey:kSavedBridgesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)updateBridgeIP:(NSString *)newIP forBridgeId:(NSString *)bridgeId {
    NSMutableArray *savedBridges = [[self loadAllCredentials] mutableCopy];

    for (NSInteger i = 0; i < savedBridges.count; i++) {
        NSDictionary *bridge = savedBridges[i];
        if ([bridge[@"serialNumber"] isEqualToString:bridgeId]) {
            NSMutableDictionary *updatedBridge = [bridge mutableCopy];
            updatedBridge[@"ip"] = newIP;
            [savedBridges replaceObjectAtIndex:i withObject:updatedBridge];
            [[NSUserDefaults standardUserDefaults] setObject:savedBridges forKey:kSavedBridgesKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        }
    }
}

+ (NSString *)recentBridgeId {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kRecentBridgeIdKey];
}

+ (void)setRecentBridgeId:(NSString *)bridgeId {
    [[NSUserDefaults standardUserDefaults] setObject:bridgeId forKey:kRecentBridgeIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)recentBridgeIP {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kRecentBridgeIPKey];
}

+ (void)setRecentBridgeIP:(NSString *)bridgeIP {
    [[NSUserDefaults standardUserDefaults] setObject:bridgeIP forKey:kRecentBridgeIPKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveRecentBridgeId:(NSString *)bridgeId ip:(NSString *)ip {
    [self setRecentBridgeId:bridgeId];
    [self setRecentBridgeIP:ip];
}

#pragma mark - Legacy Credential Migration

+ (BOOL)migrateLegacyCredentials {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Check if existing saved bridges are missing usernames
    NSArray *savedBridges = [defaults arrayForKey:kSavedBridgesKey];
    BOOL needsMigration = NO;

    if (savedBridges.count > 0) {
        for (NSDictionary *bridge in savedBridges) {
            NSString *username = bridge[@"username"];
            if (!username || username.length == 0) {
                needsMigration = YES;
                break;
            }
        }
        if (!needsMigration) {
            return NO;  // All bridges have usernames
        }
    }

    // Try to find legacy PHHueSDK credentials
    NSLog(@"[TTHueBridgeAuthenticator] Looking for legacy PHHueSDK credentials...");

    // Try to decode PHHueSDK's phBridgeResourcesCache
    // This is an NSKeyedArchiver-encoded blob containing bridge configuration
    NSData *cacheData = [defaults dataForKey:@"phBridgeResourcesCache"];
    NSString *foundUsername = nil;

    if (cacheData) {
        NSLog(@"[TTHueBridgeAuthenticator] Found phBridgeResourcesCache (%lu bytes)", (unsigned long)cacheData.length);

        // Try to unarchive and extract username
        @try {
            // The cache contains serialized objects - try to find username string in the data
            // PHHueSDK usernames are 40-character alphanumeric strings
            NSString *cacheString = [[NSString alloc] initWithData:cacheData encoding:NSASCIIStringEncoding];
            if (!cacheString) {
                // Try to find it in the raw bytes by looking for patterns
                NSString *hexString = [cacheData description];
                NSLog(@"[TTHueBridgeAuthenticator] Cache data (partial): %@", [hexString substringToIndex:MIN(200, hexString.length)]);
            }

            // Use NSKeyedUnarchiver to decode if possible
            NSError *unarchiveError;
            NSSet *allowedClasses = [NSSet setWithObjects:[NSDictionary class], [NSArray class], [NSString class], [NSNumber class], [NSData class], nil];
            id unarchivedObject = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:cacheData error:&unarchiveError];

            if (unarchivedObject && [unarchivedObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *cache = (NSDictionary *)unarchivedObject;
                NSLog(@"[TTHueBridgeAuthenticator] Unarchived cache keys: %@", cache.allKeys);

                // Look for username in various places
                foundUsername = cache[@"username"] ?: cache[@"bridgeConfiguration"][@"username"];
            } else if (unarchiveError) {
                NSLog(@"[TTHueBridgeAuthenticator] Could not unarchive: %@", unarchiveError);
            }
        } @catch (NSException *exception) {
            NSLog(@"[TTHueBridgeAuthenticator] Exception unarchiving cache: %@", exception);
        }

        // If unarchiving failed, try to find username pattern in raw data
        if (!foundUsername) {
            // PHHueSDK usernames are 40-char alphanumeric strings
            // Search for them in the defaults
            NSDictionary *allDefaults = [defaults dictionaryRepresentation];
            NSString *allDefaultsString = [allDefaults description];

            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z0-9]{40}"
                                                                                   options:0
                                                                                     error:nil];
            NSArray *matches = [regex matchesInString:allDefaultsString options:0 range:NSMakeRange(0, allDefaultsString.length)];

            for (NSTextCheckingResult *match in matches) {
                NSString *candidate = [allDefaultsString substringWithRange:match.range];
                // Hue usernames typically have mixed case and numbers
                if ([candidate rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound &&
                    [candidate rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].location != NSNotFound &&
                    [candidate rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound) {
                    foundUsername = candidate;
                    NSLog(@"[TTHueBridgeAuthenticator] Found potential username via regex: %@", foundUsername);
                    break;
                }
            }
        }
    }

    // If we found a username, update the existing saved bridges
    if (foundUsername && savedBridges.count > 0) {
        NSMutableArray *updatedBridges = [NSMutableArray array];
        for (NSDictionary *bridge in savedBridges) {
            NSMutableDictionary *updatedBridge = [bridge mutableCopy];
            if (!updatedBridge[@"username"] || [updatedBridge[@"username"] length] == 0) {
                updatedBridge[@"username"] = foundUsername;
                NSLog(@"[TTHueBridgeAuthenticator] Added username to bridge %@", bridge[@"serialNumber"]);
            }
            [updatedBridges addObject:updatedBridge];
        }
        [defaults setObject:updatedBridges forKey:kSavedBridgesKey];
        [defaults synchronize];
        NSLog(@"[TTHueBridgeAuthenticator] Migrated %lu bridges with username", (unsigned long)updatedBridges.count);
        return YES;
    }

    // If we found a username but no saved bridges, try to get IP from recent bridge or discovery
    if (foundUsername) {
        NSString *recentIP = [self recentBridgeIP];
        NSString *recentBridgeId = [self recentBridgeId];

        if (recentIP && recentIP.length > 0) {
            // We have a username and a recent IP - create a new saved bridge
            if (!recentBridgeId || recentBridgeId.length == 0) {
                recentBridgeId = @"migrated-bridge";
            }

            TTHueAuthResult *result = [[TTHueAuthResult alloc] initWithBridgeIP:recentIP
                                                                        bridgeId:recentBridgeId
                                                                  applicationKey:foundUsername
                                                                       clientKey:nil];
            [self saveCredentials:result];
            NSLog(@"[TTHueBridgeAuthenticator] Created new bridge entry with migrated username at IP %@", recentIP);
            return YES;
        } else {
            // Save the username for later when we discover a bridge
            [defaults setObject:foundUsername forKey:@"TT:pendingHueUsername"];
            [defaults synchronize];
            NSLog(@"[TTHueBridgeAuthenticator] Saved pending username for future bridge discovery");
        }
    }

    // Fallback: Look for any bridge info in other keys
    NSDictionary *allDefaults = [defaults dictionaryRepresentation];
    for (NSString *key in allDefaults.allKeys) {
        if ([key.lowercaseString containsString:@"hue"] ||
            [key.lowercaseString containsString:@"bridge"]) {
            id value = allDefaults[key];
            if ([value isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)value;
                NSString *username = dict[@"username"] ?: dict[@"user"] ?: dict[@"applicationKey"];
                NSString *ip = dict[@"ip"] ?: dict[@"ipaddress"] ?: dict[@"internalipaddress"];
                NSString *bridgeId = dict[@"bridgeid"] ?: dict[@"id"] ?: dict[@"bridgeId"] ?: dict[@"serialNumber"];

                if (username && ip) {
                    if (!bridgeId || bridgeId.length == 0) {
                        bridgeId = [[NSUUID UUID] UUIDString];
                    }
                    TTHueAuthResult *result = [[TTHueAuthResult alloc] initWithBridgeIP:ip
                                                                               bridgeId:bridgeId
                                                                         applicationKey:username
                                                                              clientKey:nil];
                    [self saveCredentials:result];
                    [self saveRecentBridgeId:bridgeId ip:ip];
                    NSLog(@"[TTHueBridgeAuthenticator] Migrated legacy credentials for bridge: %@", bridgeId);
                    return YES;
                }
            }
        }
    }

    NSLog(@"[TTHueBridgeAuthenticator] No legacy credentials found to migrate");
    return NO;
}

@end
