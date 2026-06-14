//
//  TTHueModels.m
//  Turn Touch Mac
//
//  Data models for Hue CLIP API v2
//

#import "TTHueModels.h"

#pragma mark - TTHueDiscoveredBridge

@implementation TTHueDiscoveredBridge

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _bridgeId = dict[@"id"] ?: @"";
        _internalIPAddress = dict[@"internalipaddress"] ?: @"";
        _port = dict[@"port"];
    }
    return self;
}

- (NSString *)friendlyName {
    if (_bridgeId.length >= 4) {
        return [NSString stringWithFormat:@"Hue Bridge %@", [_bridgeId substringToIndex:4]];
    }
    return @"Hue Bridge";
}

- (NSString *)modelName {
    return @"Philips Hue Bridge";
}

@end

#pragma mark - TTHueAuthResult

@implementation TTHueAuthResult

- (instancetype)initWithBridgeIP:(NSString *)bridgeIP
                        bridgeId:(NSString *)bridgeId
                  applicationKey:(NSString *)applicationKey
                       clientKey:(NSString *)clientKey {
    self = [super init];
    if (self) {
        _bridgeIP = [bridgeIP copy];
        _bridgeId = [bridgeId copy];
        _applicationKey = [applicationKey copy];
        _clientKey = [clientKey copy];
    }
    return self;
}

@end

#pragma mark - TTHueResourceLink

@implementation TTHueResourceLink

- (instancetype)initWithRid:(NSString *)rid rtype:(NSString *)rtype {
    self = [super init];
    if (self) {
        _rid = [rid copy];
        _rtype = [rtype copy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    return [self initWithRid:dict[@"rid"] ?: @""
                       rtype:dict[@"rtype"] ?: @""];
}

- (NSDictionary *)toDictionary {
    return @{@"rid": self.rid, @"rtype": self.rtype};
}

@end

#pragma mark - TTHueOnState

@implementation TTHueOnState

- (instancetype)initWithOn:(BOOL)on {
    self = [super init];
    if (self) {
        _on = on;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    return [self initWithOn:[dict[@"on"] boolValue]];
}

- (NSDictionary *)toDictionary {
    return @{@"on": @(self.on)};
}

@end

#pragma mark - TTHueDimming

@implementation TTHueDimming

- (instancetype)initWithBrightness:(double)brightness {
    self = [super init];
    if (self) {
        _brightness = brightness;
        _minDimLevel = 0.0;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _brightness = [dict[@"brightness"] doubleValue];
        _minDimLevel = [dict[@"min_dim_level"] doubleValue];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    return @{@"brightness": @(self.brightness)};
}

@end

#pragma mark - TTHueXY

@implementation TTHueXY

- (instancetype)initWithX:(double)x y:(double)y {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
    }
    return self;
}

- (instancetype)initWithPoint:(CGPoint)point {
    return [self initWithX:point.x y:point.y];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    return [self initWithX:[dict[@"x"] doubleValue]
                         y:[dict[@"y"] doubleValue]];
}

- (CGPoint)cgPoint {
    return CGPointMake(self.x, self.y);
}

- (NSDictionary *)toDictionary {
    return @{@"x": @(self.x), @"y": @(self.y)};
}

@end

#pragma mark - TTHueGamut

@implementation TTHueGamut

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict[@"red"]) {
            _red = [[TTHueXY alloc] initWithDictionary:dict[@"red"]];
        }
        if (dict[@"green"]) {
            _green = [[TTHueXY alloc] initWithDictionary:dict[@"green"]];
        }
        if (dict[@"blue"]) {
            _blue = [[TTHueXY alloc] initWithDictionary:dict[@"blue"]];
        }
    }
    return self;
}

@end

#pragma mark - TTHueColor

@implementation TTHueColor

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict[@"xy"]) {
            _xy = [[TTHueXY alloc] initWithDictionary:dict[@"xy"]];
        }
        if (dict[@"gamut"]) {
            _gamut = [[TTHueGamut alloc] initWithDictionary:dict[@"gamut"]];
        }
        _gamutType = dict[@"gamut_type"];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    if (self.xy) {
        return @{@"xy": [self.xy toDictionary]};
    }
    return @{};
}

@end

#pragma mark - TTHueColorTemperature

@implementation TTHueColorTemperature

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _mirek = dict[@"mirek"];
        _mirekValid = [dict[@"mirek_valid"] boolValue];
        if (dict[@"mirek_schema"]) {
            NSDictionary *schema = dict[@"mirek_schema"];
            _mirekMinimum = schema[@"mirek_minimum"];
            _mirekMaximum = schema[@"mirek_maximum"];
        }
    }
    return self;
}

- (NSDictionary *)toDictionary {
    if (self.mirek) {
        return @{@"mirek": self.mirek};
    }
    return @{};
}

