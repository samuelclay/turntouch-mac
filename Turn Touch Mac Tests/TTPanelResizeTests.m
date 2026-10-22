#import <Cocoa/Cocoa.h>
@class TTAppDelegate;
#import "TTPanel.h"
#import "TTPanelController.h"
#include <assert.h>

// Use the real panel resize implementation without Bluetooth or an editor.
@implementation TTPanelController
- (NSScreen *)screenForPanel { return NSScreen.mainScreen; }
- (NSRect)statusRectForWindow:(NSWindow *)window {
    NSRect visible = self.screenForPanel.visibleFrame;
    return NSMakeRect(NSMidX(visible), NSMaxY(visible), 22, 22);
}
@end

@interface ResizeTestPanel : TTPanel
@property BOOL testVisible;
@end
@implementation ResizeTestPanel
- (BOOL)isVisible { return self.testVisible; }
@end

int main(void) { @autoreleasepool {
    [NSApplication sharedApplication];
    ResizeTestPanel *panel = [[ResizeTestPanel alloc]
        initWithContentRect:NSMakeRect(0, 0, 380, 500)
        styleMask:NSWindowStyleMaskBorderless
        backing:NSBackingStoreBuffered defer:YES];
    TTPanelController *controller = [[TTPanelController alloc] initWithWindow:panel];
    panel.testVisible = YES;
    CGFloat top = NSMinY([controller statusRectForWindow:panel]) - 2;
    [panel setFrame:NSMakeRect(0, top - 500, 380, 500) display:NO];
    assert(NSMaxY(panel.frame) == top);

    // Cancel can shift the origin even when the final height is unchanged.
    NSRect shifted = panel.frame;
    shifted.origin.y += 145;
    [panel setFrame:shifted display:NO];
    assert(NSMaxY(panel.frame) == top);
    assert(NSHeight(panel.frame) == 500);

    // Growing and shrinking the editor must preserve the same menu-bar anchor.
    for (NSNumber *height in @[@650, @355, @500]) {
        shifted.size.height = height.doubleValue;
        [panel setFrame:shifted display:NO animate:NO];
        assert(NSMaxY(panel.frame) == top);
        assert(NSHeight(panel.frame) == height.doubleValue);
    }
    puts("PASS: automatic panel resize stays below its status item, including unchanged-height Cancel");
} }
