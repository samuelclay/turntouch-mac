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
        
        [self registerAsObserver];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [self countUnpairedDevices];
    [appDelegate.bluetoothMonitor startScan];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDevicesCount"
                                      options:0 context:nil];
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDeviceConnected"
                                      options:0 context:nil];
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"pairedDevicesCount"
                                      options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(unpairedDevicesCount))]) {
        [self countUnpairedDevices];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(unpairedDeviceConnected))]) {
        [self countUnpairedDevices];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(pairedDevicesCount))]) {
        [self countUnpairedDevices];
    }
}

- (void)dealloc {
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDevicesCount"];
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDeviceConnected"];
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"pairedDevicesCount"];
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

#pragma mark - Drawing

- (void)countUnpairedDevices {
    BOOL found = !![appDelegate.bluetoothMonitor.unpairedDevicesCount integerValue];
    BOOL connected = [appDelegate.bluetoothMonitor.unpairedDeviceConnected boolValue];
    
    NSLog(@"Counting unpaired devices: %d-%d", found, connected);
    if (!found) {
        [titleBox setHidden:YES];
        [labelPressButtons setHidden:YES];
        [countdownIndicator setHidden:YES];
        [diamondView setHidden:YES];
        
        [spinnerScanning setHidden:NO];
        [labelScanning setHidden:NO];
        [spinnerScanning startAnimation:nil];
        
        [labelScanning setStringValue:@"Scanning for remotes..."];
    } else if (found && !connected) {
        [titleBox setHidden:NO];
        [labelPressButtons setHidden:YES];
        [countdownIndicator setHidden:YES];
        [diamondView setHidden:YES];
        
        [spinnerScanning setHidden:NO];
        [labelScanning setHidden:NO];
        [spinnerScanning startAnimation:nil];
        [labelScanning setStringValue:@"Connecting..."];
    } else if (found && connected) {
        [titleBox setHidden:NO];
        [labelPressButtons setHidden:NO];
        [countdownIndicator setHidden:NO];
        [diamondView setHidden:NO];

        diamondView = [[TTDiamondView alloc] initWithFrame:diamondViewPlaceholder.bounds pairing:YES];
        [diamondView setIgnoreSelectedMode:YES];
        for (NSView *subview in diamondViewPlaceholder.subviews) {
            [subview removeFromSuperview];
        }
        [diamondViewPlaceholder addSubview:diamondView];

        [spinnerScanning setHidden:YES];
        [labelScanning setHidden:YES];
        [spinnerScanning stopAnimation:nil];
    }
    
}

@end