@end

#pragma mark - TTHueDynamics

@implementation TTHueDynamics

- (instancetype)initWithDuration:(NSInteger)duration {
    self = [super init];
    if (self) {
        _duration = @(duration);
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _duration = dict[@"duration"];
        _speed = dict[@"speed"];
        _speedValid = [dict[@"speed_valid"] boolValue];
        _status = dict[@"status"];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    if (self.duration) {
        return @{@"duration": self.duration};
    }
    return @{};
}

@end

#pragma mark - TTHueEffects

@implementation TTHueEffects

- (instancetype)initWithEffect:(NSString *)effect {
    self = [super init];
    if (self) {
        _effect = [effect copy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _effect = dict[@"effect"];
        _effectValues = dict[@"effect_values"];
        _status = dict[@"status"];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    if (self.effect) {
        return @{@"effect": self.effect};
    }
    return @{};
}

@end

#pragma mark - TTHueLightMetadata

@implementation TTHueLightMetadata

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = dict[@"name"] ?: @"Light";
        _archetype = dict[@"archetype"];
        _fixedMired = dict[@"fixed_mired"];
    }
    return self;
}

@end

#pragma mark - TTHueLight

@implementation TTHueLight

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _lightId = dict[@"id"] ?: @"";
        _idV1 = dict[@"id_v1"];
        if (dict[@"owner"]) {
            _owner = [[TTHueResourceLink alloc] initWithDictionary:dict[@"owner"]];
        }
        if (dict[@"metadata"]) {
            _metadata = [[TTHueLightMetadata alloc] initWithDictionary:dict[@"metadata"]];
        }
        if (dict[@"on"]) {
            _on = [[TTHueOnState alloc] initWithDictionary:dict[@"on"]];
        }
        if (dict[@"dimming"]) {
            _dimming = [[TTHueDimming alloc] initWithDictionary:dict[@"dimming"]];
        }
        if (dict[@"color_temperature"]) {
            _colorTemperature = [[TTHueColorTemperature alloc] initWithDictionary:dict[@"color_temperature"]];
        }
        if (dict[@"color"]) {
            _color = [[TTHueColor alloc] initWithDictionary:dict[@"color"]];
        }
        if (dict[@"dynamics"]) {
            _dynamics = [[TTHueDynamics alloc] initWithDictionary:dict[@"dynamics"]];
        }
        if (dict[@"effects"]) {
            _effects = [[TTHueEffects alloc] initWithDictionary:dict[@"effects"]];
        }
        _mode = dict[@"mode"];
        _type = dict[@"type"];
    }
    return self;
}

- (NSString *)name {
    return self.metadata.name ?: @"Light";
}

@end

#pragma mark - TTHueRoomMetadata

@implementation TTHueRoomMetadata

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = dict[@"name"] ?: @"Room";
        _archetype = dict[@"archetype"];
    }
    return self;
}

@end

#pragma mark - TTHueRoom

@implementation TTHueRoom

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _roomId = dict[@"id"] ?: @"";
        _idV1 = dict[@"id_v1"];
        if (dict[@"metadata"]) {
            _metadata = [[TTHueRoomMetadata alloc] initWithDictionary:dict[@"metadata"]];
        } else {
            _metadata = [[TTHueRoomMetadata alloc] init];
            _metadata.name = @"Room";
        }

        NSMutableArray<TTHueResourceLink *> *children = [NSMutableArray array];
        for (NSDictionary *childDict in dict[@"children"]) {
            TTHueResourceLink *child = [[TTHueResourceLink alloc] initWithDictionary:childDict];
            [children addObject:child];
        }
        _children = children;

        if (dict[@"services"]) {
            NSMutableArray<TTHueResourceLink *> *services = [NSMutableArray array];
            for (NSDictionary *serviceDict in dict[@"services"]) {
                TTHueResourceLink *service = [[TTHueResourceLink alloc] initWithDictionary:serviceDict];
                [services addObject:service];
            }
            _services = services;
        }
        _type = dict[@"type"];
    }
    return self;
}

- (NSString *)name {
    return self.metadata.name;
}

- (NSString *)groupedLightId {
    for (TTHueResourceLink *service in self.services) {
        if ([service.rtype isEqualToString:@"grouped_light"]) {
            return service.rid;
        }
    }
    return nil;
}

@end

#pragma mark - TTHueAlert

@implementation TTHueAlert

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _actionValues = dict[@"action_values"];
    }
    return self;
}

@end

#pragma mark - TTHueGroupedLight

