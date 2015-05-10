//
//  TTPairingViewController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/14/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RHPreferences.h"
#import "TTAppDelegate.h"

@interface TTSettingsPairingViewController : NSViewController
<RHPreferencesViewControllerProtocol> {
    TTAppDelegate *appDelegate;
    NSTimer *countdownTimer;
}

@property (nonatomic) IBOutlet NSBox *titleBox;
@property (nonatomic) IBOutlet NSTextField *labelPressButtons;
@property (nonatomic) IBOutlet NSProgressIndicator *countdownIndicator;
@property (nonatomic) IBOutlet NSView *diamondViewPlaceholder;
@property (nonatomic) IBOutlet TTDiamondView *diamondView;
@property (nonatomic) IBOutlet NSProgressIndicator *spinnerScanning;
@property (nonatomic) IBOutlet NSTextField *labelScanning;

@end
