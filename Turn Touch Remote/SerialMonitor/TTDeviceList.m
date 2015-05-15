//
//  TTPeripheralList.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/28/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTDeviceList.h"

@implementation TTDeviceList

- (instancetype)init {
    if (self = [super init]) {
        devices = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSString *)description {
    NSMutableArray *peripheralIds = [NSMutableArray array];
    for (TTDevice *device in devices) {
        [peripheralIds addObject:[device.peripheral.identifier.UUIDString substringToIndex:8]];
    }
    return [NSString stringWithFormat:@"%@", [peripheralIds componentsJoinedByString:@", "]];
}

- (NSInteger)count {
    NSInteger count = [devices count];
    if (!count) return 0;
    return count;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [devices countByEnumeratingWithState:state objects:buffer count:len];
}

- (TTDevice *)deviceForPeripheral:(CBPeripheral *)peripheral {
    for (TTDevice *device in devices) {
        if (device.peripheral == peripheral) return device;
    }
    
    return nil;
}

- (TTDevice *)objectAtIndex:(NSUInteger)index {
    return [devices objectAtIndex:index];

    // Uncomment below to only use paired devices
//    for (int i=0; i < index; ) {
//        TTDevice *device = [devices objectAtIndex:i];
//        if (device.isPaired) {
//            if (i == index) return device;
//            i++;
//        }
//    }
//    
//    return nil;
}

#pragma mark - Devices

- (void)addPeripheral:(CBPeripheral *)peripheral {
    TTDevice *device = [[TTDevice alloc] initWithPeripheral:peripheral];
    [self addDevice:device];
}

- (void)addDevice:(TTDevice *)addDevice {
    for (TTDevice *device in devices) {
        if ([device.peripheral.identifier.UUIDString
             isEqualToString:addDevice.peripheral.identifier.UUIDString]) {
            return;
        }
    }

    if (![devices containsObject:addDevice]) {
        [devices addObject:addDevice];
    } else {
        NSLog(@"Already added device: %@", addDevice);
    }
    addDevice.isPaired = [self isDevicePaired:addDevice];
}

- (void)removePeripheral:(CBPeripheral *)peripheral {
    TTDevice *device = [self deviceForPeripheral:peripheral];
    [self removeDevice:device];
}

- (void)removeDevice:(TTDevice *)removeDevice {
    NSMutableArray *updatedDevices = [[NSMutableArray alloc] init];
    for (TTDevice *device in devices) {
        if (device != removeDevice) {
            [updatedDevices addObject:device];
        } else if (device == removeDevice) {
            [device.peripheral setDelegate:nil];
            device.peripheral = nil;
        }
    }
    devices = updatedDevices;
    removeDevice = nil;
}

- (void)ensureDevicesConnected {
    NSMutableArray *updatedConnectedDevices = [[NSMutableArray alloc] init];
    
    // Counting paired devices
    for (TTDevice *device in devices) {
        if (device.peripheral.state == CBPeripheralStateConnected) {
            [updatedConnectedDevices addObject:device];
        }
    }

    devices = updatedConnectedDevices;
}

#pragma mark - Paired

- (BOOL)isPeripheralPaired:(CBPeripheral *)peripheral {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSArray *pairedDevices = [preferences objectForKey:@"TT:devices:paired"];

    return [pairedDevices containsObject:peripheral.identifier.UUIDString];
}

- (BOOL)isDevicePaired:(TTDevice *)device {
    return [self isPeripheralPaired:device.peripheral];
}

#pragma mark - Counts

- (NSUInteger)totalPairedCount {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSArray *pairedDevices = [preferences objectForKey:@"TT:devices:paired"];
    
    return [pairedDevices count];
}

- (NSUInteger)pairedConnectedCount {
    NSUInteger count = 0;

    for (TTDevice *device in devices) {
        if ([self isPeripheralPaired:device.peripheral]) {
            count++;
        }
    }

    return count;
}

- (NSUInteger)unpairedCount {
    NSUInteger count = 0;
    
    for (TTDevice *device in devices) {
        if (![self isPeripheralPaired:device.peripheral]) {
            count++;
        }
    }
    
    return count;
}

- (NSUInteger)unpairedConnectedCount {
    NSUInteger count = 0;
    
    for (TTDevice *device in devices) {
        if (![self isPeripheralPaired:device.peripheral] && device.isNotified) {
            count++;
        }
    }
    
    return count;
}

@end
