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

#import "FirebaseManager.h"
#import "NestAuthManager.h"

#import <Firebase/Firebase.h>

@interface FirebaseManager ()

@property (nonatomic, strong) NSMutableDictionary *subscribedURLs;
@property (nonatomic, strong) NSMutableDictionary *fireBi; // The plural of Firebase

@property (nonatomic, strong) Firebase *rootFirebase;

@end

@implementation FirebaseManager

/**
 * Creates or retrieves the shared Firebase manager.
 * @return The singleton shared Firebase manager.
 */
+ (FirebaseManager *)sharedManager
{
    static dispatch_once_t once;
	static FirebaseManager *instance;
    
	dispatch_once(&once, ^{
		instance = [[FirebaseManager alloc] init];
	});
    
	return instance;
}

- (id)init
{
    if (self = [super init]) {
        self.subscribedURLs = [[NSMutableDictionary alloc] init];
        self.fireBi = [[NSMutableDictionary alloc] init];
        self.rootFirebase = [[Firebase alloc] initWithUrl:@"https://developer-api.nest.com/"];
        [self.rootFirebase authWithCredential:[[NestAuthManager sharedManager] accessToken] withCompletionBlock:^(NSError *error, id data) {} withCancelBlock:^(NSError *error) {}];
    }
    
    return self;
}

/**
 * Adds a subscription to the URL and creates a new firebase for that subscription
 * @param URL The URL you wish to subscribe to.
 * @param block The block you want to execute when values change at the specified firebase location.
 */
- (void)addSubscriptionToURL:(NSString *)URL withBlock:(SubscriptionBlock)block
{
    if ([self.subscribedURLs objectForKey:URL]) {
        
        // Don't add another subscription
        block([self.subscribedURLs objectForKey:URL]);
        
    } else {
        Firebase *newFirebase = [self.rootFirebase childByAppendingPath:URL];

        [newFirebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            [self.subscribedURLs setObject:snapshot forKey:URL];
            block(snapshot);
        }];
        
        [self.fireBi setObject:newFirebase forKey:URL];

    }
}

/**
 * Sets the values for the given firebase URL.
 * @param values The key value pairs you want to update.
 * @param URL The URL you want to update to.
 */
- (void)setValues:(NSDictionary *)values forURL:(NSString *)URL
{
    if ([self.subscribedURLs objectForKey:URL]) {
        // IMPORTANT to set withLocalEvents to NO
        // Read more here: https://www.firebase.com/docs/transactions.html
        [[self.fireBi objectForKey:URL]  runTransactionBlock:^FTransactionResult *(FMutableData *currentData) {
            [currentData setValue:values];
            return [FTransactionResult successWithValue:currentData];
        } andCompletionBlock:^(NSError *error, BOOL committed, FDataSnapshot *snapshot) {
            if (error) {
                NSLog(@"Error: %@", error);
            }
        } withLocalEvents:NO];
    }
}

@end
