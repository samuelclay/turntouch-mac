#import <Cocoa/Cocoa.h>

/// Embedded catalog/action editor, independent of TTMode for protocol/UI testing.
@interface TTHomeAssistantViewController : NSViewController
@property (nonatomic, copy) void (^saveHandler)(NSDictionary *binding);
@property (nonatomic, copy) void (^interactionHandler)(BOOL active);
- (void)loadBinding:(NSDictionary *)binding;
@end
