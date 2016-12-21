//
//  TTAppDelegate.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTAppDelegate.h"
#import <dispatch/dispatch.h>
#import "LaunchAtLoginController.h"

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
    
//    [self erasePreferences];
    [self loadPreferences];
    
    // Install icon into the menu bar
    self.bluetoothMonitor = [[TTBluetoothMonitor alloc] init];
    self.modeMap = [[TTModeMap alloc] init];
    self.menubarController = [[TTMenubarController alloc] init];
    
    [self.modeMap switchMode];
    [self.modeMap activateTimers];
    [self observeSleepNotifications];
    
    self.menubarController.hasActiveIcon = NO;
    self.panelController.hasActivePanel = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
        [launchController setLaunchAtLogin:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.bluetoothMonitor noKnownDevices]) {
            [self.panelController openModal:MODAL_PAIRING_INTRO];
        }
    });
    
    // Useful for debugging:
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openPanel];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.panelController.backgroundView switchPanelModal:PANEL_MODAL_SUPPORT];
//        });
    });
//    [self.panelController closePanel];
//    [self.hudController toastActiveMode];
//    [self.hudController toastActiveAction:nil inDirection:SOUTH];
//    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
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

- (void)openPanel {
    if (!self.panelController.hasActivePanel) {
        self.menubarController.hasActiveIcon = YES;
        self.panelController.hasActivePanel = YES;
    }
}
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

#pragma mark - Sleep

- (void) receiveSleepNote: (NSNotification*) note {
    NSLog(@"receiveSleepNote: %@", [note name]);
    [_bluetoothMonitor stopScan];
    [_bluetoothMonitor terminate];
}

- (void) receiveWakeNote: (NSNotification*) note {
    NSLog(@"receiveWakeNote: %@", [note name]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_bluetoothMonitor reconnect:YES];
    });
}

- (void)receiveSysTimeChangedNotification:(NSNotification *)notification {
    [self.modeMap activateTimers];
}

- (void) observeSleepNotifications {
    //These notifications are filed on NSWorkspace's notification center, not the default
    // notification center. You will not receive sleep/wake notifications if you file
    //with the default notification center.
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNote:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSysTimeChangedNotification:)
                                                 name:NSSystemClockDidChangeNotification
                                               object:nil];
}

#pragma mark - Preferences

- (void)loadPreferences {
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
}

- (void)erasePreferences {
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[NSBundle mainBundle].bundleIdentifier];
}

@end
