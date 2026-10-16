#import <Cocoa/Cocoa.h>

// Source-built Hue REST client; independent of the retired Philips binary SDK.
#define LOCAL_CONNECTION_NOTIFICATION @"TTHueConnected"
#define NO_LOCAL_CONNECTION_NOTIFICATION @"TTHueDisconnected"
#define NO_LOCAL_AUTHENTICATION_NOTIFICATION @"TTHueUnauthorized"
#define PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION @"TTHuePaired"
#define PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION @"TTHuePairingFailed"
#define PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION NO_LOCAL_CONNECTION_NOTIFICATION
#define PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION @"TTHueNoBridge"
#define PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION @"TTHueWaitingForButton"
#define SDK_ERROR_DOMAIN @"com.turntouch.hue"
#define PUSHLINK_TIME_LIMIT_REACHED 101
#define PUSHLINK_NO_LOCAL_BRIDGE 102
#define PUSHLINK_NO_CONNECTION 103
#define EFFECT_COLORLOOP 1

@interface TTHueLightState : NSObject
@property NSNumber *on, *brightness, *saturation, *hue, *x, *y, *transitionTime, *brightnessIncrement, *hueIncrement;
@property NSInteger alert, effect;
- (NSDictionary *)JSON;
@end
@interface TTHueLight : NSObject
@property NSString *identifier, *name, *modelNumber;
@property NSSet *stateKeys;
@end
@interface TTHueGroup : NSObject
@property NSString *identifier, *name;
@property NSArray *lightIdentifiers;
@end
@interface TTHueScene : NSObject
@property NSString *identifier, *name;
@property NSArray *lightIdentifiers;
@end
@interface TTHueBridgeConfiguration : NSObject
@property NSString *ipaddress, *bridgeId;
@end
@interface TTHueBridgeResources : NSObject
@property NSDictionary<NSString *, TTHueLight *> *lights;
@property NSDictionary<NSString *, TTHueGroup *> *groups;
@property NSDictionary<NSString *, TTHueScene *> *scenes;
@property TTHueBridgeConfiguration *bridgeConfiguration;
@end
@interface TTHueResourcesReader : NSObject
+ (TTHueBridgeResources *)readBridgeResourcesCache;
@end
@interface TTHueNotifications : NSObject
+ (instancetype)defaultManager;
- (void)registerObject:(id)object withSelector:(SEL)selector forNotification:(NSString *)name;
- (void)deregisterObjectForAllNotifications:(id)object;
@end
@interface TTHueClient : NSObject <NSURLSessionTaskDelegate>
@property (nonatomic, readonly) BOOL localConnected;
+ (instancetype)sharedClient;
- (void)startUpSDK;
- (void)enableLogging:(BOOL)enabled;
- (void)setBridgeToUseWithId:(NSString *)bridgeId ipAddress:(NSString *)address;
- (void)enableLocalConnection;
- (void)disableLocalConnection;
- (void)startPushlinkAuthentication;
@end
@interface TTHueBridgeSearch : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
- (instancetype)initWithUpnpSearch:(BOOL)upnp andPortalSearch:(BOOL)portal andIpAddressSearch:(BOOL)ip;
- (void)startSearchWithCompletionHandler:(void (^)(NSDictionary *))completion;
@end
@interface TTHueCommands : NSObject
- (void)activateSceneWithIdentifier:(NSString *)scene onGroup:(NSString *)group completionHandler:(void (^)(NSArray *errors))completion;
- (void)updateLightStateForId:(NSString *)identifier withLightState:(TTHueLightState *)state completionHandler:(void (^)(NSArray *errors))completion;
- (void)setLightStateForGroupWithId:(NSString *)identifier lightState:(TTHueLightState *)state completionHandler:(void (^)(NSArray *errors))completion;
- (void)getAllScenesWithCompletionHandler:(void (^)(NSDictionary *, NSArray *))completion;
- (void)saveSceneWithCurrentLightStates:(TTHueScene *)scene completionHandler:(void (^)(NSArray *errors))completion;
- (void)saveLightState:(TTHueLightState *)state forLightIdentifier:(NSString *)light inSceneWithIdentifier:(NSString *)scene completionHandler:(void (^)(NSArray *errors))completion;
@end
@interface TTHueColor : NSObject
+ (CGPoint)calculateXY:(NSColor *)color forModel:(NSString *)model;
@end
