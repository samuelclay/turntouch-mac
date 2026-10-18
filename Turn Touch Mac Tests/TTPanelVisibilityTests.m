#import <Cocoa/Cocoa.h>
@class TTAppDelegate;
#import "TTPanelController.h"
#import "TTBackgroundView.h"
#import "TTHomeAssistantClient.h"

// Exercise the controller's focus decisions without switching desktop apps or
// loading Bluetooth, Keychain, or the configuration editor.
NSString *const TTHAKeychainInteractionChanged = @"test-keychain-interaction";
@implementation TTHomeAssistantClient
+ (BOOL)isAwaitingKeychainAuthorization { return NO; }
@end
@implementation TTBackgroundView
@end
@interface PanelTestApplication : NSApplication
@end
@implementation PanelTestApplication
- (BOOL)isActive { return NO; }
@end
@interface PanelTestWindow : NSPanel
@property BOOL testKey;
@end
@implementation PanelTestWindow
- (BOOL)isKeyWindow { return self.testKey; }
- (BOOL)isVisible { return YES; }
@end
@interface PanelTestController : TTPanelController
- (void)updatePanelHidingPolicy;
@end
@implementation PanelTestController
- (void)openPanel {} // No editor or on-screen test window needed.
@end
static void Check(BOOL value, const char *message) {
    if (!value) { fprintf(stderr, "FAIL: %s\n", message); exit(1); }
}
int main(void) { @autoreleasepool {
    [PanelTestApplication sharedApplication];
    PanelTestWindow *window = [[PanelTestWindow alloc]
        initWithContentRect:NSMakeRect(0, 0, 380, 500)
        styleMask:NSWindowStyleMaskNonactivatingPanel
        backing:NSBackingStoreBuffered defer:YES];
    PanelTestController *controller = [[PanelTestController alloc] initWithWindow:window];
    [controller updatePanelHidingPolicy];
    Check(!window.hidesOnDeactivate, "AppKit must not hide a nonactivating panel independently of its controller");
    window.testKey = YES;
    controller.hasActivePanel = YES;
    [controller dismissIfInactive];
    Check(controller.hasActivePanel, "a key nonactivating panel stays open while another app is active");
    window.testKey = NO;
    [controller windowDidResignKey:[NSNotification notificationWithName:NSWindowDidResignKeyNotification object:window]];
    Check(!controller.hasActivePanel, "clicking away dismisses an unprotected panel");
    controller.preventClosing = YES;
    controller.hasActivePanel = YES;
    [controller dismissIfInactive];
    Check(controller.hasActivePanel, "an authorization interaction remains protected after losing focus");
    controller.preventClosing = NO;
    Check(!window.hidesOnDeactivate, "ending protection does not reenable AppKit's conflicting auto-hide");
    [controller dismissIfInactive];
    Check(!controller.hasActivePanel, "an inactive, non-key panel dismisses once protection ends");
    puts("PASS: panel focus, click-away, and protected-interaction checks");
    return 0;
} }