@implementation TTHueGroupedLight

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _groupedLightId = dict[@"id"] ?: @"";
        _idV1 = dict[@"id_v1"];
        if (dict[@"owner"]) {
            _owner = [[TTHueResourceLink alloc] initWithDictionary:dict[@"owner"]];
        }
        if (dict[@"on"]) {
            _on = [[TTHueOnState alloc] initWithDictionary:dict[@"on"]];
        }
        if (dict[@"dimming"]) {
            _dimming = [[TTHueDimming alloc] initWithDictionary:dict[@"dimming"]];
        }
        if (dict[@"alert"]) {
            _alert = [[TTHueAlert alloc] initWithDictionary:dict[@"alert"]];
        }
        _type = dict[@"type"];
    }
    return self;
}

@end

#pragma mark - TTHueSceneMetadata

@implementation TTHueSceneMetadata

- (instancetype)initWithName:(NSString *)name image:(TTHueResourceLink *)image appdata:(NSString *)appdata {
    self = [super init];
    if (self) {
        _name = [name copy];
        _image = image;
        _appdata = [appdata copy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = dict[@"name"] ?: @"Scene";
        if (dict[@"image"]) {
            _image = [[TTHueResourceLink alloc] initWithDictionary:dict[@"image"]];
        }
        _appdata = dict[@"appdata"];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"name"] = self.name;
    if (self.image) {
        result[@"image"] = [self.image toDictionary];
    }
    if (self.appdata) {
        result[@"appdata"] = self.appdata;
    }
    return result;
}

@end

#pragma mark - TTHueSceneActionState

@implementation TTHueSceneActionState

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict[@"on"]) {
            _on = [[TTHueOnState alloc] initWithDictionary:dict[@"on"]];
        }
        if (dict[@"dimming"]) {
            _dimming = [[TTHueDimming alloc] initWithDictionary:dict[@"dimming"]];
        }
        if (dict[@"color"]) {
            _color = [[TTHueColor alloc] initWithDictionary:dict[@"color"]];
        }
        if (dict[@"color_temperature"]) {
            _colorTemperature = [[TTHueColorTemperature alloc] initWithDictionary:dict[@"color_temperature"]];
        }
        if (dict[@"effects"]) {
            _effects = [[TTHueEffects alloc] initWithDictionary:dict[@"effects"]];
        }
        if (dict[@"dynamics"]) {
            _dynamics = [[TTHueDynamics alloc] initWithDictionary:dict[@"dynamics"]];
        }
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (self.on) {
        result[@"on"] = [self.on toDictionary];
    }
    if (self.dimming) {
        result[@"dimming"] = [self.dimming toDictionary];
    }
    if (self.color) {
        result[@"color"] = [self.color toDictionary];
    }
    if (self.colorTemperature) {
        result[@"color_temperature"] = [self.colorTemperature toDictionary];
    }
    if (self.effects) {
        result[@"effects"] = [self.effects toDictionary];
    }
    if (self.dynamics) {
        result[@"dynamics"] = [self.dynamics toDictionary];
    }
    return result;
}

@end

#pragma mark - TTHueSceneAction

@implementation TTHueSceneAction

- (instancetype)initWithTarget:(TTHueResourceLink *)target action:(TTHueSceneActionState *)action {
    self = [super init];
    if (self) {
        _target = target;
        _action = action;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict[@"target"]) {
            _target = [[TTHueResourceLink alloc] initWithDictionary:dict[@"target"]];
        }
        if (dict[@"action"]) {
            _action = [[TTHueSceneActionState alloc] initWithDictionary:dict[@"action"]];
        }
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (self.target) {
        result[@"target"] = [self.target toDictionary];
    }
    if (self.action) {
        result[@"action"] = [self.action toDictionary];
    }
    return result;
}

@end

#pragma mark - TTHueSceneStatus

@implementation TTHueSceneStatus

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _active = dict[@"active"];
    }
    return self;
}

@end

#pragma mark - TTHueScene

@implementation TTHueScene

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _sceneId = dict[@"id"] ?: @"";
        _idV1 = dict[@"id_v1"];
        if (dict[@"metadata"]) {
            _metadata = [[TTHueSceneMetadata alloc] initWithDictionary:dict[@"metadata"]];
        } else {
            _metadata = [[TTHueSceneMetadata alloc] initWithName:@"Scene" image:nil appdata:nil];
        }
        if (dict[@"group"]) {
            _group = [[TTHueResourceLink alloc] initWithDictionary:dict[@"group"]];
        } else {
            _group = [[TTHueResourceLink alloc] initWithRid:@"" rtype:@"room"];
        }
        if (dict[@"actions"]) {
            NSMutableArray<TTHueSceneAction *> *actions = [NSMutableArray array];
            for (NSDictionary *actionDict in dict[@"actions"]) {
                TTHueSceneAction *action = [[TTHueSceneAction alloc] initWithDictionary:actionDict];
                [actions addObject:action];
            }
            _actions = actions;
        }
        _speed = dict[@"speed"];
        _autoDynamic = [dict[@"auto_dynamic"] boolValue];
        if (dict[@"status"]) {
            _status = [[TTHueSceneStatus alloc] initWithDictionary:dict[@"status"]];
        }
        _type = dict[@"type"];
    }
    return self;
}

