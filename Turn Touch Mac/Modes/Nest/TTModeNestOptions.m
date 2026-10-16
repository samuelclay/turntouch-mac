#import "TTModeNestOptions.h"
@implementation TTModeNestOptions
- (void)loadView {
    [super loadView];
    for (NSView *view in self.view.subviews) {
        if ([view isKindOfClass:NSTextField.class]) {
            ((NSTextField *)view).stringValue = @"Google retired Works with Nest. Connect your Nest devices through Home Assistant, then assign actions again.";
        }
    }
}
@end
