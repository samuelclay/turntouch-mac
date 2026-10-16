#import <Cocoa/Cocoa.h>

@interface TTSettingsPopoverController : NSViewController
@property (nonatomic, copy) void (^dismissHandler)(void);
@end
