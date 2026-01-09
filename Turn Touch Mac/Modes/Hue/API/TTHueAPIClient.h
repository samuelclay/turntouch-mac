//
//  TTHueAPIClient.h
//  Turn Touch Mac
//
//  REST client for Hue CLIP API v2
//

#import <Foundation/Foundation.h>
#import "TTHueModels.h"
#import "TTHueResourceCache.h"

NS_ASSUME_NONNULL_BEGIN

/// Error codes for API client
typedef NS_ENUM(NSInteger, TTHueAPIClientErrorCode) {
    TTHueAPIClientErrorInvalidURL,
    TTHueAPIClientErrorNotAuthenticated,
    TTHueAPIClientErrorNetwork,
    TTHueAPIClientErrorInvalidResponse,
    TTHueAPIClientErrorHTTP,
    TTHueAPIClientErrorDecoding,
    TTHueAPIClientErrorAPI
};

/// Error domain for API client
extern NSString * const TTHueAPIClientErrorDomain;

/// Completion handlers
typedef void (^TTHueAPICompletionHandler)(id _Nullable result, NSError * _Nullable error);
typedef void (^TTHueAPILightsHandler)(NSArray<TTHueLight *> * _Nullable lights, NSError * _Nullable error);
typedef void (^TTHueAPIRoomsHandler)(NSArray<TTHueRoom *> * _Nullable rooms, NSError * _Nullable error);
typedef void (^TTHueAPIGroupedLightsHandler)(NSArray<TTHueGroupedLight *> * _Nullable groupedLights, NSError * _Nullable error);
typedef void (^TTHueAPIScenesHandler)(NSArray<TTHueScene *> * _Nullable scenes, NSError * _Nullable error);
typedef void (^TTHueAPIDevicesHandler)(NSArray<TTHueDevice *> * _Nullable devices, NSError * _Nullable error);
typedef void (^TTHueAPIResourceCacheHandler)(TTHueResourceCache * _Nullable cache, NSError * _Nullable error);

/// REST API client for Hue CLIP API v2
@interface TTHueAPIClient : NSObject <NSURLSessionDelegate>

@property (nonatomic, copy, readonly) NSString *bridgeIP;
@property (nonatomic, copy, readonly) NSString *applicationKey;

- (instancetype)initWithBridgeIP:(NSString *)bridgeIP applicationKey:(NSString *)applicationKey;

#pragma mark - Resource Fetching

/// Fetch all lights
- (void)fetchLightsWithCompletion:(TTHueAPILightsHandler)completion;

/// Fetch all rooms
- (void)fetchRoomsWithCompletion:(TTHueAPIRoomsHandler)completion;

/// Fetch all grouped lights (for room control)
- (void)fetchGroupedLightsWithCompletion:(TTHueAPIGroupedLightsHandler)completion;

/// Fetch all scenes
- (void)fetchScenesWithCompletion:(TTHueAPIScenesHandler)completion;

/// Fetch all devices (for getting light model info)
- (void)fetchDevicesWithCompletion:(TTHueAPIDevicesHandler)completion;

/// Fetch all resources and populate a cache
- (void)fetchAllResourcesWithCompletion:(TTHueAPIResourceCacheHandler)completion;

#pragma mark - Light Control

/// Update a single light's state
/// @param lightId The light UUID
/// @param on Optional on state (pass nil to not change)
/// @param brightness Optional brightness 0.0-100.0 (pass nil to not change)
/// @param xy Optional color XY point (pass nil to not change)
/// @param transitionMs Optional transition time in milliseconds (pass nil for default)
/// @param effect Optional effect name ("no_effect", "color_loop", etc.)
/// @param completion Called when complete
- (void)updateLightId:(NSString *)lightId
                   on:(nullable NSNumber *)on
           brightness:(nullable NSNumber *)brightness
                   xy:(nullable TTHueXY *)xy
         transitionMs:(nullable NSNumber *)transitionMs
               effect:(nullable NSString *)effect
           completion:(nullable TTHueAPICompletionHandler)completion;

/// Update a grouped light (all lights in a room)
/// @param groupedLightId The grouped light UUID
/// @param on Optional on state
/// @param brightness Optional brightness 0.0-100.0
/// @param completion Called when complete
- (void)updateGroupedLightId:(NSString *)groupedLightId
                          on:(nullable NSNumber *)on
                  brightness:(nullable NSNumber *)brightness
                  completion:(nullable TTHueAPICompletionHandler)completion;

#pragma mark - Scene Control

/// Recall (activate) a scene
/// @param sceneId The scene UUID
/// @param duration Optional transition duration in milliseconds
/// @param brightness Optional brightness override 0.0-100.0
/// @param completion Called when complete
- (void)recallSceneId:(NSString *)sceneId
             duration:(nullable NSNumber *)duration
           brightness:(nullable NSNumber *)brightness
           completion:(nullable TTHueAPICompletionHandler)completion;

/// Create a new scene
/// @param name The scene name
/// @param roomId The room UUID to associate with
/// @param actions Array of scene actions
/// @param completion Called with the new scene ID or error
- (void)createSceneWithName:(NSString *)name
                     roomId:(NSString *)roomId
                    actions:(NSArray<TTHueSceneAction *> *)actions
                 completion:(TTHueAPICompletionHandler)completion;

/// Update a scene's actions (light states)
/// @param sceneId The scene UUID
/// @param actions Array of scene actions
/// @param completion Called when complete
- (void)updateSceneId:(NSString *)sceneId
              actions:(NSArray<TTHueSceneAction *> *)actions
           completion:(nullable TTHueAPICompletionHandler)completion;

/// Delete a scene
/// @param sceneId The scene UUID
/// @param completion Called when complete
- (void)deleteSceneId:(NSString *)sceneId
           completion:(nullable TTHueAPICompletionHandler)completion;

#pragma mark - Helper Methods

/// Create a scene action for a light with specific settings
+ (TTHueSceneAction *)createSceneActionWithLightId:(NSString *)lightId
                                                on:(BOOL)on
                                        brightness:(nullable NSNumber *)brightness
                                                xy:(nullable TTHueXY *)xy;

@end

NS_ASSUME_NONNULL_END
