//
//  TTHueBridgeAuthenticator.h
//  Turn Touch Mac
//
//  Pushlink authentication flow for Hue Bridge
//

#import <Foundation/Foundation.h>
#import "TTHueModels.h"

NS_ASSUME_NONNULL_BEGIN

/// Error codes for authentication
typedef NS_ENUM(NSInteger, TTHueBridgeAuthenticatorErrorCode) {
    TTHueBridgeAuthenticatorErrorNetwork,
    TTHueBridgeAuthenticatorErrorInvalidResponse,
    TTHueBridgeAuthenticatorErrorLinkButtonNotPressed,
    TTHueBridgeAuthenticatorErrorTimeout,
    TTHueBridgeAuthenticatorErrorCancelled,
    TTHueBridgeAuthenticatorErrorAuthenticationFailed
};

/// Error domain for authentication
extern NSString * const TTHueBridgeAuthenticatorErrorDomain;

/// Protocol for receiving authentication updates
@protocol TTHueBridgeAuthenticatorDelegate <NSObject>
- (void)authenticationStarted;
- (void)authenticationProgressWithRemainingSeconds:(NSInteger)seconds;
- (void)authenticationSucceededWithResult:(TTHueAuthResult *)result;
- (void)authenticationFailedWithError:(NSError *)error;
@end

/// Handles the pushlink authentication flow with a Hue Bridge
@interface TTHueBridgeAuthenticator : NSObject <NSURLSessionDelegate>

@property (nonatomic, weak, nullable) id<TTHueBridgeAuthenticatorDelegate> delegate;

/// Start the authentication process
/// @param bridgeIP The IP address of the bridge
/// @param bridgeId The bridge identifier
- (void)startAuthenticationWithBridgeIP:(NSString *)bridgeIP bridgeId:(NSString *)bridgeId;

/// Cancel the authentication process
- (void)cancelAuthentication;

#pragma mark - Credential Storage (Class Methods)

/// Save authentication result to UserDefaults
+ (void)saveCredentials:(TTHueAuthResult *)result;

/// Load saved credentials for a specific bridge
+ (nullable TTHueAuthResult *)loadCredentialsForBridgeId:(NSString *)bridgeId;

/// Load all saved bridge credentials
+ (NSArray<NSDictionary *> *)loadAllCredentials;

/// Remove saved credentials for a bridge
+ (void)removeCredentialsForBridgeId:(NSString *)bridgeId;

/// Update the IP address for a saved bridge (in case it changed)
+ (void)updateBridgeIP:(NSString *)newIP forBridgeId:(NSString *)bridgeId;

/// Get the most recently used bridge ID
+ (nullable NSString *)recentBridgeId;

/// Set the most recently used bridge ID
+ (void)setRecentBridgeId:(nullable NSString *)bridgeId;

/// Get the most recently used bridge IP
+ (nullable NSString *)recentBridgeIP;

/// Set the most recently used bridge IP
+ (void)setRecentBridgeIP:(nullable NSString *)bridgeIP;

/// Save the recently used bridge info
+ (void)saveRecentBridgeId:(NSString *)bridgeId ip:(NSString *)ip;

#pragma mark - Legacy Credential Migration

/// Attempt to migrate credentials from old PHHueSDK format
/// @return YES if credentials were migrated, NO if no legacy credentials found
+ (BOOL)migrateLegacyCredentials;

@end

NS_ASSUME_NONNULL_END
