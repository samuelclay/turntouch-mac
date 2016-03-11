//
//  TTPairingViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/14/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTSettingsPairingViewController.h"
#import "TTDiamondView.h"

@interface TTSettingsPairingViewController ()

@end

@implementation TTSettingsPairingViewController

@synthesize titleBox;
@synthesize labelPressButtons;
@synthesize countdownIndicator;
@synthesize diamondViewPlaceholder;
@synthesize diamondView;
@synthesize spinnerScanning;
@synthesize labelScanning;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"TTSettingsPairingViewController" bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
}

- (void)viewWillDisappear {
//    [appDelegate.bluetoothMonitor stopScan];
}

#pragma mark - RHPreferencesViewControllerProtocol

- (NSString*)identifier {
    return NSStringFromClass(self.class);
}
- (NSImage*)toolbarItemImage {
    return [NSImage imageNamed:@"television"];
}
- (NSString*)toolbarItemLabel {
    return @"Add Remote";
}

- (NSView*)initialKeyView {
    return nil;
}

@end
