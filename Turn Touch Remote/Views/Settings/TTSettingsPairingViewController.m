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
    [appDelegate.bluetoothMonitor scanUnknown];
}

- (void)viewWillDisappear {
//    [appDelegate.bluetoothMonitor stopScan];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDevicesCount"
                                      options:0 context:nil];
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDevicesConnected"
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
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(unpairedDevicesConnected))]) {
        [self countUnpairedDevices];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(pairedDevicesCount))]) {
        [self countUnpairedDevices];
    }
}

- (void)dealloc {
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDevicesCount"];
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDevicesConnected"];
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
    BOOL connected = !![appDelegate.bluetoothMonitor.unpairedDevicesConnected integerValue];
    
//    NSLog(@"Counting unpaired devices: %d-%d", found, connected);
    if (!found) {
        [titleBox setHidden:YES];
        [labelPressButtons setHidden:YES];
        [countdownIndicator setHidden:YES];
        [diamondView setHidden:YES];
        
        [spinnerScanning setHidden:NO];
        [labelScanning setHidden:NO];
        [spinnerScanning startAnimation:nil];
        
        [labelScanning setStringValue:@"Scanning for remotes..."];

        if (countdownTimer) {
            [countdownTimer invalidate];
            countdownTimer = nil;
        }
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
        [countdownIndicator setDoubleValue:0];
        [self updateCountdown];
        [diamondView setHidden:NO];

        diamondView = [[TTDiamondView alloc] initWithFrame:diamondViewPlaceholder.bounds
                                               diamondType:DIAMOND_TYPE_PAIRING];
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

#pragma mark - Countdown timer

- (void)updateCountdown {
    double minusOneSecond = countdownIndicator.doubleValue + countdownIndicator.maxValue/60;
    [countdownIndicator setDoubleValue:minusOneSecond];

//    NSLog(@"Countdown: %f", minusOneSecond);
    if (minusOneSecond >= countdownIndicator.maxValue) {
        [appDelegate.bluetoothMonitor disconnectUnpairedDevices];
        [appDelegate showPreferences:@"devices"];
        [countdownTimer invalidate];
        countdownTimer = nil;
    } else {
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        if (countdownTimer) [countdownTimer invalidate];
        countdownTimer = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:1.f]
                                                  interval:0.f
                                                    target:self
                                                  selector:@selector(updateCountdown)
                                                  userInfo:nil repeats:NO];
        [runner addTimer:countdownTimer forMode:NSDefaultRunLoopMode];
    }
}

@end
