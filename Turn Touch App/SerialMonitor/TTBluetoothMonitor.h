//
//  TTBluetoothMonitor.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/19/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

@interface TTBluetoothMonitor : NSObject
<CBCentralManagerDelegate, CBPeripheralDelegate> {
    NSString *manufacturer;
    CBCentralManager *manager;
    CBPeripheral *peripheral;
}

- (void) startScan;
- (void) stopScan;
- (BOOL) isLECapableHardware;
- (void) terminate;

@end
