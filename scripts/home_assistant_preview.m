#import <Cocoa/Cocoa.h>
#import "TTHomeAssistantWindowController.h"
@interface PreviewDelegate : NSObject <NSApplicationDelegate>
@property TTHomeAssistantWindowController *browser;
@end
@implementation PreviewDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.browser = [[TTHomeAssistantWindowController alloc] init];
    [self.browser showWithBinding:nil];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app { return YES; }
@end
int main(void) {
    @autoreleasepool {
        NSApplication *app = NSApplication.sharedApplication;
        PreviewDelegate *delegate = [[PreviewDelegate alloc] init];
        app.delegate = delegate;
        NSMenu *mainMenu = [[NSMenu alloc] init];
        NSMenuItem *appItem = [[NSMenuItem alloc] init];
        NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"Turn Touch Home Assistant"];
        [appMenu addItemWithTitle:@"Quit Turn Touch Home Assistant" action:@selector(terminate:) keyEquivalent:@"q"];
        appItem.submenu = appMenu; [mainMenu addItem:appItem];
        NSMenuItem *editItem = [[NSMenuItem alloc] init];
        NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
        [editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
        [editMenu addItem:[NSMenuItem separatorItem]];
        [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
        [editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
        [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
        [editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
        editItem.submenu = editMenu; [mainMenu addItem:editItem]; app.mainMenu = mainMenu;
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        [app run];
    }
}
