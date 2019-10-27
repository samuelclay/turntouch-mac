//
//  TTModalPairingScanningView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModalPairingScanningView.h"
#import "TTDiamondView.h"

@interface TTModalPairingScanningView ()

@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, strong) NSTimer *searchingTimer;

@end

@implementation TTModalPairingScanningView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"TTModalPairingScanningView" bundle:nibBundleOrNil];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
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
            [self.appDelegate.bluetoothMonitor disconnectUnpairedDevices];
            [self.appDelegate.bluetoothMonitor scanUnknown:NO];
            self.appDelegate.bluetoothMonitor.isPairing = YES;
        });
    });

    [self resetDiamond];
    [self countUnpairedDevices];
}

- (void)viewWillDisappear {
    [self.appDelegate.bluetoothMonitor stopScan];
    self.appDelegate.bluetoothMonitor.isPairing = NO;
    
    if (self.countdownTimer) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
}

- (void)checkBluetoothState {
    if ([self.appDelegate.bluetoothMonitor.manager state] != CBCentralManagerStatePoweredOn) {
        [self searchingFailure];
    }    
}

#pragma mark - KVO

- (void)registerAsObserver {
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDevicesCount"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDevicesConnected"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
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
    if (self.countdownTimer) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
    [self.appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDevicesCount"];
    [self.appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDevicesConnected"];
    [self.appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"pairedDevicesCount"];
}

#pragma mark - Drawing

- (void)countUnpairedDevices {
    BOOL found = !![self.appDelegate.bluetoothMonitor.unpairedDevicesCount integerValue] || self.appDelegate.bluetoothMonitor.bluetoothState == BT_STATE_CONNECTING_UNKNOWN;
    BOOL connected = !![self.appDelegate.bluetoothMonitor.unpairedDevicesConnected integerValue];
    
    //    NSLog(@"Counting unpaired devices: %d-%d", found, connected);
    if (!found) {
        [self.countdownIndicator setHidden:YES];
        [self.spinnerScanning setHidden:NO];
//        [self.appDelegate.bluetoothMonitor disconnectUnpairedDevices];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        if (self.searchingTimer) [self.searchingTimer invalidate];
        self.searchingTimer = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:10.f]
                                                  interval:0.f
                                                    target:self
                                                  selector:@selector(searchingFailure)
                                                  userInfo:nil repeats:NO];
        [runner addTimer:self.searchingTimer forMode:NSDefaultRunLoopMode];
        [self.spinnerScanning setNeedsDisplay:YES];
        
        [self.labelScanning setStringValue:@"Scanning for remotes..."];
        
        if (self.countdownTimer) {
            [self.countdownTimer invalidate];
            self.countdownTimer = nil;
        }
    } else if (found && !connected) {
        [self.countdownIndicator setHidden:YES];
        [self.spinnerScanning setHidden:NO];
        [self.labelScanning setStringValue:@"Connecting..."];
        [self.searchingTimer invalidate];
    } else if (found && connected) {
        [self.countdownIndicator setHidden:NO];
        [self.countdownIndicator setDoubleValue:0];
        [self.spinnerScanning setHidden:YES];
        [self.labelScanning setStringValue:@"Press all four buttons to connect"];
        [self.searchingTimer invalidate];
        [self resetDiamond];
        [self updateCountdown];
    }
    
}

- (void)resetDiamond {
    self.diamondView = [[TTDiamondView alloc] initWithFrame:self.diamondViewPlaceholder.bounds
                                           diamondType:DIAMOND_TYPE_PAIRING];
    [self.diamondView setIgnoreSelectedMode:YES];
    for (NSView *subview in self.diamondViewPlaceholder.subviews) {
        [subview removeFromSuperview];
    }
    [self.diamondViewPlaceholder addSubview:self.diamondView];
}

#pragma mark - Countdown timer

- (void)updateCountdown {
    double minusOneSecond = self.countdownIndicator.doubleValue + self.countdownIndicator.maxValue/10;
    [self.countdownIndicator setDoubleValue:minusOneSecond];
    
    NSLog(@"Countdown: %f >= %f", minusOneSecond, self.countdownIndicator.maxValue);
    if (minusOneSecond >= self.countdownIndicator.maxValue) {
        [self.appDelegate.bluetoothMonitor disconnectUnpairedDevices];
        [self.appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_FAILURE];
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    } else {
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        if (self.countdownTimer) [self.countdownTimer invalidate];
        self.countdownTimer = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:1.f]
                                                  interval:0.f
                                                    target:self
                                                  selector:@selector(updateCountdown)
                                                  userInfo:nil repeats:NO];
        [runner addTimer:self.countdownTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)searchingFailure {
    if (self.appDelegate.bluetoothMonitor.bluetoothState == BT_STATE_CONNECTING_UNKNOWN) {
        NSLog(@" ---> Not cancelling unknown search, connecting to unknown...");
        return;
    }
    [self.searchingTimer invalidate];
    [self.appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_FAILURE];
}

#pragma mark - Actions

- (void)closeModal:(id)sender {
    [self.appDelegate.bluetoothMonitor disconnectUnpairedDevices];
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

@end
