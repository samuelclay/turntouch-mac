//
//  TTModeSonosConnected.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/18/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeSonosConnected.h"

@interface TTModeSonosConnected ()

@end

@implementation TTModeSonosConnected

@synthesize modeSonos;
@synthesize connectedLabel;
@synthesize scanButton;
@synthesize deviceSelect;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self selectDevice];
}

- (void)selectDevice {
    NSMutableArray *devices = [NSMutableArray array];
    NSString *deviceSelected = [NSAppDelegate.modeMap mode:self.modeSonos optionValue:kSonosDeviceId];
    NSArray *foundDevices = [self.modeSonos foundDevices];
    
    [deviceSelect removeAllItems];
    
    for (SonosController *device in foundDevices) {
        [devices addObject:@{@"name": device.name, @"identifier": device.uuid}];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [devices sortUsingDescriptors:@[sd]];

    for (NSDictionary *device in devices) {
        [deviceSelect addItemWithTitle:device[@"name"]];
        if ([device[@"uuid"] isEqualToString:deviceSelected]) {
            [deviceSelect selectItemWithTitle:device[@"name"]];
        }
    }
}

- (IBAction)changeDevice:(id)sender {
    NSArray *foundDevices = [self.modeSonos foundDevices];
    NSAssert(!self.modeSonos, @" ***> self.modeSonos is nil!");
    
    for (SonosController *device in foundDevices) {
        if ([device.name isEqualToString:deviceSelect.selectedItem.title]) {
            [NSAppDelegate.modeMap changeMode:self.modeSonos option:kSonosDeviceId to:device.uuid];
            break;
        }
    }
    
    [self selectDevice];
}

- (IBAction)scanForDevices:(id)sender {
    [self.modeSonos beginConnectingToSonos:nil];
}

@end
