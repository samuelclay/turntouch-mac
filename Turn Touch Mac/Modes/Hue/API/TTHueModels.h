//
//  TTHueModels.h
//  Turn Touch Mac
//
//  Data models for Hue CLIP API v2
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Bridge Discovery

/// Represents a discovered Hue bridge from discovery.meethue.com
@interface TTHueDiscoveredBridge : NSObject
@property (nonatomic, copy) NSString *bridgeId;
@property (nonatomic, copy) NSString *internalIPAddress;
@property (nonatomic, strong, nullable) NSNumber *port;
@property (nonatomic, copy, readonly) NSString *friendlyName;
@property (nonatomic, copy, readonly) NSString *modelName;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

#pragma mark - Authentication Result

@interface TTHueAuthResult : NSObject
@property (nonatomic, copy) NSString *bridgeIP;
@property (nonatomic, copy) NSString *bridgeId;
@property (nonatomic, copy) NSString *applicationKey;  // "username" in v1
@property (nonatomic, copy, nullable) NSString *clientKey;
- (instancetype)initWithBridgeIP:(NSString *)bridgeIP
                        bridgeId:(NSString *)bridgeId
                  applicationKey:(NSString *)applicationKey
                       clientKey:(nullable NSString *)clientKey;
@end

#pragma mark - Resource Link (API v2 references between resources)

@interface TTHueResourceLink : NSObject
@property (nonatomic, copy) NSString *rid;      // Resource ID (UUID)
@property (nonatomic, copy) NSString *rtype;    // Resource type
- (instancetype)initWithRid:(NSString *)rid rtype:(NSString *)rtype;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end

#pragma mark - Light State Components

@interface TTHueOnState : NSObject
@property (nonatomic) BOOL on;
- (instancetype)initWithOn:(BOOL)on;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end

@interface TTHueDimming : NSObject
@property (nonatomic) double brightness;  // 0.0-100.0 (not 0-254!)
@property (nonatomic) double minDimLevel;
- (instancetype)initWithBrightness:(double)brightness;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end

@interface TTHueXY : NSObject
@property (nonatomic) double x;
@property (nonatomic) double y;
- (instancetype)initWithX:(double)x y:(double)y;
- (instancetype)initWithPoint:(CGPoint)point;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (CGPoint)cgPoint;
- (NSDictionary *)toDictionary;
@end

@interface TTHueGamut : NSObject
@property (nonatomic, strong) TTHueXY *red;
@property (nonatomic, strong) TTHueXY *green;
@property (nonatomic, strong) TTHueXY *blue;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

@interface TTHueColor : NSObject
@property (nonatomic, strong, nullable) TTHueXY *xy;
@property (nonatomic, strong, nullable) TTHueGamut *gamut;
@property (nonatomic, copy, nullable) NSString *gamutType;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end

@interface TTHueColorTemperature : NSObject
@property (nonatomic, strong, nullable) NSNumber *mirek;
@property (nonatomic) BOOL mirekValid;
@property (nonatomic, strong, nullable) NSNumber *mirekMinimum;
@property (nonatomic, strong, nullable) NSNumber *mirekMaximum;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end

@interface TTHueDynamics : NSObject
@property (nonatomic, strong, nullable) NSNumber *duration;  // Transition time in milliseconds
@property (nonatomic, strong, nullable) NSNumber *speed;
@property (nonatomic) BOOL speedValid;
@property (nonatomic, copy, nullable) NSString *status;
- (instancetype)initWithDuration:(NSInteger)duration;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end

@interface TTHueEffects : NSObject
@property (nonatomic, copy, nullable) NSString *effect;  // "no_effect", "color_loop", etc.
@property (nonatomic, strong, nullable) NSArray<NSString *> *effectValues;
@property (nonatomic, copy, nullable) NSString *status;
- (instancetype)initWithEffect:(NSString *)effect;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end

#pragma mark - Light Metadata

@interface TTHueLightMetadata : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *archetype;
@property (nonatomic, strong, nullable) NSNumber *fixedMired;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

#pragma mark - Light

@interface TTHueLight : NSObject
@property (nonatomic, copy) NSString *lightId;              // UUID
@property (nonatomic, copy, nullable) NSString *idV1;       // Legacy v1 ID (e.g., "/lights/1")
@property (nonatomic, strong, nullable) TTHueResourceLink *owner;
@property (nonatomic, strong, nullable) TTHueLightMetadata *metadata;
@property (nonatomic, strong, nullable) TTHueOnState *on;
@property (nonatomic, strong, nullable) TTHueDimming *dimming;
@property (nonatomic, strong, nullable) TTHueColorTemperature *colorTemperature;
@property (nonatomic, strong, nullable) TTHueColor *color;
@property (nonatomic, strong, nullable) TTHueDynamics *dynamics;
@property (nonatomic, strong, nullable) TTHueEffects *effects;
@property (nonatomic, copy, nullable) NSString *mode;
@property (nonatomic, copy, nullable) NSString *type;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSString *)name;
@end

#pragma mark - Room Metadata

@interface TTHueRoomMetadata : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *archetype;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

#pragma mark - Room

@interface TTHueRoom : NSObject
@property (nonatomic, copy) NSString *roomId;               // UUID
@property (nonatomic, copy, nullable) NSString *idV1;       // Legacy v1 ID (e.g., "/groups/1")
@property (nonatomic, strong) TTHueRoomMetadata *metadata;
@property (nonatomic, strong) NSArray<TTHueResourceLink *> *children;   // Links to devices/lights
@property (nonatomic, strong, nullable) NSArray<TTHueResourceLink *> *services;  // Links to grouped_light, etc.
@property (nonatomic, copy, nullable) NSString *type;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSString *)name;
- (nullable NSString *)groupedLightId;  // Helper to get grouped_light service ID
@end

