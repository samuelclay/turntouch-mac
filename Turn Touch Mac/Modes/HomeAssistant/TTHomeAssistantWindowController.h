#import <Cocoa/Cocoa.h>

// The browser is independent of TTMode so it can also run in the native UI harness.
@interface TTHomeAssistantWindowController : NSWindowController
@property (nonatomic, copy) void (^saveHandler)(NSDictionary *binding);
- (void)showWithBinding:(NSDictionary *)binding;
@end
