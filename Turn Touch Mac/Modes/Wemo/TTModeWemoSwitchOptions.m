//
//  TTModeWemoSwitchOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemoSwitchOptions.h"
#import "TTModeWemoSwitchDevice.h"
#import "TTModeWemo.h"

@interface TTModeWemoSwitchOptions ()

@end

@implementation TTModeWemoSwitchOptions

@synthesize devicePopup;
@synthesize refreshButton;
@synthesize spinner;
@synthesize devicesStack;
@synthesize noticeLabel;
@synthesize tableHeightConstraint;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modeWemo = ((TTModeWemo *)self.mode);
    [self.modeWemo setDelegate:self];

    spinner.hidden = YES;
    refreshButton.hidden = NO;
    [refreshButton setImage:[NSImage imageNamed:@"settings"]];
    
    [self selectDevices];
}

- (void)redrawTable {
    for (NSView *deviceRow in devicesStack.views) {
        [devicesStack removeView:deviceRow];
    }
    
    for (TTModeWemoDevice *device in TTModeWemo.foundDevices) {
        TTModeWemoSwitchDevice *deviceRow = [[TTModeWemoSwitchDevice alloc] initWithDevice:device];
        deviceRow.delegate = self;
        [devicesStack addView:deviceRow inGravity:NSStackViewGravityTop];
        [deviceRow redraw];
    }
    
    [devicesStack setNeedsDisplay:YES];
}

#pragma mark - Wemo Delegate

- (void)changeState:(TTWemoState)wemoState withMode:(TTModeWemo *)modeWemo {
    NSLog(@" Changing Wemo state: %lu", wemoState);
    
    if (wemoState == WEMO_STATE_CONNECTED) {
        spinner.hidden = YES;
        refreshButton.hidden = NO;
    }
    
    [self selectDevices];
}

- (void)selectDevices {
    [self.modeWemo ensureDevicesSelected];
    
    if (TTModeWemo.foundDevices.count == 0) {
        if (TTModeWemo.wemoState == WEMO_STATE_CONNECTING) {
            [self.noticeLabel setStringValue:@"Searching for Wemo devices..."];
            [self.noticeLabel setTextColor:[NSColor darkGrayColor]];
            spinner.hidden = NO;
            refreshButton.hidden = YES;
        } else {
            [self.noticeLabel setStringValue:@"No Wemo devices found"];
            [self.noticeLabel setTextColor:[NSColor lightGrayColor]];
            spinner.hidden = YES;
            refreshButton.hidden = NO;
        }
        self.noticeLabel.hidden = NO;
    } else {
        self.noticeLabel.hidden = YES;
        self.refreshButton.hidden = NO;
    }
    
    [self redrawTable];
}

- (IBAction)refreshDevices:(id)sender {
    spinner.hidden = NO;
    [spinner startAnimation:nil];
    refreshButton.hidden = YES;
    
    [self.modeWemo refreshDevices];
}

#pragma mark - Table View delegate and data source

- (void)toggleDevice:(TTModeWemoDevice *)device {
    NSMutableArray *selectedDevices = [[self.action optionValue:kWemoDeviceLocations] mutableCopy];
    
    if ([selectedDevices containsObject:device.location]) {
        [selectedDevices removeObject:device.location];
    } else {
        [selectedDevices addObject:device.location];
    }
    
    [self.action changeActionOption:kWemoDeviceLocations to:selectedDevices];
}

- (BOOL)isSelected:(TTModeWemoDevice *)device {
    NSArray *selectedDevices = [self.action optionValue:kWemoDeviceLocations];
    return [selectedDevices containsObject:device.location];
}

@end
