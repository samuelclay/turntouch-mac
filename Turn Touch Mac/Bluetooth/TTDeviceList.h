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

@interface TTDeviceList : NSObject <NSFastEnumeration>

@property (nonatomic) NSMutableArray *devices;

- (TTDevice *)deviceForPeripheral:(CBPeripheral *)peripheral;
- (TTDevice *)objectAtIndex:(NSUInteger)index;

- (TTDevice *)addPeripheral:(CBPeripheral *)peripheral;
- (void)addDevice:(TTDevice *)device;
- (void)removePeripheral:(CBPeripheral *)peripheral;
- (void)removeDevice:(TTDevice *)removeDevice;
- (void)ensureDevicesConnected;
- (TTDevice *)connectedDeviceAtIndex:(NSInteger)index;

- (BOOL)isPeripheralPaired:(CBPeripheral *)peripheral;
- (BOOL)isDevicePaired:(TTDevice *)device;

- (NSInteger)count;
- (NSInteger)visibleCount;
- (NSInteger)connectedCount;
- (NSUInteger)totalPairedCount;
- (NSArray *)nicknamedConnected;
- (NSUInteger)pairedConnectedCount;
- (NSUInteger)unpairedCount;
- (NSUInteger)unpairedConnectedCount;

@end
