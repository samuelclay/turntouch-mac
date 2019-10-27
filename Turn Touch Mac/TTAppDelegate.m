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
#import "PFMoveApplication.h"
#import <ApplicationServices/ApplicationServices.h>

@interface TTAppDelegate ()

@property (nonatomic, strong, readwrite) TTPanelController *panelController;

@end

@implementation TTAppDelegate

#pragma mark - Dealloc

- (void)dealloc {
    [self.panelController removeObserver:self forKeyPath:@"hasActivePanel"];
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
    
    [self checkAlreadyRunning];
    
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
        
        [self.modeMap recordUsageMoment:@"launch"];
    });
    
    // Useful for debugging:
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self openPanel];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.panelController.backgroundView switchPanelModal:PANEL_MODAL_SUPPORT];
//        });
    });
//    [self.panelController closePanel];
//    [self.hudController toastActiveMode];
//    [self.hudController toastActiveAction:nil inDirection:SOUTH];
//    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @NO};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    if (!accessibilityEnabled) {
        NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility";
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
    }
    NSLog(@" ---> Trusted in accessibility: %d", accessibilityEnabled);
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    PFMoveToApplicationsFolderIfNecessary();
    
    [[NSAppleEventManager sharedAppleEventManager]
     setEventHandler:self
     andSelector:@selector(handleURLEvent:withReplyEvent:)
     forEventClass:kInternetEventClass
     andEventID:kAEGetURL];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.bluetoothMonitor terminate];
}

- (void)checkAlreadyRunning {
    BOOL seen = false;
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in apps) {
        if ([[app bundleIdentifier] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
            if (!seen) {
                seen = YES;
                continue;
            }
            
            NSLog(@" ---> Instance of Turn Touch already running, exiting...");
            
            [NSApp terminate:self];
        }
    }
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event
        withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject]
                     stringValue];
    NSLog(@" ---> URL: %@", url);
    if ([url hasPrefix:@"turntouch"]) {
        NSURL *ttUrl = [[NSURL alloc] initWithString:url];
        NSDictionary* parameters = [self parseQueryString:[ttUrl query]];
        NSString* articleId = [parameters valueForKey:@"id"];
        if (articleId != nil) {
            NSLog(@" --- > IFTTT id: %@", articleId);
        }
        return;
    }
    return;
}

- (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
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
    [self.bluetoothMonitor stopScan];
    [self.bluetoothMonitor terminate];
}

- (void) receiveWakeNote: (NSNotification*) note {
    NSLog(@"receiveWakeNote: %@", [note name]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.bluetoothMonitor reconnect:YES];
    });
}

- (void)receiveSysTimeChangedNotification:(NSNotification *)notification {
    NSLog(@" ---> New time zone! Receiving notification: %@", notification);
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSysTimeChangedNotification:)
                                                 name:NSCurrentLocaleDidChangeNotification
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
