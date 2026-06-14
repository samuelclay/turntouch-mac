//
//  TTHueEventStream.h
//  Turn Touch Mac
//
//  Server-Sent Events (SSE) for real-time Hue resource updates
//

#import <Foundation/Foundation.h>
#import "TTHueModels.h"

NS_ASSUME_NONNULL_BEGIN

/// Notification names for resource updates
extern NSNotificationName const TTHueEventStreamLightsUpdatedNotification;
extern NSNotificationName const TTHueEventStreamScenesUpdatedNotification;
extern NSNotificationName const TTHueEventStreamRoomsUpdatedNotification;
extern NSNotificationName const TTHueEventStreamGroupsUpdatedNotification;
extern NSNotificationName const TTHueEventStreamConfigUpdatedNotification;
extern NSNotificationName const TTHueEventStreamConnectedNotification;
extern NSNotificationName const TTHueEventStreamDisconnectedNotification;

/// Protocol for receiving SSE event updates
@protocol TTHueEventStreamDelegate <NSObject>
@optional
- (void)eventStreamConnected;
- (void)eventStreamDisconnectedWithError:(nullable NSError *)error;
- (void)eventStreamAuthenticationFailed;
- (void)eventStreamReceivedLightUpdates:(NSArray<TTHueLight *> *)lights;
- (void)eventStreamReceivedSceneUpdates:(NSArray<TTHueScene *> *)scenes;
- (void)eventStreamReceivedRoomUpdates:(NSArray<TTHueRoom *> *)rooms;
@end

@class TTHueAPIClient;

/// Manages a Server-Sent Events connection to the Hue Bridge for real-time updates
@interface TTHueEventStream : NSObject <NSURLSessionDataDelegate, NSURLSessionDelegate>

@property (nonatomic, weak, nullable) id<TTHueEventStreamDelegate> delegate;
@property (nonatomic, readonly) BOOL isConnected;

- (instancetype)initWithBridgeIP:(NSString *)bridgeIP applicationKey:(NSString *)applicationKey;

/// Connect to the SSE event stream
- (void)connect;

/// Disconnect from the SSE event stream
- (void)disconnect;

/// Reconnect to the event stream
- (void)reconnect;

@end

NS_ASSUME_NONNULL_END
