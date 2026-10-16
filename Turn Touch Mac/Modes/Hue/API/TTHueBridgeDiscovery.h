//
//  TTHueBridgeDiscovery.h
//  Turn Touch Mac
//
//  Bridge discovery via discovery.meethue.com (NUPNP)
//

#import <Foundation/Foundation.h>
#import "TTHueModels.h"

NS_ASSUME_NONNULL_BEGIN

/// Error codes for bridge discovery
typedef NS_ENUM(NSInteger, TTHueBridgeDiscoveryErrorCode) {
    TTHueBridgeDiscoveryErrorNetwork,
    TTHueBridgeDiscoveryErrorInvalidResponse,
    TTHueBridgeDiscoveryErrorNoBridgesFound,
    TTHueBridgeDiscoveryErrorCancelled,
    TTHueBridgeDiscoveryErrorRateLimited
};

/// Error domain for bridge discovery
extern NSString * const TTHueBridgeDiscoveryErrorDomain;

/// Protocol for receiving bridge discovery updates
@protocol TTHueBridgeDiscoveryDelegate <NSObject>
- (void)bridgeDiscoveryStarted;
- (void)bridgeDiscoveryFinished:(NSArray<TTHueDiscoveredBridge *> *)bridges;
- (void)bridgeDiscoveryError:(NSError *)error;
@end

/// Discovers Hue Bridges on the local network using Philips' NUPNP discovery service
@interface TTHueBridgeDiscovery : NSObject <NSURLSessionDelegate>

@property (nonatomic, weak, nullable) id<TTHueBridgeDiscoveryDelegate> delegate;

/// Discover Hue Bridges using the NUPNP discovery service
/// Results are delivered via delegate callbacks
- (void)startDiscovery;

/// Cancel ongoing discovery
- (void)cancelDiscovery;

/// Discover Hue Bridges with a completion handler
/// @param completion Called with discovered bridges or error
- (void)discoverBridgesWithCompletion:(void (^)(NSArray<TTHueDiscoveredBridge *> * _Nullable bridges, NSError * _Nullable error))completion;

/// Validate that a bridge is reachable at the given IP
/// @param ip The bridge IP address
/// @param completion Called with YES if bridge is reachable
- (void)validateBridgeIP:(NSString *)ip completion:(void (^)(BOOL valid))completion;

/// Get bridge name/info by querying its API
/// @param ip The bridge IP address
/// @param completion Called with name and bridgeId, or nil if failed
- (void)getBridgeInfoForIP:(NSString *)ip completion:(void (^)(NSString * _Nullable name, NSString * _Nullable bridgeId))completion;

@end

NS_ASSUME_NONNULL_END
