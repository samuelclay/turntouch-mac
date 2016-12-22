//
//  TTModeWemoSwitchOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemoSwitchOptions.h"
#import "TTModeWemo.h"

@interface TTModeWemoSwitchOptions ()

@end

@implementation TTModeWemoSwitchOptions

@synthesize devicePopup;
@synthesize refreshButton;
@synthesize spinner;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modeWemo = ((TTModeWemo *)self.mode);
    [self.modeWemo setDelegate:self];

    spinner.hidden = YES;
    refreshButton.hidden = NO;
    
    [self selectDevice];
    [self changeState:TTModeWemo.wemoState withMode:self.modeWemo];
}

- (void)selectDevice {
    NSString *deviceSelectedIdentifier = [self.action optionValue:kWemoDeviceLocation
                                                      inDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *deviceSelected;
    NSMutableArray *devices = [NSMutableArray array];
    [devicePopup removeAllItems];

    for (TTModeWemoDevice *device in TTModeWemo.foundDevices) {
        if (!device.deviceName || !device.location) continue;
        [devices addObject:@{@"name": device.deviceName, @"identifier": device.location}];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [devices sortUsingDescriptors:@[sd]];
    
    for (NSDictionary *deviceData in devices) {
        [devicePopup addItemWithTitle:deviceData[@"name"]];
        if ([deviceData[@"identifier"] isEqualToString:deviceSelectedIdentifier]) {
            deviceSelected = deviceData[@"name"];
        }
    }
    if (deviceSelected) {
        [devicePopup selectItemWithTitle:deviceSelected];
    } else if (devicePopup.numberOfItems) {
        [self didChangeDevice:nil];
    }
}

- (void)didChangeDevice:(id)sender {
    NSMenuItem *menuItem = [devicePopup selectedItem];
    NSString *deviceIdentifier;
    
    for (TTModeWemoDevice *device in TTModeWemo.foundDevices) {
        if ([device.deviceName isEqualToString:menuItem.title]) {
            deviceIdentifier = device.location;
            break;
        }
    }
    
    [self.action changeActionOption:kWemoDeviceLocation to:deviceIdentifier];
}

- (IBAction)refreshDevices:(id)sender {
    spinner.hidden = NO;
    [spinner startAnimation:nil];
    refreshButton.hidden = YES;
    
    [self.modeWemo beginConnectingToWemo];
}

#pragma mark - Wemo Delegate


- (void)changeState:(TTWemoState)wemoState withMode:(TTModeWemo *)modeWemo {
    NSLog(@" Changing Wemo state: %lu", wemoState);
    
    switch (wemoState) {
        case WEMO_STATE_NOT_CONNECTED:
            [self selectDevice];
            break;
            
        case WEMO_STATE_CONNECTING:
            [self selectDevice];
            break;
            
        case WEMO_STATE_CONNECTED:
            spinner.hidden = YES;
            refreshButton.hidden = NO;
            [self selectDevice];
            break;
            
        default:
            break;
    }
}

@end
