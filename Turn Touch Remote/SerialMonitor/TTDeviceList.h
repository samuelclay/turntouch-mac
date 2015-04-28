//
//  TTPeripheralList.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/28/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TTDevice.h"

@interface TTDeviceList : NSObject <NSFastEnumeration> {
    NSMutableArray *peripherals;
    NSMutableArray *devices;
}

- (NSInteger)count;
- (TTDevice *)deviceForPeripheral:(CBPeripheral *)peripheral;
- (TTDevice *)objectAtIndex:(NSUInteger)index;

- (void)addPeripheral:(CBPeripheral *)peripheral;
- (void)addDevice:(TTDevice *)device;
- (void)removePeripheral:(CBPeripheral *)peripheral;
- (void)removeDevice:(TTDevice *)removeDevice;
- (void)ensureDevicesConnected;

- (BOOL)isPeripheralPaired:(CBPeripheral *)peripheral;
- (BOOL)isDevicePaired:(TTDevice *)device;

- (NSUInteger)totalPairedCount;
- (NSUInteger)pairedConnectedCount;
- (NSUInteger)unpairedConnectedCount;

@end
