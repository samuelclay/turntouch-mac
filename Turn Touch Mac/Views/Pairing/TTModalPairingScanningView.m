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
@property (nonatomic, assign) BOOL observersRegistered;
@property (nonatomic, assign) BOOL hasAppeared;
@property (nonatomic, assign) BOOL isDeallocating;

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
    if (!self.hasAppeared) {
        self.hasAppeared = YES;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.isDeallocating) {
                return;
            }
            [strongSelf checkBluetoothState];
            [strongSelf.appDelegate.bluetoothMonitor disconnectUnpairedDevices];
            [strongSelf.appDelegate.bluetoothMonitor scanUnknown:NO];
            strongSelf.appDelegate.bluetoothMonitor.isPairing = YES;
        });
    }

    [self resetDiamond];
    [self countUnpairedDevices];
}

- (void)viewWillDisappear {
    // Remove KVO observers first to prevent callbacks during teardown
    [self unregisterAsObserver];

    [self.appDelegate.bluetoothMonitor stopScan];
    self.appDelegate.bluetoothMonitor.isPairing = NO;

    // Capture and nil the timer first to avoid race conditions
    NSTimer *timer = _countdownTimer;
    _countdownTimer = nil;
    if (timer && [timer isValid]) {
        [timer invalidate];
    }

    // Also invalidate the searching timer
    NSTimer *searchTimer = _searchingTimer;
    _searchingTimer = nil;
    if (searchTimer && [searchTimer isValid]) {
        [searchTimer invalidate];
    }
}

- (void)checkBluetoothState {
    if ([self.appDelegate.bluetoothMonitor.manager state] != CBCentralManagerStatePoweredOn) {
        [self searchingFailure];
    }    
}

#pragma mark - KVO

- (void)registerAsObserver {
    if (self.observersRegistered) return;

    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDevicesCount"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDevicesConnected"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"pairedDevicesCount"
                                      options:0 context:nil];
    self.observersRegistered = YES;
}

