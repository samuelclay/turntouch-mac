//
//  TTAppDelegate.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTAppDelegate.h"
#import <dispatch/dispatch.h>

@implementation TTAppDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;
@synthesize bluetoothMonitor = _bluetoothMonitor;
@synthesize hudController = _hudController;

#pragma mark - Dealloc

- (void)dealloc {
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    // Install icon into the menu bar
    self.modeMap = [[TTModeMap alloc] init];
    self.menubarController = [[TTMenubarController alloc] init];
    self.bluetoothMonitor = [[TTBluetoothMonitor alloc] init];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.bluetoothMonitor terminate];
}


#pragma mark - Actions

- (IBAction)togglePanel:(id)sender {
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (TTPanelController *)panelController {
    if (_panelController == nil) {
        _panelController = [[TTPanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

- (TTHUDController *)hudController {
    if (_hudController == nil) {
        _hudController = [[TTHUDController alloc] init];
    }
    return _hudController;
}

#pragma mark - TTPanelControllerDelegate

- (TTStatusItemView *)statusItemViewForPanelController:(TTPanelController *)controller {
    return self.menubarController.statusItemView;
}


@end
