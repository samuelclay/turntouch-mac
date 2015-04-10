//
//  TTSettingsDevicesViewController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RHPreferences.h"
#import "TTAppDelegate.h"

@interface TTSettingsDevicesViewController : NSViewController
<RHPreferencesViewControllerProtocol, NSTableViewDataSource, NSTableViewDelegate> {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) IBOutlet NSTableView *devicesTable;
@property (nonatomic) IBOutlet NSSlider *latencySlider;
@property (nonatomic) IBOutlet NSSlider *modeChangeSlider;

- (IBAction)slideLatency:(id)sender;
- (IBAction)slideModeChange:(id)sender;

@end
