//
//  TTDevice.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface TTDevice : NSObject

typedef enum {
    TTDeviceStateDisconnected = 0,
    TTDeviceStateSearching = 1,
    TTDeviceStateConnecting = 2,
    TTDeviceStateConnected = 3
} TTDeviceState;

@property (nonatomic) NSString *nickname;
@property (nonatomic) NSString *uuid;
@property (nonatomic, retain) CBPeripheral *peripheral;
@property (nonatomic) NSNumber *batteryPct;
@property (nonatomic) NSDate *lastActionDate;
@property (nonatomic, readwrite) BOOL isPaired;
@property (nonatomic, readwrite) BOOL isNotified;
@property (nonatomic, readwrite) BOOL needsReconnection;
@property (nonatomic, readwrite) BOOL inDFU;
@property (nonatomic) NSInteger firmwareVersion;
@property (nonatomic) BOOL isFirmwareOld;
@property (nonatomic) TTDeviceState state;

- (NSString *)stateLabel;
- (id)initWithPeripheral:(CBPeripheral *)peripheral;
- (void)setNicknameData:(NSData *)nicknameData;
- (BOOL)isPairing;

@end