- (NSString *)name {
    return self.metadata.name;
}

@end

#pragma mark - TTHueProductData

@implementation TTHueProductData

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _modelId = dict[@"model_id"];
        _manufacturerName = dict[@"manufacturer_name"];
        _productName = dict[@"product_name"];
        _productArchetype = dict[@"product_archetype"];
        _certified = [dict[@"certified"] boolValue];
        _softwareVersion = dict[@"software_version"];
    }
    return self;
}

@end

#pragma mark - TTHueDeviceMetadata

@implementation TTHueDeviceMetadata

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = dict[@"name"] ?: @"Device";
        _archetype = dict[@"archetype"];
    }
    return self;
}

@end

#pragma mark - TTHueDevice

@implementation TTHueDevice

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _deviceId = dict[@"id"] ?: @"";
        _idV1 = dict[@"id_v1"];
        if (dict[@"product_data"]) {
            _productData = [[TTHueProductData alloc] initWithDictionary:dict[@"product_data"]];
        }
        if (dict[@"metadata"]) {
            _metadata = [[TTHueDeviceMetadata alloc] initWithDictionary:dict[@"metadata"]];
        }
        if (dict[@"services"]) {
            NSMutableArray<TTHueResourceLink *> *services = [NSMutableArray array];
            for (NSDictionary *serviceDict in dict[@"services"]) {
                TTHueResourceLink *service = [[TTHueResourceLink alloc] initWithDictionary:serviceDict];
                [services addObject:service];
            }
            _services = services;
        }
        _type = dict[@"type"];
    }
    return self;
}

- (NSString *)lightId {
    for (TTHueResourceLink *service in self.services) {
        if ([service.rtype isEqualToString:@"light"]) {
            return service.rid;
        }
    }
    return nil;
}

@end

#pragma mark - TTHueBridge

@implementation TTHueBridge

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _bridgeResourceId = dict[@"id"] ?: @"";
        _idV1 = dict[@"id_v1"];
        _bridgeId = dict[@"bridge_id"];
        if (dict[@"owner"]) {
            _owner = [[TTHueResourceLink alloc] initWithDictionary:dict[@"owner"]];
        }
        if (dict[@"time_zone"]) {
            NSDictionary *tzDict = dict[@"time_zone"];
            _timeZone = tzDict[@"time_zone"];
        }
        _type = dict[@"type"];
    }
    return self;
}

@end

#pragma mark - TTHueAPIError

@implementation TTHueAPIError

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _errorDescription = dict[@"description"] ?: @"Unknown error";
    }
    return self;
}

@end

#pragma mark - TTHueSSEEventData

@implementation TTHueSSEEventData

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _eventId = dict[@"id"] ?: @"";
        _idV1 = dict[@"id_v1"];
        _type = dict[@"type"] ?: @"";
        if (dict[@"on"]) {
            _on = [[TTHueOnState alloc] initWithDictionary:dict[@"on"]];
        }
        if (dict[@"dimming"]) {
            _dimming = [[TTHueDimming alloc] initWithDictionary:dict[@"dimming"]];
        }
        if (dict[@"color"]) {
            _color = [[TTHueColor alloc] initWithDictionary:dict[@"color"]];
        }
        if (dict[@"color_temperature"]) {
            _colorTemperature = [[TTHueColorTemperature alloc] initWithDictionary:dict[@"color_temperature"]];
        }
        if (dict[@"dynamics"]) {
            _dynamics = [[TTHueDynamics alloc] initWithDictionary:dict[@"dynamics"]];
        }
        if (dict[@"effects"]) {
            _effects = [[TTHueEffects alloc] initWithDictionary:dict[@"effects"]];
        }
        if (dict[@"metadata"]) {
            _metadata = [[TTHueLightMetadata alloc] initWithDictionary:dict[@"metadata"]];
        }
        if (dict[@"owner"]) {
            _owner = [[TTHueResourceLink alloc] initWithDictionary:dict[@"owner"]];
        }
    }
    return self;
}

@end

#pragma mark - TTHueSSEEvent

@implementation TTHueSSEEvent

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _creationTime = dict[@"creationtime"];
        _eventId = dict[@"id"];
        _type = dict[@"type"] ?: @"";
        if (dict[@"data"]) {
            NSMutableArray<TTHueSSEEventData *> *data = [NSMutableArray array];
            for (NSDictionary *dataDict in dict[@"data"]) {
                TTHueSSEEventData *eventData = [[TTHueSSEEventData alloc] initWithDictionary:dataDict];
                [data addObject:eventData];
            }
            _data = data;
        } else {
            _data = @[];
        }
    }
    return self;
}

@end