#pragma mark - Alert

@interface TTHueAlert : NSObject
@property (nonatomic, strong, nullable) NSArray<NSString *> *actionValues;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

#pragma mark - Grouped Light (for controlling all lights in a room)

@interface TTHueGroupedLight : NSObject
@property (nonatomic, copy) NSString *groupedLightId;
@property (nonatomic, copy, nullable) NSString *idV1;
@property (nonatomic, strong, nullable) TTHueResourceLink *owner;
@property (nonatomic, strong, nullable) TTHueOnState *on;
@property (nonatomic, strong, nullable) TTHueDimming *dimming;
@property (nonatomic, strong, nullable) TTHueAlert *alert;
@property (nonatomic, copy, nullable) NSString *type;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

#pragma mark - Scene Metadata

@interface TTHueSceneMetadata : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong, nullable) TTHueResourceLink *image;
@property (nonatomic, copy, nullable) NSString *appdata;
- (instancetype)initWithName:(NSString *)name image:(nullable TTHueResourceLink *)image appdata:(nullable NSString *)appdata;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end

#pragma mark - Scene Action State

@interface TTHueSceneActionState : NSObject
@property (nonatomic, strong, nullable) TTHueOnState *on;
@property (nonatomic, strong, nullable) TTHueDimming *dimming;
@property (nonatomic, strong, nullable) TTHueColor *color;
@property (nonatomic, strong, nullable) TTHueColorTemperature *colorTemperature;
@property (nonatomic, strong, nullable) TTHueEffects *effects;
@property (nonatomic, strong, nullable) TTHueDynamics *dynamics;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end

#pragma mark - Scene Action

@interface TTHueSceneAction : NSObject
@property (nonatomic, strong) TTHueResourceLink *target;
@property (nonatomic, strong) TTHueSceneActionState *action;
- (instancetype)initWithTarget:(TTHueResourceLink *)target action:(TTHueSceneActionState *)action;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end

#pragma mark - Scene Status

@interface TTHueSceneStatus : NSObject
@property (nonatomic, copy, nullable) NSString *active;  // "inactive", "static", "dynamic_palette"
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

#pragma mark - Scene

@interface TTHueScene : NSObject
@property (nonatomic, copy) NSString *sceneId;              // UUID
@property (nonatomic, copy, nullable) NSString *idV1;       // Legacy v1 ID
@property (nonatomic, strong) TTHueSceneMetadata *metadata;
@property (nonatomic, strong) TTHueResourceLink *group;     // Room this scene belongs to
@property (nonatomic, strong, nullable) NSArray<TTHueSceneAction *> *actions;
@property (nonatomic, strong, nullable) NSNumber *speed;
@property (nonatomic) BOOL autoDynamic;
@property (nonatomic, strong, nullable) TTHueSceneStatus *status;
@property (nonatomic, copy, nullable) NSString *type;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSString *)name;
@end

#pragma mark - Device Product Data

@interface TTHueProductData : NSObject
@property (nonatomic, copy, nullable) NSString *modelId;
@property (nonatomic, copy, nullable) NSString *manufacturerName;
@property (nonatomic, copy, nullable) NSString *productName;
@property (nonatomic, copy, nullable) NSString *productArchetype;
@property (nonatomic) BOOL certified;
@property (nonatomic, copy, nullable) NSString *softwareVersion;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

#pragma mark - Device Metadata

@interface TTHueDeviceMetadata : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *archetype;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

#pragma mark - Device

@interface TTHueDevice : NSObject
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy, nullable) NSString *idV1;
@property (nonatomic, strong, nullable) TTHueProductData *productData;
@property (nonatomic, strong, nullable) TTHueDeviceMetadata *metadata;
@property (nonatomic, strong, nullable) NSArray<TTHueResourceLink *> *services;
@property (nonatomic, copy, nullable) NSString *type;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (nullable NSString *)lightId;  // Helper to get light service ID
@end

#pragma mark - Bridge

@interface TTHueBridge : NSObject
@property (nonatomic, copy) NSString *bridgeResourceId;
@property (nonatomic, copy, nullable) NSString *idV1;
@property (nonatomic, copy, nullable) NSString *bridgeId;
@property (nonatomic, strong, nullable) TTHueResourceLink *owner;
@property (nonatomic, copy, nullable) NSString *timeZone;
@property (nonatomic, copy, nullable) NSString *type;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

#pragma mark - API Response Wrapper

@interface TTHueAPIError : NSObject
@property (nonatomic, copy) NSString *errorDescription;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

#pragma mark - SSE Event Types

@interface TTHueSSEEventData : NSObject
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy, nullable) NSString *idV1;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong, nullable) TTHueOnState *on;
@property (nonatomic, strong, nullable) TTHueDimming *dimming;
@property (nonatomic, strong, nullable) TTHueColor *color;
@property (nonatomic, strong, nullable) TTHueColorTemperature *colorTemperature;
@property (nonatomic, strong, nullable) TTHueDynamics *dynamics;
@property (nonatomic, strong, nullable) TTHueEffects *effects;
@property (nonatomic, strong, nullable) TTHueLightMetadata *metadata;
@property (nonatomic, strong, nullable) TTHueResourceLink *owner;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

@interface TTHueSSEEvent : NSObject
@property (nonatomic, copy, nullable) NSString *creationTime;
@property (nonatomic, copy, nullable) NSString *eventId;
@property (nonatomic, copy) NSString *type;  // "update", "add", "delete"
@property (nonatomic, strong) NSArray<TTHueSSEEventData *> *data;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
