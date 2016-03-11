//
//  TTModalPairingScanningView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
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
        spinnerBeginTime = CACurrentMediaTime();
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
            [appDelegate.bluetoothMonitor scanUnknown];
        });
    });

    [self resetDiamond];
    [self countUnpairedDevices];
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

#pragma mark - Drawing

- (void)countUnpairedDevices {
    BOOL found = !![appDelegate.bluetoothMonitor.unpairedDevicesCount integerValue];
    BOOL connected = !![appDelegate.bluetoothMonitor.unpairedDevicesConnected integerValue];
    
    //    NSLog(@"Counting unpaired devices: %d-%d", found, connected);
    if (!found) {
        [countdownIndicator setHidden:YES];
        [spinnerScanning setHidden:NO];
        
        for (CALayer *layer in [spinnerScanning.layer.sublayers copy]) {
            [layer removeFromSuperlayer];
        }

        for (NSInteger i=0; i < 2; i+=1) {
            CALayer *circle = [CALayer layer];
            circle.frame = CGRectMake(0, 0, NSWidth(spinnerScanning.frame), NSHeight(spinnerScanning.frame));
            circle.backgroundColor = NSColorFromRGB(0x0000FF).CGColor;
            circle.anchorPoint = CGPointMake(0.5, 0.5);
            circle.opacity = 0.6;
            circle.cornerRadius = CGRectGetHeight(circle.bounds) * 0.5;
            circle.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
            
            CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            anim.removedOnCompletion = NO;
            anim.repeatCount = HUGE_VALF;
            anim.duration = 2.0;
            anim.beginTime = spinnerBeginTime - (1.0 * i);
            anim.keyTimes = @[@(0.0), @(0.5), @(1.0)];
            
            anim.timingFunctions = @[
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                     ];
            
            anim.values = @[
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 0.0)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)]
                            ];
            
            [spinnerScanning.layer addSublayer:circle];
            [circle addAnimation:anim forKey:@"transform"];
        }
        [labelScanning setStringValue:@"Scanning for remotes..."];
        
        if (countdownTimer) {
            [countdownTimer invalidate];
            countdownTimer = nil;
        }
    } else if (found && !connected) {
        [countdownIndicator setHidden:YES];
        [spinnerScanning setHidden:NO];
        [labelScanning setStringValue:@"Connecting..."];
    } else if (found && connected) {
        [countdownIndicator setHidden:NO];
        [countdownIndicator setDoubleValue:0];
        [spinnerScanning setHidden:YES];
        [labelScanning setStringValue:@"Press all four buttons to connect"];
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
    double minusOneSecond = countdownIndicator.doubleValue + countdownIndicator.maxValue/60;
    [countdownIndicator setDoubleValue:minusOneSecond];
    
//    NSLog(@"Countdown: %f >= %f", minusOneSecond, countdownIndicator.maxValue);
    if (minusOneSecond >= countdownIndicator.maxValue) {
        [appDelegate.bluetoothMonitor disconnectUnpairedDevices];
        [appDelegate showPreferences:@"devices" onlyIfVisible:YES];
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

#pragma mark - Actions

- (void)closeModal:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

@end
