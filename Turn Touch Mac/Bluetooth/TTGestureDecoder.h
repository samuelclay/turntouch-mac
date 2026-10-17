#import <Foundation/Foundation.h>
#import "TTModeDirection.h"

/// One decoder per remote. Times are monotonic seconds; tick after the tap deadline.
@interface TTGestureDecoder : NSObject
@property (nonatomic, copy) void (^onGesture)(TTModeDirection direction, TTModeDirection gesture);
@property (nonatomic, readonly) TTModeDirection pressedDirection;
@property (nonatomic, readonly) NSTimeInterval nextDeadline;
- (void)readData:(NSData *)data atTime:(NSTimeInterval)now;
- (void)flushAtTime:(NSTimeInterval)now;
- (void)reset;
@end
