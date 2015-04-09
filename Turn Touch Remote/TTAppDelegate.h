//
//  TTAppDelegate.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeDirection.h"
#import "TTMenubarController.h"
#import "TTPanelDelegate.h"
#import "TTPanelController.h"
#import "TTBluetoothMonitor.h"
#import "TTModeMap.h"
#import "TTHUDController.h"
#import "Vendor/RHPreferences/RHPreferences.h"

#define NSAppDelegate  ((TTAppDelegate *)[[NSApplication sharedApplication] delegate])

@class TTModeMap;
@class TTPanelController;
@class TTHUDController;
@class TTBluetoothMonitor;

#define OPEN_DURATION 0.42f

@interface TTAppDelegate : NSObject
<NSApplicationDelegate, TTPanelControllerDelegate>

@property (nonatomic, strong) TTMenubarController *menubarController;
@property (nonatomic, strong, readonly) TTPanelController *panelController;
@property (nonatomic) TTBluetoothMonitor *bluetoothMonitor;
@property (nonatomic) TTModeMap *modeMap;
@property (nonatomic) TTHUDController *hudController;
@property (retain) RHPreferencesWindowController *preferencesWindowController;

- (IBAction)togglePanel:(id)sender;

@end
