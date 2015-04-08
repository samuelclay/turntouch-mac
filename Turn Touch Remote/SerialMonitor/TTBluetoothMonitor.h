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

typedef enum {
    FIRMWARE_INTERVAL_MIN = 0,
    FIRMWARE_INTERVAL_MAX = 1,
    FIRMWARE_CONN_LATENCY = 2,
    FIRMWARE_CONN_TIMEOUT = 3
} FirmwareSetting;

@class TTButtonTimer;

@interface TTBluetoothMonitor : NSObject
<CBCentralManagerDelegate, CBPeripheralDelegate> {
    TTAppDelegate *appDelegate;
    TTButtonTimer *buttonTimer;
    NSTimer *batteryLevelTimer;

    NSString *manufacturer;
    CBCentralManager *manager;
    NSMutableArray *connectedDevices;
    NSMutableDictionary *characteristics;
}

@property (nonatomic) NSNumber *batteryPct;
@property (nonatomic) NSMutableArray *foundDevices;
@property (nonatomic) NSMutableArray *connectedDevices;
@property (nonatomic) NSNumber *connectedDevicesCount;

- (void) startScan;
- (void) stopScan;
- (BOOL) isLECapableHardware;
- (void) terminate;

@end