- (void)unregisterAsObserver {
    if (!self.observersRegistered) return;

    @try {
        [self.appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDevicesCount"];
        [self.appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDevicesConnected"];
        [self.appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"pairedDevicesCount"];
    } @catch (NSException *exception) {
        // Observers may already be removed
    }
    self.observersRegistered = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    // Guard against late-arriving KVO callbacks after unregistration or during dealloc
    if (_isDeallocating || !_observersRegistered) {
        return;
    }

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
    // Mark as deallocating immediately to prevent any callbacks
    _isDeallocating = YES;

    // Remove KVO observers first
    [self unregisterAsObserver];

    // Use direct ivar access to avoid any property getter issues during dealloc
    NSTimer *timer = _countdownTimer;
    _countdownTimer = nil;
    if (timer && [timer isValid]) {
        [timer invalidate];
    }

    NSTimer *searchTimer = _searchingTimer;
    _searchingTimer = nil;
    if (searchTimer && [searchTimer isValid]) {
        [searchTimer invalidate];
    }
}

#pragma mark - Drawing

- (void)countUnpairedDevices {
    // Guard against calls during deallocation
    if (_isDeallocating) {
        return;
    }

    BOOL found = !![self.appDelegate.bluetoothMonitor.unpairedDevicesCount integerValue] || self.appDelegate.bluetoothMonitor.bluetoothState == BT_STATE_CONNECTING_UNKNOWN;
    BOOL connected = !![self.appDelegate.bluetoothMonitor.unpairedDevicesConnected integerValue];

    //    NSLog(@"Counting unpaired devices: %d-%d", found, connected);
    if (!found) {
        [self.countdownIndicator setHidden:YES];
        [self.spinnerScanning setHidden:NO];
//        [self.appDelegate.bluetoothMonitor disconnectUnpairedDevices];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];

        // Safely invalidate existing searching timer using direct ivar access
        NSTimer *oldSearchTimer = _searchingTimer;
        _searchingTimer = nil;
        if (oldSearchTimer && [oldSearchTimer isValid]) {
            [oldSearchTimer invalidate];
        }

        _searchingTimer = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:10.f]
                                                  interval:0.f
                                                    target:self
                                                  selector:@selector(searchingFailure)
                                                  userInfo:nil repeats:NO];
        [runner addTimer:_searchingTimer forMode:NSDefaultRunLoopMode];
        [self.spinnerScanning setNeedsDisplay:YES];

        [self.labelScanning setStringValue:@"Scanning for remotes..."];

        // Safely invalidate countdown timer
        NSTimer *oldCountdown = _countdownTimer;
        _countdownTimer = nil;
        if (oldCountdown && [oldCountdown isValid]) {
            [oldCountdown invalidate];
        }
    } else if (found && !connected) {
        [self.countdownIndicator setHidden:YES];
        [self.spinnerScanning setHidden:NO];
        [self.labelScanning setStringValue:@"Connecting..."];

        // Safely invalidate searching timer
        NSTimer *oldSearchTimer = _searchingTimer;
        _searchingTimer = nil;
        if (oldSearchTimer && [oldSearchTimer isValid]) {
            [oldSearchTimer invalidate];
        }
    } else if (found && connected) {
        [self.countdownIndicator setHidden:NO];
        [self.countdownIndicator setDoubleValue:0];
        [self.spinnerScanning setHidden:YES];
        [self.labelScanning setStringValue:@"Press all four buttons to connect"];

        // Safely invalidate searching timer
        NSTimer *oldSearchTimer = _searchingTimer;
        _searchingTimer = nil;
        if (oldSearchTimer && [oldSearchTimer isValid]) {
            [oldSearchTimer invalidate];
        }

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
    // Guard against calls during deallocation
    if (_isDeallocating) {
        return;
    }

    double minusOneSecond = self.countdownIndicator.doubleValue + self.countdownIndicator.maxValue/10;
    [self.countdownIndicator setDoubleValue:minusOneSecond];

    NSLog(@"Countdown: %f >= %f", minusOneSecond, self.countdownIndicator.maxValue);
    if (minusOneSecond >= self.countdownIndicator.maxValue) {
        [self.appDelegate.bluetoothMonitor disconnectUnpairedDevices];
        [self.appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_FAILURE];

        // Safely invalidate countdown timer using direct ivar
        NSTimer *oldTimer = _countdownTimer;
        _countdownTimer = nil;
        if (oldTimer && [oldTimer isValid]) {
            [oldTimer invalidate];
        }
    } else {
        NSRunLoop *runner = [NSRunLoop currentRunLoop];

        // Safely invalidate existing timer before creating new one
        NSTimer *oldTimer = _countdownTimer;
        _countdownTimer = nil;
        if (oldTimer && [oldTimer isValid]) {
            [oldTimer invalidate];
        }

        _countdownTimer = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:1.f]
                                                  interval:0.f
                                                    target:self
                                                  selector:@selector(updateCountdown)
                                                  userInfo:nil repeats:NO];
        [runner addTimer:_countdownTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)searchingFailure {
    // Guard against calls during deallocation
    if (_isDeallocating) {
        return;
    }

    if (self.appDelegate.bluetoothMonitor.bluetoothState == BT_STATE_CONNECTING_UNKNOWN) {
        NSLog(@" ---> Not cancelling unknown search, connecting to unknown...");
        return;
    }

    // Safely invalidate searching timer using direct ivar
    NSTimer *oldTimer = _searchingTimer;
    _searchingTimer = nil;
    if (oldTimer && [oldTimer isValid]) {
        [oldTimer invalidate];
    }

    [self.appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_FAILURE];
}

#pragma mark - Actions

- (void)closeModal:(id)sender {
    [self.appDelegate.bluetoothMonitor disconnectUnpairedDevices];
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

@end
