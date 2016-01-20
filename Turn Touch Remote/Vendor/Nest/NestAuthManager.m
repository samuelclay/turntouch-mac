/**
 *  Copyright 2014 Nest Labs Inc. All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#import "NestAuthManager.h"
#import "NestConstants.h"
#import "AccessToken.h"

@interface NestAuthManager ()

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation NestAuthManager

/**
 * Get the shared manager singleton.
 * @return The singleton object
 */
+ (NestAuthManager *)sharedManager {
	static dispatch_once_t once;
	static NestAuthManager *instance;
    
	dispatch_once(&once, ^{
		instance = [[NestAuthManager alloc] init];
	});
    
	return instance;
}


/**
 * Checks whether or not the current session is authenticated by checking for the
 * authorization token and making sure it is not expired.
 * @return YES if valid session, NO if invalid session.
 */
- (BOOL)isValidSession
{
    if ([self accessToken]) {
        return true;
    } else {
        return false;
    }
}

/**
 * Get the URL to get the authorizationcode.
 * @return The URL to get the authorization code (the login with nest screen).
 */
- (NSString *)authorizationURL
{
    // First get the client id
    NSString *clientId = [[NSUserDefaults standardUserDefaults] valueForKey:@"TT:mode:nest:clientId"];
    if (clientId) {
        return [NSString stringWithFormat:@"https://%@/login/oauth2?client_id=%@&state=%@", NestCurrentAPIDomain, clientId, NestState];
    } else {
        NSLog(@"Missing the Client ID");
        return nil;
    }
}

/**
 * Get the URL for to get the access key.
 * @return The URL to get the access token from Nest.
 */
- (NSString *)accessURL
{
    NSString *clientId = [[NSUserDefaults standardUserDefaults] valueForKey:@"TT:mode:nest:clientId"];
    NSString *clientSecret = [[NSUserDefaults standardUserDefaults] valueForKey:@"TT:mode:nest:clientSecret"];
    NSString *authorizationCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"TT:mode:nest:authorizationCode"];
    
    if (clientId && clientSecret && authorizationCode) {
        return [NSString stringWithFormat:@"https://api.%@/oauth2/access_token?code=%@&client_id=%@&client_secret=%@&grant_type=authorization_code", NestCurrentAPIDomain, authorizationCode, clientId, clientSecret];
    } else {
        if (!clientSecret) {
            NSLog(@"Missing Client Secret");
        }
        if (!clientId) {
            NSLog(@"Missing Client ID");
        }
        if (!authorizationCode) {
            NSLog(@"Missing authorization code");
        }
        return nil;
    }
}

/**
 * Get the access token (if there is one).
 * @return The access token for this session. String is nil if no access token.
 */
- (NSString *)accessToken
{
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"TT:mode:nest:accessToken"];
    
    // If there is nothing there -- return
    if (!encodedObject) {
        return nil;
    }
    AccessToken *at = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    if ([at isValid]) {
        return at.token;
    } else {
        return nil;
    }
}



/**
 * Set the authorization code.
 * @param The authorization code you wish to write to NSUserdefaults.
 */
- (void)setAuthorizationCode:(NSString *)authorizationCode
{
    [[NSUserDefaults standardUserDefaults] setObject:authorizationCode forKey:@"TT:mode:nest:authorizationCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self exchangeCodeForToken];
}

/**
 * Set the acccess token.
 * @param accessToken The access token you wish to set.
 * @param expiration The expiration of the token (long).
 */
- (void)setAccessToken:(NSString *)accessToken withExpiration:(long)expiration
{
    AccessToken *nat = [AccessToken tokenWithToken:accessToken expiresIn:expiration];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:nat];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"TT:mode:nest:accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/**
 * Set the client's ID.
 * @param clientId The client. Generally set in the app delegate
 */
- (void)setClientId:(NSString *)clientId
{
    [[NSUserDefaults standardUserDefaults] setObject:clientId forKey:@"TT:mode:nest:clientId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * Set the client's secret.
 * @param clientSecret The client's secret. Generally set in the app delegate
 */
- (void)setClientSecret:(NSString *)clientSecret
{
    [[NSUserDefaults standardUserDefaults] setObject:clientSecret forKey:@"TT:mode:nest:clientSecret"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

/**
 * Exchanges the authorization code for an access token.
 */
- (void)exchangeCodeForToken
{
    // Get the accessURL
    NSString *accessURL = [self accessURL];
    
    // For the POST request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:accessURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"form-data" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Create the response data
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
    
    // Store the access key
    long expiresIn = [[json objectForKey:@"expires_in"] longValue];
    NSString *accessToken = [json objectForKey:@"access_token"];
    [self setAccessToken:accessToken withExpiration:expiresIn];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    NSLog(@"Failed to get access key");
}

@end
