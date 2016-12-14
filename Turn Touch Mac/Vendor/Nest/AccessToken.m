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

#import "AccessToken.h"

@interface AccessToken () <NSCoding>

@property (nonatomic, strong) NSDate *expiresOn;

@end

@implementation AccessToken

/**
 * Tells whether or not the token is valid.
 * @return YES if valid token. NO if invalid token.
 */
- (BOOL)isValid
{
    if (self.token){
        if ([[NSDate date] compare:self.expiresOn] == NSOrderedAscending) {
            return YES;
        }
    }
    
    return NO;
}

/**
 * Sets the token and expiration date.
 * @param token The token string.
 * @param expiration The amount of time (in seconds) the token has until it expires.
 */
+ (AccessToken *)tokenWithToken:(NSString *)token expiresIn:(long)expiration;
{
    AccessToken *accessToken = [[AccessToken alloc] init];
    accessToken.token = token;
    accessToken.expiresOn = [[NSDate date] dateByAddingTimeInterval:expiration];
    return accessToken;
}

/**
 * Encode the access token.
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.token forKey:@"token"];
    [encoder encodeObject:self.expiresOn forKey:@"expiresOn"];
}

/**
 * Decode the access token.
 */
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.token = [decoder decodeObjectForKey:@"token"];
        self.expiresOn = [decoder decodeObjectForKey:@"expiresOn"];
    }
    return self;
}

@end
