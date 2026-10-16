//
//  TTHueResourceCache.m
//  Turn Touch Mac
//
//  In-memory cache for Hue resources
//

#import "TTHueResourceCache.h"

@implementation TTHueResourceCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _lights = [NSMutableDictionary dictionary];
        _rooms = [NSMutableDictionary dictionary];
        _groupedLights = [NSMutableDictionary dictionary];
        _scenes = [NSMutableDictionary dictionary];
        _devices = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)clear {
    [self.lights removeAllObjects];
    [self.rooms removeAllObjects];
    [self.groupedLights removeAllObjects];
    [self.scenes removeAllObjects];
    [self.devices removeAllObjects];
    self.bridge = nil;
}

- (NSString *)modelIdForLightId:(NSString *)lightId {
    // Find the device that owns this light
    for (TTHueDevice *device in self.devices.allValues) {
        if ([device.lightId isEqualToString:lightId]) {
            return device.productData.modelId;
        }
    }
    return nil;
}

- (NSArray<TTHueLight *> *)allLights {
    return [self.lights.allValues sortedArrayUsingComparator:^NSComparisonResult(TTHueLight *a, TTHueLight *b) {
        return [a.name compare:b.name];
    }];
}

- (NSArray<TTHueRoom *> *)allRooms {
    return [self.rooms.allValues sortedArrayUsingComparator:^NSComparisonResult(TTHueRoom *a, TTHueRoom *b) {
        return [a.name compare:b.name];
    }];
}

- (NSArray<TTHueScene *> *)allScenes {
    return [self.scenes.allValues sortedArrayUsingComparator:^NSComparisonResult(TTHueScene *a, TTHueScene *b) {
        return [a.name compare:b.name];
    }];
}

- (NSArray<TTHueScene *> *)scenesForRoomId:(NSString *)roomId {
    NSMutableArray<TTHueScene *> *result = [NSMutableArray array];
    for (TTHueScene *scene in self.scenes.allValues) {
        if ([scene.group.rid isEqualToString:roomId]) {
            [result addObject:scene];
        }
    }
    return [result sortedArrayUsingComparator:^NSComparisonResult(TTHueScene *a, TTHueScene *b) {
        return [a.name compare:b.name];
    }];
}

- (NSArray<TTHueLight *> *)lightsForRoomId:(NSString *)roomId {
    TTHueRoom *room = self.rooms[roomId];
    if (!room) {
        return @[];
    }

    NSMutableArray<TTHueLight *> *result = [NSMutableArray array];
    for (TTHueResourceLink *child in room.children) {
        // Children can be devices, so we need to find lights through devices
        if ([child.rtype isEqualToString:@"device"]) {
            TTHueDevice *device = self.devices[child.rid];
            NSString *lightId = device.lightId;
            if (lightId) {
                TTHueLight *light = self.lights[lightId];
                if (light) {
                    [result addObject:light];
                }
            }
        } else if ([child.rtype isEqualToString:@"light"]) {
            TTHueLight *light = self.lights[child.rid];
            if (light) {
                [result addObject:light];
            }
        }
    }

    // Also check by owner relationship
    for (TTHueLight *light in self.lights.allValues) {
        if (light.owner && [light.owner.rtype isEqualToString:@"device"]) {
            TTHueDevice *device = self.devices[light.owner.rid];
            if (device) {
                // Check if this device is in the room
                for (TTHueResourceLink *child in room.children) {
                    if ([child.rid isEqualToString:device.deviceId]) {
                        if (![result containsObject:light]) {
                            [result addObject:light];
                        }
                        break;
                    }
                }
            }
        }
    }

    return [result sortedArrayUsingComparator:^NSComparisonResult(TTHueLight *a, TTHueLight *b) {
        return [a.name compare:b.name];
    }];
}

- (void)updateLightFromEventData:(TTHueSSEEventData *)eventData {
    TTHueLight *existingLight = self.lights[eventData.eventId];
    if (!existingLight) {
        return;
    }

    // Update the light's state with new data from SSE event
    // Note: We update in place to preserve other properties
    if (eventData.on) {
        existingLight.on = eventData.on;
    }
    if (eventData.dimming) {
        existingLight.dimming = eventData.dimming;
    }
    if (eventData.color) {
        existingLight.color = eventData.color;
    }
    if (eventData.colorTemperature) {
        existingLight.colorTemperature = eventData.colorTemperature;
    }
    if (eventData.dynamics) {
        existingLight.dynamics = eventData.dynamics;
    }
    if (eventData.effects) {
        existingLight.effects = eventData.effects;
    }
}

- (void)updateLight:(TTHueLight *)light {
    if (!light || !light.lightId) {
        return;
    }

    TTHueLight *existingLight = self.lights[light.lightId];
    if (existingLight) {
        // Merge: update only non-nil properties
        if (light.on) existingLight.on = light.on;
        if (light.dimming) existingLight.dimming = light.dimming;
        if (light.color) existingLight.color = light.color;
        if (light.colorTemperature) existingLight.colorTemperature = light.colorTemperature;
        if (light.dynamics) existingLight.dynamics = light.dynamics;
        if (light.effects) existingLight.effects = light.effects;
        if (light.metadata) existingLight.metadata = light.metadata;
    } else {
        // Add new light
        self.lights[light.lightId] = light;
    }
}

- (void)updateScene:(TTHueScene *)scene {
    if (!scene || !scene.sceneId) {
        return;
    }
    self.scenes[scene.sceneId] = scene;
}

- (void)updateRoom:(TTHueRoom *)room {
    if (!room || !room.roomId) {
        return;
    }
    self.rooms[room.roomId] = room;
}

@end
