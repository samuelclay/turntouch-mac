//
//  TTModalPairingScanningView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModalPairingScanningView.h"
#import "TTDiamondView.h"

@implementation TTModalPairingScanningView

@synthesize titleBox;
@synthesize countdownIndicator;
@synthesize diamondViewPlaceholder;
@synthesize diamondView;
@synthesize spinnerScanning;
@synthesize labelScanning;
@synthesize closeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"TTModalPairingScanningView" bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        [self registerAsObserver];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear {
    static dispatch_once_t onceUnknownToken;
    dispatch_once(&onceUnknownToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            onceUnknownToken = 0;
            [self checkBluetoothState];
            [appDelegate.bluetoothMonitor disconnectUnpairedDevices];
            [appDelegate.bluetoothMonitor scanUnknown:NO];
            appDelegate.bluetoothMonitor.isPairing = YES;
        });
    });

    [self resetDiamond];
    [self countUnpairedDevices];
}

- (void)viewWillDisappear {
    [appDelegate.bluetoothMonitor stopScan];
    appDelegate.bluetoothMonitor.isPairing = NO;
    
    if (countdownTimer) {
        [countdownTimer invalidate];
        countdownTimer = nil;
    }
}

- (void)checkBluetoothState {
    if ([appDelegate.bluetoothMonitor.manager state] != CBCentralManagerStatePoweredOn) {
        [self searchingFailure];
    }    
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
    [self checkBluetoothState];
}

- (void)dealloc {
    if (countdownTimer) {
        [countdownTimer invalidate];
        countdownTimer = nil;
    }
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDevicesCount"];
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDevicesConnected"];
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"pairedDevicesCount"];
}

#pragma mark - Drawing

- (void)countUnpairedDevices {
    BOOL found = !![appDelegate.bluetoothMonitor.unpairedDevicesCount integerValue] || appDelegate.bluetoothMonitor.bluetoothState == BT_STATE_CONNECTING_UNKNOWN;
    BOOL connected = !![appDelegate.bluetoothMonitor.unpairedDevicesConnected integerValue];
    
    //    NSLog(@"Counting unpaired devices: %d-%d", found, connected);
    if (!found) {
        [countdownIndicator setHidden:YES];
        [spinnerScanning setHidden:NO];
//        [appDelegate.bluetoothMonitor disconnectUnpairedDevices];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        if (searchingTimer) [searchingTimer invalidate];
        searchingTimer = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:10.f]
                                                  interval:0.f
                                                    target:self
                                                  selector:@selector(searchingFailure)
                                                  userInfo:nil repeats:NO];
        [runner addTimer:searchingTimer forMode:NSDefaultRunLoopMode];
        [spinnerScanning setNeedsDisplay:YES];
        
        [labelScanning setStringValue:@"Scanning for remotes..."];
        
        if (countdownTimer) {
            [countdownTimer invalidate];
            countdownTimer = nil;
        }
    } else if (found && !connected) {
        [countdownIndicator setHidden:YES];
        [spinnerScanning setHidden:NO];
        [labelScanning setStringValue:@"Connecting..."];
        [searchingTimer invalidate];
    } else if (found && connected) {
        [countdownIndicator setHidden:NO];
        [countdownIndicator setDoubleValue:0];
        [spinnerScanning setHidden:YES];
        [labelScanning setStringValue:@"Press all four buttons to connect"];
        [searchingTimer invalidate];
        [self resetDiamond];
        [self updateCountdown];
    }
    
}

- (void)resetDiamond {
    diamondView = [[TTDiamondView alloc] initWithFrame:diamondViewPlaceholder.bounds
                                           diamondType:DIAMOND_TYPE_PAIRING];
    [diamondView setIgnoreSelectedMode:YES];
    for (NSView *subview in diamondViewPlaceholder.subviews) {
        [subview removeFromSuperview];
    }
    [diamondViewPlaceholder addSubview:diamondView];
}

#pragma mark - Countdown timer

- (void)updateCountdown {
    double minusOneSecond = countdownIndicator.doubleValue + countdownIndicator.maxValue/10;
    [countdownIndicator setDoubleValue:minusOneSecond];
    
    NSLog(@"Countdown: %f >= %f", minusOneSecond, countdownIndicator.maxValue);
    if (minusOneSecond >= countdownIndicator.maxValue) {
        [appDelegate.bluetoothMonitor disconnectUnpairedDevices];
        [appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_FAILURE];
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

- (void)searchingFailure {
    if (appDelegate.bluetoothMonitor.bluetoothState == BT_STATE_CONNECTING_UNKNOWN) {
        NSLog(@" ---> Not cancelling unknown search, connecting to unknown...");
        return;
    }
    [searchingTimer invalidate];
    [appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_FAILURE];
}

#pragma mark - Actions

- (void)closeModal:(id)sender {
    [appDelegate.bluetoothMonitor disconnectUnpairedDevices];
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

@end
