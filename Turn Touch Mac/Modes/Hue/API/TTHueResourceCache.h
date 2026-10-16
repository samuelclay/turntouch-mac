//
//  TTHueResourceCache.h
//  Turn Touch Mac
//
//  In-memory cache for Hue resources
//

#import <Foundation/Foundation.h>
#import "TTHueModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTHueResourceCache : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, TTHueLight *> *lights;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TTHueRoom *> *rooms;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TTHueGroupedLight *> *groupedLights;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TTHueScene *> *scenes;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TTHueDevice *> *devices;
@property (nonatomic, strong, nullable) TTHueBridge *bridge;

/// Clear all cached resources
- (void)clear;

/// Get model ID for a light (needed for color gamut calculation)
/// @param lightId The light UUID
/// @return The model ID string if found, nil otherwise
- (nullable NSString *)modelIdForLightId:(NSString *)lightId;

/// Get all lights as an array
- (NSArray<TTHueLight *> *)allLights;

/// Get all rooms as an array
- (NSArray<TTHueRoom *> *)allRooms;

/// Get all scenes as an array
- (NSArray<TTHueScene *> *)allScenes;

/// Get scenes for a specific room
- (NSArray<TTHueScene *> *)scenesForRoomId:(NSString *)roomId;

/// Get lights for a specific room
- (NSArray<TTHueLight *> *)lightsForRoomId:(NSString *)roomId;

/// Update a light from SSE event data
- (void)updateLightFromEventData:(TTHueSSEEventData *)eventData;

/// Update a light (merge partial update)
- (void)updateLight:(TTHueLight *)light;

/// Update a scene (merge partial update)
- (void)updateScene:(TTHueScene *)scene;

/// Update a room (merge partial update)
- (void)updateRoom:(TTHueRoom *)room;

@end

NS_ASSUME_NONNULL_END
