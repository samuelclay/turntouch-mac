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
#import "TTDeviceList.h"

typedef enum {
    FIRMWARE_INTERVAL_MIN = 0,
    FIRMWARE_INTERVAL_MAX = 1,
    FIRMWARE_CONN_LATENCY = 2,
    FIRMWARE_CONN_TIMEOUT = 3,
    FIRMWARE_MODE_DURATION = 4,
    FIRMWARE_NICKNAME = 5,
} FirmwareSetting;

@class TTButtonTimer;

@interface TTBluetoothMonitor : NSObject
<CBCentralManagerDelegate, CBPeripheralDelegate> {
    TTAppDelegate *appDelegate;
    TTButtonTimer *buttonTimer;
    NSTimer *batteryLevelTimer;

    NSString *manufacturer;
    CBCentralManager *manager;
    NSMutableDictionary *characteristics;
    NSInteger connectionDelay;
}

@property (nonatomic) NSNumber *batteryPct;
@property (nonatomic) NSDate *lastActionDate;
@property (nonatomic) TTButtonTimer *buttonTimer;
@property (nonatomic, readwrite) BOOL addingDevice;
@property (nonatomic, strong) CBCentralManager *manager;

// Both unpaired and paired peripherals
@property (nonatomic) TTDeviceList *foundDevices;
@property (nonatomic) NSNumber *pairedDevicesCount;
@property (nonatomic) NSNumber *unpairedDevicesCount;
@property (nonatomic, readwrite) NSNumber *unpairedDevicesConnected;

- (BOOL)isLECapableHardware;
- (void)startScan;
- (void)startScan:(BOOL)findUnpaired;
- (void)stopScan;
- (void)updateBluetoothState:(BOOL)renew;
- (void)reconnect;
- (void)terminate;
- (void)disconnectUnpairedDevices;
- (void)setDeviceLatency:(NSInteger)latency;
- (void)setModeDuration:(NSInteger)duration;
- (void)writeNickname:(NSString *)newNickname toDevice:(TTDevice *)device;

@end
