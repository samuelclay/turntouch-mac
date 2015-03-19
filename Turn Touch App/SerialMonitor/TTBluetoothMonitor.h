//
//  TTBluetoothMonitor.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/19/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import "TTAppDelegate.h"
#import "TTButtonTimer.h"

@class TTButtonTimer;

@interface TTBluetoothMonitor : NSObject
<CBCentralManagerDelegate, CBPeripheralDelegate> {
    TTAppDelegate *appDelegate;
    TTButtonTimer *buttonTimer;

    NSString *manufacturer;
    CBCentralManager *manager;
    CBPeripheral *peripheral;
}

@property (nonatomic) NSNumber *batteryPct;

- (void) startScan;
- (void) stopScan;
- (BOOL) isLECapableHardware;
- (void) terminate;

@end
