//
//  TTBluetoothMonitor.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/19/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTBluetoothMonitor.h"
#import "NSData+Conversion.h"
#import "TTDevice.h"
#import "Utility.h"

// Firmware rev. 10 - 19 = v1
#define DEVICE_V1_SERVICE_BATTERY_UUID                 @"180F"
#define DEVICE_V1_SERVICE_BUTTON_UUID                  @"88c3907a-dc4f-41b1-bb04-4e4deb81fadd"
#define DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID       @"2f850855-71c4-4543-bcd3-9bc29d435390"

#define DEVICE_V1_CHARACTERISTIC_BATTERY_LEVEL_UUID    @"2a19"
#define DEVICE_V1_CHARACTERISTIC_BUTTON_STATUS_UUID    @"47099164-4d08-4338-bedf-7fc043dbec5c"
#define DEVICE_V1_CHARACTERISTIC_INTERVAL_MIN_UUID     @"0a02cefb-f546-4a56-ad2b-4aeadca0da6e"
#define DEVICE_V1_CHARACTERISTIC_INTERVAL_MAX_UUID     @"50a71e79-f950-4973-9cbd-1ce5439603be"
#define DEVICE_V1_CHARACTERISTIC_CONN_LATENCY_UUID     @"3b6ef6e7-d9dc-4010-960a-a48bbe114935"
#define DEVICE_V1_CHARACTERISTIC_CONN_TIMEOUT_UUID     @"c6d87b9e-70c3-47ff-a534-e1ceb2bdf435"
#define DEVICE_V1_CHARACTERISTIC_MODE_DURATION_UUID    @"bc382b21-1617-48cc-9e93-f4104561f71d"
#define DEVICE_V1_CHARACTERISTIC_NICKNAME_UUID         @"6b8d8785-0b9b-4b13-bfe5-d71dd3b6ccc2"

// Firmware rev. 20+ = v2
#define DEVICE_V2_SERVICE_BATTERY_UUID                 @"180F"
#define DEVICE_V2_SERVICE_BUTTON_UUID                  @"99c31523-dc4f-41b1-bb04-4e4deb81fadd"
#define DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID    @"2a19"
#define DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID    @"99c31525-dc4f-41b1-bb04-4e4deb81fadd"
#define DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID         @"99c31526-dc4f-41b1-bb04-4e4deb81fadd"


const int BATTERY_LEVEL_READING_INTERVAL = 60; // every 6 hours

#define CLEAR_PAIRED_DEVICES 1
#define DEBUG_CONNECT

@implementation TTBluetoothMonitor

@synthesize manager;
@synthesize buttonTimer;
@synthesize batteryPct;
@synthesize lastActionDate;
@synthesize foundDevices;
@synthesize nicknamedConnectedCount;
@synthesize pairedDevicesCount;
@synthesize unpairedDevicesCount;
@synthesize addingDevice;
@synthesize unpairedDevicesConnected;

- (instancetype)init {
    if (self = [super init]) {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        buttonTimer = [[TTButtonTimer alloc] init];
        batteryPct = [[NSNumber alloc] init];
        lastActionDate = [NSDate date];
        characteristics = [[NSMutableDictionary alloc] init];
        connectionDelay = 4;

        foundDevices = [[TTDeviceList alloc] init];
        nicknamedConnectedCount = [[NSNumber alloc] initWithInteger:0];
        pairedDevicesCount = [[NSNumber alloc] initWithInteger:0];
        unpairedDevicesCount = [[NSNumber alloc] initWithInteger:0];
        
        NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
        if (CLEAR_PAIRED_DEVICES) {
            [preferences setObject:nil forKey:@"TT:devices:paired"];
            [preferences synchronize];
        }
    }
    
    return self;
}

- (BOOL)isLECapableHardware {
    NSString * state = nil;
    
    switch ([manager state]) {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            return TRUE;
        case CBCentralManagerStateUnknown:
            state = @"Bluetooth in unknown state.";
            break;
        case CBCentralManagerStateResetting:
            state = @"Bluetooth in resetting state.";
            break;
        default:
            state = @"Bluetooth not in any state!";
            break;
    }
    
    NSLog(@"Central manager state: %@ - %@/%ld", state, manager, manager.state);
    
    return FALSE;
}

- (NSArray *)knownPeripheralIdentifiers {
    NSMutableArray *identifiers = [NSMutableArray array];
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSMutableArray *pairedDevices = [[preferences objectForKey:@"TT:devices:paired"] mutableCopy];
    
    for (NSString *identifier in pairedDevices) {
        [identifiers addObject:[[NSUUID alloc] initWithUUIDString:identifier]];
    }
    
    return identifiers;
}

#pragma mark - Start/Stop Scan methods

- (void)scanKnown {
    BOOL knownDevicesStillDisconnected = NO;
    
    bluetoothState = BT_STATE_SCANNING_KNOWN;
#ifdef DEBUG_CONNECT
    NSLog(@" ---> (%X) Scanning known: %lu remotes", bluetoothState, (unsigned long)[[self knownPeripheralIdentifiers] count]);
#endif
    BOOL isActivelyConnecting = NO;
    
    NSArray *peripherals = [manager retrievePeripheralsWithIdentifiers:[self knownPeripheralIdentifiers]];
    for (CBPeripheral *peripheral in peripherals) {
        TTDevice *foundDevice = [foundDevices deviceForPeripheral:peripheral];
        if (!foundDevice) {
            foundDevice = [foundDevices addPeripheral:peripheral];
        } else if (foundDevice.state == TTDeviceStateConnecting) {
            isActivelyConnecting = YES;
        }
        if (peripheral.state != CBPeripheralStateDisconnected && foundDevice.state != TTDeviceStateSearching) {
#ifdef DEBUG_CONNECT
//            NSLog(@" ---> (%X) Already connected: %@", bluetoothState, foundDevice);
#endif
            continue;
        } else {
            knownDevicesStillDisconnected = YES;
        }
        
        bluetoothState = BT_STATE_CONNECTING_KNOWN;
#ifdef DEBUG_CONNECT
        NSLog(@" ---> (%X) Attempting connect to known: %@/%@", bluetoothState, [peripheral.identifier.UUIDString substringToIndex:8], foundDevice);
#endif
        NSDictionary *options = @{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES],
                                  CBCentralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES]};
        [manager cancelPeripheralConnection:peripheral];
        [manager connectPeripheral:peripheral options:options];
    }
    
    if (!knownDevicesStillDisconnected) {
        bluetoothState = BT_STATE_DOING_NOTHING;
#ifdef DEBUG_CONNECT
        NSLog(@" ---> (%X) All done, no known devices left to connect.", bluetoothState);
#endif
    }

    if (![self knownPeripheralIdentifiers].count && !isActivelyConnecting) {
        [self scanUnknown];
        return;
    }

    // Search for unpaired devices or paired devices that aren't responding to `connectPeripheral`
    static dispatch_once_t onceUnknownToken;
    dispatch_once(&onceUnknownToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            onceUnknownToken = 0;
            if (bluetoothState != BT_STATE_SCANNING_KNOWN && bluetoothState != BT_STATE_CONNECTING_KNOWN) {
#ifdef DEBUG_CONNECT
                NSLog(@" ---> (%X) Not scanning for unpaired, since not scanning known.", bluetoothState);
#endif
                return;
            }

#ifdef DEBUG_CONNECT
            NSLog(@" ---> (%X) Starting scan for unpaired...", bluetoothState);
#endif
            [self stopScan];
            [self scanUnknown];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#ifdef DEBUG_CONNECT
                NSLog(@" ---> (%X) Stopping scan for unpaired", bluetoothState);
#endif
                [self stopScan];
                [self scanKnown];
            });
        });
    });
}

- (void)scanUnknown {
    if (bluetoothState == BT_STATE_PAIRING_UNKNOWN) {
#ifdef DEBUG_CONNECT
        NSLog(@" ---> (%X) Not scanning unknown since in pairing state.", bluetoothState);
#endif
        return;
    }
    if (bluetoothState == BT_STATE_CONNECTING_UNKNOWN) {
        for (TTDevice *foundDevice in foundDevices) {
            if (foundDevice.state == TTDeviceStateConnecting) {
#ifdef DEBUG_CONNECT
                NSLog(@" ---> (%X) [Scanning unknown] Canceling peripheral connection: %@", bluetoothState, foundDevice);
#endif
                [manager cancelPeripheralConnection:foundDevice.peripheral];
            }
        }
#ifdef DEBUG_CONNECT
        NSLog(@" ---> (%X) Not scanning unknown since already connecting to unknown.", bluetoothState);
#endif
        return;
    }

    [self stopScan];
    bluetoothState = BT_STATE_SCANNING_UNKNOWN;
#ifdef DEBUG_CONNECT
    NSLog(@" ---> (%X) Scanning unknown: %@", bluetoothState, [self knownPeripheralIdentifiers]);
#endif
    
    [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:DEVICE_V1_SERVICE_BUTTON_UUID],
                                              [CBUUID UUIDWithString:DEVICE_V2_SERVICE_BUTTON_UUID],
                                              [CBUUID UUIDWithString:@"1523"]]
                                    options:nil];
}

- (void) stopScan {
#ifdef DEBUG_CONNECT
    NSLog(@" ---> (%X) Stopping scan.", bluetoothState);
#endif
    [manager stopScan];
}


#pragma mark - CBCentralManager delegate methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
#ifdef DEBUG_CONNECT
//    NSLog(@" ---> centralManagerDidUpdateState: %ld vs %ld", (long)central.state, (long)manager.state);
#endif
    manager = central;
    [self updateBluetoothState:NO];
}

- (void)updateBluetoothState:(BOOL)renew {
    if (renew) {
        NSLog(@"Renewing CB manager. Old: %@/%ld", manager, (long)manager.state);
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    [self stopScan];
    if ([self isLECapableHardware]) {
        [self scanKnown];
    } else {
        [self countDevices];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reconnect];
        });
    }
}

- (void) reconnect {
    [self stopScan];
    [self terminate];
    [self updateBluetoothState:YES];
}

- (void) terminate {
    NSMutableArray *identifiers;
    for (TTDevice *device in foundDevices) {
        NSLog(@"Terminating device: %@", device);
        if (device.state != TTDeviceStateConnected) continue;
        [identifiers addObject:device.uuid];
    }

    if (!identifiers.count) {
        NSLog(@"No identifiers to terminate...");
        manager = nil;
        return;
    }
    
    NSArray *peripherals = [manager retrievePeripheralsWithIdentifiers:identifiers];
    for (CBPeripheral *peripheral in peripherals) {
        [manager cancelPeripheralConnection:peripheral];
        TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
        [foundDevices removeDevice:device];
    }
    manager = nil;
}

- (void)countDevices {
//    NSLog(@"Counting %d: %@", (int)foundDevices.count, foundDevices);
    
    [foundDevices ensureDevicesConnected];
    
    [self setValue:@([[foundDevices nicknamedConnected] count]) forKey:@"nicknamedConnectedCount"];
    [self setValue:@([foundDevices pairedConnectedCount]) forKey:@"pairedDevicesCount"];
    [self setValue:@([foundDevices unpairedCount]) forKey:@"unpairedDevicesCount"];
    [self setValue:@([foundDevices unpairedConnectedCount]) forKey:@"unpairedDevicesConnected"];
}

/*
 Invoked when the central discovers peripheral while scanning.
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
      advertisementData:(NSDictionary *)advertisementData
                   RSSI:(NSNumber *)RSSI
{
    TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
    if (!device) {
        device = [foundDevices addPeripheral:peripheral];
    }

    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    bluetoothState = BT_STATE_CONNECTING_UNKNOWN;
#ifdef DEBUG_CONNECT
    NSLog(@" --> (%X) Found bluetooth peripheral, attempting connect: %@/%@ (%@)", bluetoothState, localName, device, RSSI);
#endif
    [self stopScan];
    BOOL isAlreadyConnecting = NO;
    for (TTDevice *foundDevice in foundDevices) {
        if (foundDevice.peripheral == peripheral) continue;
        if (foundDevice.state == TTDeviceStateConnecting) {
#ifdef DEBUG_CONNECT
            NSLog(@" ---> (%X) [Connecting to another] Canceling peripheral connection: have %@, canceling %@", bluetoothState, foundDevice, peripheral);
#endif
            isAlreadyConnecting = YES;
        }
    }
    
    if (isAlreadyConnecting) {
        [manager cancelPeripheralConnection:peripheral];
    } else {
        [manager connectPeripheral:peripheral
                           options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES],
                                     CBCentralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES]}];
    }

    // In case stillconnecting 30 seconds from now, disconnect.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (bluetoothState != BT_STATE_CONNECTING_UNKNOWN) return;
#ifdef DEBUG_CONNECT
        NSLog(@" ---> (%X) Still connecting to unknown, disconnecting...", bluetoothState);
#endif
        bluetoothState = BT_STATE_DOING_NOTHING;
        [self stopScan];
        [self scanKnown];
    });

}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral.
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
    
    for (TTDevice *foundDevice in foundDevices) {
        if (foundDevice.state == TTDeviceStateConnecting && foundDevice.peripheral == peripheral) {
#ifdef DEBUG_CONNECT
            NSLog(@" ---> (%X) [Connected another] Canceling peripheral connection: %@ (connecting to %@)", bluetoothState, device, foundDevice);
#endif
            [manager cancelPeripheralConnection:peripheral];
            return;
        }
    }
    [peripheral setDelegate:self];

#ifdef DEBUG_CONNECT
    NSLog(@" ---> (%X) Connected bluetooth peripheral: %@", bluetoothState, device);
#endif

    if (device.isPaired) {
        // Seen device before, connect and discover services

        device.state = TTDeviceStateConnecting;
        device.needsReconnection = NO;

        [self countDevices];

        bluetoothState = BT_STATE_DISCOVER_SERVICES;
    } else {
        // Never seen device before, start the pairing process

        bluetoothState = BT_STATE_PAIRING_UNKNOWN;
        
        device.state = TTDeviceStateConnecting;
        device.needsReconnection = NO;

        [buttonTimer resetPairingState];
        [self countDevices];

        BOOL noPairedDevices = ![foundDevices totalPairedCount];
        if (noPairedDevices) {
            [appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_SEARCH];
        }
    }

    [peripheral discoverServices:@[[CBUUID UUIDWithString:DEVICE_V1_SERVICE_BUTTON_UUID],
                                   [CBUUID UUIDWithString:DEVICE_V1_SERVICE_BATTERY_UUID],
                                   [CBUUID UUIDWithString:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID],
                                   [CBUUID UUIDWithString:DEVICE_V2_SERVICE_BUTTON_UUID],
                                   [CBUUID UUIDWithString:DEVICE_V2_SERVICE_BATTERY_UUID],
                                   [CBUUID UUIDWithString:dfuServiceUUIDString]
                                   ]];
    
    
    // Should put in a timer to ensure that scanknown is called in 10 seconds, just in case
//    [self scanKnown];
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
#ifdef DEBUG_CONNECT
    TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
    NSLog(@" ---> (%X) Disconnected device: %@", bluetoothState, device);
#endif
    connectionDelay = 4;
    [foundDevices removePeripheral:peripheral];
    [self countDevices];

    static dispatch_once_t onceKnownToken;
    dispatch_once(&onceKnownToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            onceKnownToken = 0;
            [self scanKnown];
        });
    });
    
    [appDelegate.hudController releaseToastActiveAction];
    [appDelegate.hudController releaseToastActiveMode];
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error.code == 10) {
//        NSLog(@"Ignoring error: %@ (should be reached max conn)", [error localizedDescription]);
        return;
    }
    
#ifdef DEBUG_CONNECT
    NSLog(@" ---> (%X) Fail to connect to peripheral: %@ (%@) with error = %@", bluetoothState,
          peripheral.name, [peripheral.identifier.UUIDString substringToIndex:8], [error localizedDescription]);
#endif
    
    [foundDevices removePeripheral:peripheral];
    [self countDevices];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopScan];
        [self scanKnown];
    });
}

#pragma mark - CBPeripheral delegate methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    bluetoothState = BT_STATE_DISCOVER_CHARACTERISTICS;
    
    for (CBService *service in peripheral.services) {
#ifdef DEBUG_CONNECT
//        NSLog(@" ---> (%X) Service found with UUID: %@", bluetoothState, service.UUID);
#endif
        TTDevice *device = [foundDevices deviceForPeripheral:peripheral];

        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_SERVICE_BUTTON_UUID]]) {
            device.firmwareVersion = 1;
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_BUTTON_STATUS_UUID]]
                                     forService:service];
        }

        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID]]) {
            device.firmwareVersion = 1;
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_INTERVAL_MIN_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_INTERVAL_MAX_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_MODE_DURATION_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_NICKNAME_UUID]]
                                     forService:service];
        }
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_SERVICE_BATTERY_UUID]]) {
            device.firmwareVersion = 1;
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_BATTERY_LEVEL_UUID]]
                                     forService:service];
        }
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_SERVICE_BUTTON_UUID]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID]]
                                     forService:service];
        }
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_SERVICE_BATTERY_UUID]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID]]
                                     forService:service];
        }
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:dfuServiceUUIDString]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:dfuVersionCharacteritsicUUIDString]]
                                     forService:service];
        }
        
        /* Device Information Service */
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"2A29"]]
                                     forService:service];
        }
        
        /* GAP (Generic Access Profile) for Device Name */
        if ([service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CBUUIDDeviceNameString]]
                                     forService:service];
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    bluetoothState = BT_STATE_CHAR_NOTIFICATION;
#ifdef DEBUG_CONNECT
//    NSLog(@" ---> (%X) Characteristic found with UUID: %@", bluetoothState, service.UUID);
#endif
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_SERVICE_BUTTON_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_BUTTON_STATUS_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_SERVICE_BUTTON_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:dfuServiceUUIDString]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:dfuVersionCharacteritsicUUIDString]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
        }
    }

    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_INTERVAL_MIN_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_INTERVAL_MAX_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_MODE_DURATION_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_NICKNAME_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_CONN_LATENCY_UUID]]) {
//                [peripheral readValueForCharacteristic:aChar];
//            }
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_CONN_TIMEOUT_UUID]]) {
//                [peripheral readValueForCharacteristic:aChar];
//            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_SERVICE_BATTERY_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_BATTERY_LEVEL_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
                [self delayBatteryLevelReading];
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_SERVICE_BATTERY_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
                [self delayBatteryLevelReading];
            }
        }
    }
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] ) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
        }
    }
}

/*
 Invoked upon completion of a -[setNotifyValue:] request
 */
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_BUTTON_STATUS_UUID]] ||
        [characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID]]) {
#ifdef DEBUG_CONNECT
        NSLog(@" ---> (%X) Subscribed to button status notifications: %@", bluetoothState,
              [peripheral.identifier.UUIDString substringToIndex:8]);
#endif
        
        TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
        device.isNotified = YES;
        device.state = TTDeviceStateConnected;
        [self countDevices];
        
        bluetoothState = BT_STATE_DOING_NOTHING;
        [self scanKnown];
//        [appDelegate.hudController toastActiveMode];
    } else {
        NSLog(@"ERROR: Subscribed to notifications: %@/%@", peripheral.identifier.UUIDString, characteristic.UUID.UUIDString);
    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
              error:(NSError *)error {
    TTDevice *device = [foundDevices deviceForPeripheral:peripheral];

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_BUTTON_STATUS_UUID]] ||
        [characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID]]) {
        if( (characteristic.value)  || !error ) {
//            NSLog(@"Characteristic value: %@", [characteristic.value hexadecimalString]);
            if (device.isPaired) {
                [buttonTimer readBluetoothData:characteristic.value];
            } else {
                [buttonTimer readBluetoothDataDuringPairing:characteristic.value];
                if ([buttonTimer isDevicePaired]) {
                    [self pairDeviceSuccess:peripheral];
                }
            }
            device.lastActionDate = [NSDate date];
            [self setValue:[NSDate date] forKey:@"lastActionDate"];
        } else {
            NSLog(@"Characteristic error: %@ / %@", characteristic.value, error);
        }
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_BATTERY_LEVEL_UUID]]) {
        if( (characteristic.value)  || !error ) {
            const uint8_t *bytes = [characteristic.value bytes]; // pointer to the bytes in data
            uint16_t value = bytes[0]; // first byte
//            NSLog(@"Battery level: %d%%", value);
            device.lastActionDate = [NSDate date];
            device.batteryPct = @(value);
            device.uuid = peripheral.identifier.UUIDString;
            [self setValue:@(value) forKey:@"batteryPct"];
            [self setValue:[NSDate date] forKey:@"lastActionDate"];
        }
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_INTERVAL_MIN_UUID]]) {
        [characteristics setObject:characteristic forKey:@"interval_min"];
        [self device:peripheral sentFirmwareSettings:FIRMWARE_INTERVAL_MIN];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_INTERVAL_MAX_UUID]]) {
        [characteristics setObject:characteristic forKey:@"interval_max"];
        [self device:peripheral sentFirmwareSettings:FIRMWARE_INTERVAL_MAX];
//    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_CONN_LATENCY_UUID]]) {
//        [characteristics setObject:characteristic forKey:@"conn_latency"];
//        [self device:peripheral sentFirmwareSettings:FIRMWARE_CONN_LATENCY];
//    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_CONN_TIMEOUT_UUID]]) {
//        [characteristics setObject:characteristic forKey:@"conn_timeout"];
//        [self device:peripheral sentFirmwareSettings:FIRMWARE_CONN_TIMEOUT];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V1_CHARACTERISTIC_NICKNAME_UUID]] ||
               [characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID]]) {
        if (!characteristic || !characteristic.value || !characteristic.value.length) {
#ifdef DEBUG_CONNECT
            NSLog(@" ---> !!! %@ has no nickname", peripheral);
#endif
        }
        TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
        [device setNicknameData:characteristic.value];
        
        [self countDevices];
        NSLog(@" ---> (%X) Hello %@", bluetoothState, device);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self ensureNicknameOnDevice:device];
        });
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) {
        NSString * deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Device Name = %@", deviceName);
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) {
        manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Manufacturer Name = %@", manufacturer);
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:dfuVersionCharacteritsicUUIDString]]) {
        int firmwareVersion;
        [characteristic.value getBytes:&firmwareVersion length:2];
#ifdef DEBUG_CONNECT
        NSLog(@" ---> Firmware version of %@: %d", device, firmwareVersion);
#endif
        device.firmwareVersion = firmwareVersion;
        [self countDevices];
    } else {
        NSLog(@"Unidentified characteristic: %@", characteristic);
    }
}

/*
 Invoked upon completion of a -[writeValue:forCharacteristic:type:] request
 */
- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    uint16_t value;
    [characteristic.value getBytes:&value length:2];
    
    NSLog(@"Did write value. Old: %d/%@ - %@", value, characteristic.value, error);
    
    TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
    if (device.needsReconnection) {
#ifdef DEBUG_CONNECT
        NSLog(@" ---> (%X) [Needs reconnections] Canceling peripheral connection: %@", bluetoothState, peripheral);
#endif
        [manager cancelPeripheralConnection:device.peripheral];
    }
}


#pragma mark - Connection Attributes Firmware Updates

- (void)device:(CBPeripheral *)peripheral sentFirmwareSettings:(FirmwareSetting)setting {
//    NSLog(@"Device sent firmware settings: %d", setting);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    uint16_t firmwareIntervalMin = [[prefs objectForKey:@"TT:firmware:interval_min"] intValue];
    uint16_t firmwareIntervalMax = [[prefs objectForKey:@"TT:firmware:interval_max"] intValue];
    uint16_t firmwareConnLatency = [[prefs objectForKey:@"TT:firmware:conn_latency"] intValue];
    uint16_t firmwareConnTimeout = [[prefs objectForKey:@"TT:firmware:conn_timeout"] intValue];
    uint16_t firmwareModeDuration = [[prefs objectForKey:@"TT:firmware:mode_duration"] intValue];
    
    if (setting == FIRMWARE_INTERVAL_MIN) {
        CBCharacteristic *characteristic = [self characteristicInPeripheral:peripheral
                                                             andServiceUUID:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_V1_CHARACTERISTIC_INTERVAL_MIN_UUID];
        if (!characteristic.value) return;
        uint16_t value;
        [characteristic.value getBytes:&value length:2];
        if (firmwareIntervalMin != value) {
            NSLog(@"Server %d, remote %d", firmwareIntervalMin, value);
            NSData *data = [NSData dataWithBytes:(void*)&firmwareIntervalMin length:2];
            [peripheral writeValue:data forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
        }
    } else if (setting == FIRMWARE_INTERVAL_MAX) {
        CBCharacteristic *characteristic = [self characteristicInPeripheral:peripheral
                                                             andServiceUUID:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_V1_CHARACTERISTIC_INTERVAL_MAX_UUID];
        if (!characteristic.value) return;
        uint16_t value;
        [characteristic.value getBytes:&value length:2];
        if (firmwareIntervalMax != value) {
            NSLog(@"Server %d, remote %d", firmwareIntervalMax, value);
            NSData *data = [NSData dataWithBytes:(void*)&firmwareIntervalMax length:2];
            [peripheral writeValue:data forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
        }
    } else if (setting == FIRMWARE_CONN_LATENCY) {
        CBCharacteristic *characteristic = [self characteristicInPeripheral:peripheral
                                                             andServiceUUID:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_V1_CHARACTERISTIC_CONN_LATENCY_UUID];
        if (!characteristic.value) return;
        uint16_t value;
        [characteristic.value getBytes:&value length:2];
        if (firmwareConnLatency != value) {
            NSLog(@"Server %d, remote %d", firmwareConnLatency, value);
            NSData *data = [NSData dataWithBytes:(void*)&firmwareConnLatency length:2];
            [peripheral writeValue:data forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
        }
    } else if (setting == FIRMWARE_CONN_TIMEOUT) {
        CBCharacteristic *characteristic = [self characteristicInPeripheral:peripheral
                                                             andServiceUUID:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_V1_CHARACTERISTIC_CONN_TIMEOUT_UUID];
        if (!characteristic.value) return;
        uint16_t value;
        [characteristic.value getBytes:&value length:2];
        if (firmwareConnTimeout != value) {
            NSLog(@"Server %d, remote %d", firmwareConnTimeout, value);
            NSData *data = [NSData dataWithBytes:(void*)&firmwareConnTimeout length:2];
            [peripheral writeValue:data forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
        }
    } else if (setting == FIRMWARE_MODE_DURATION) {
        CBCharacteristic *characteristic = [self characteristicInPeripheral:peripheral
                                                             andServiceUUID:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_V1_CHARACTERISTIC_MODE_DURATION_UUID];
        if (!characteristic.value) return;
        uint16_t value;
        [characteristic.value getBytes:&value length:2];
        if (firmwareModeDuration != value) {
            NSLog(@"Server %d, remote %d", firmwareModeDuration, value);
            NSData *data = [NSData dataWithBytes:(void*)&firmwareModeDuration length:2];
            [peripheral writeValue:data forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
        }
    }
}

- (void)setDeviceLatency:(NSInteger)latency {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    uint16_t minLatency = round((CGFloat)latency * 0.7f);
    uint16_t maxLatency = latency;
    
    [prefs setObject:@(minLatency) forKey:@"TT:firmware:interval_min"];
    [prefs setObject:@(maxLatency) forKey:@"TT:firmware:interval_max"];
    [prefs synchronize];
    
    for (TTDevice *device in foundDevices) {
        if (!device.isPaired) continue;
        [self device:device.peripheral sentFirmwareSettings:FIRMWARE_INTERVAL_MIN];
        [self device:device.peripheral sentFirmwareSettings:FIRMWARE_INTERVAL_MAX];
        device.needsReconnection = YES;
    }
}

- (void)setModeDuration:(NSInteger)duration {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    uint16_t modeDuration = duration;
    
    [prefs setObject:@(modeDuration) forKey:@"TT:firmware:mode_duration"];
    [prefs synchronize];
    
    for (TTDevice *device in foundDevices) {
        if (!device.isPaired) continue;
        [self device:device.peripheral sentFirmwareSettings:FIRMWARE_MODE_DURATION];
    }
}

- (void)ensureNicknameOnDevice:(TTDevice *)device {
//    if (!device.isPaired) return; // I guess unpaired remotes can still get a nickname forced on them

    NSString *newNickname;
    NSMutableData *emptyNickname = [NSMutableData dataWithLength:32];
    NSData *deviceNicknameData = [device.nickname dataUsingEncoding:NSUTF8StringEncoding];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *nicknameKey = [NSString stringWithFormat:@"TT:device:%@:nickname", device.uuid];
    NSString *existingNickname = [[prefs objectForKey:nicknameKey] stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    
    BOOL hasDeviceNickname = ![deviceNicknameData isEqualToData:emptyNickname] && [device.nickname stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].length;
    BOOL force = YES;
    force = NO;
    
    if (!existingNickname && hasDeviceNickname) {
        [prefs setObject:device.nickname forKey:nicknameKey];
        [prefs synchronize];
    }
    
    if (!hasDeviceNickname || force) {
        if (existingNickname && existingNickname.length) {
            newNickname = existingNickname;
        } else {
            NSArray *emoji = @[@"🐱", @"🐼", @"🐶", @"🐨", @"🐙", @"🐝", @"🐠", @"🐳", @"⛄️",
                               @"⚽️", @"🎻", @"🎱", @"🌀", @"📚", @"🔮", @"📡", @"⛵️", @"🚲",
                               @"☀️", @"🌎", @"🌵", @"🌴", @"🎋", @"🍉", @"🍒", @"🌻", @"🌸",
                               @"🏺", @"🚀", @"🔭", @"🔬", @"🗿", @"🏮", @"💎", @"🎵", @"🍄"];
            NSString *randomEmoji = [emoji objectAtIndex:arc4random_uniform((uint32_t)emoji.count)];
            newNickname = [NSString stringWithFormat:@"%@ Turn Touch Remote", randomEmoji];
        }
        
        NSLog(@"Generating emoji nickname: %@", newNickname);

        [self writeNickname:newNickname toDevice:device];
    }
}

- (void)writeNickname:(NSString *)newNickname toDevice:(TTDevice *)device {
    NSMutableData *data = [NSMutableData dataWithData:[newNickname dataUsingEncoding:NSUTF8StringEncoding]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    // Clear out the NULL \0 bytes that accumulate
    [self clearDataOfNullBytes:data];

    // Must have a 32 byte string to overwrite old nicknames that were longer.
    if (data.length > 32) {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataString = [dataString substringToIndex:32];
        NSUInteger maxLength = MIN(32, dataString.length);
        while (maxLength > 0) {
            NSInteger encodedLength = [dataString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            if (encodedLength > 32 || !encodedLength) {
                --maxLength;
                dataString = [dataString substringToIndex:maxLength];
            } else {
                break;
            }
        }
        [dataString substringToIndex:maxLength];
        data = [NSMutableData dataWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
        [data increaseLengthBy:(32-data.length)];
    }

    CBCharacteristic *characteristic;
    
    if (device.firmwareVersion <= 1) {
        // BlueGiga's BLE112
        characteristic = [self characteristicInPeripheral:device.peripheral
                                           andServiceUUID:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID
                                    andCharacteristicUUID:DEVICE_V1_CHARACTERISTIC_NICKNAME_UUID];
    } else if (device.firmwareVersion >= 2) {
        // Nordic's nRF51
        characteristic = [self characteristicInPeripheral:device.peripheral
                                           andServiceUUID:DEVICE_V2_SERVICE_BUTTON_UUID
                                    andCharacteristicUUID:DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID];
    }
    
    if (!characteristic) {
        NSLog(@" ***> Problem! No valid nickname characteristic: v%d", device.firmwareVersion);
        [manager cancelPeripheralConnection:device.peripheral];
        return;
    }

    NSLog(@"New Nickname: => %@ (%@)", newNickname, data);
    
    [device.peripheral writeValue:data forCharacteristic:characteristic
                             type:CBCharacteristicWriteWithResponse];
    
    // Clear it again since it was padded out
    [self clearDataOfNullBytes:data];

    [device setNicknameData:data];
    
    [prefs setObject:newNickname forKey:[NSString stringWithFormat:@"TT:device:%@:nickname", device.uuid]];
    [prefs synchronize];

    [self countDevices];
}

- (void)clearDataOfNullBytes:(NSMutableData *)data {
    NSInteger i = MIN(32, data.length);
    char nullBytes[] = "\0";
    NSData *emptyData = [NSData dataWithBytes:nullBytes length:1];
    while (i--) {
        NSRange range = NSMakeRange(i, 1);
        NSData *dataAtByte = [data subdataWithRange:range];
        if ([dataAtByte isEqualToData:emptyData]) {
            [data replaceBytesInRange:range withBytes:NULL length:0];
        }
    }
}

#pragma mark - Battery level

- (void)delayBatteryLevelReading {
    if (batteryLevelTimer) {
        [batteryLevelTimer invalidate];
        batteryLevelTimer = nil;
    }
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:BATTERY_LEVEL_READING_INTERVAL];
    batteryLevelTimer = [[NSTimer alloc]
                         initWithFireDate:fireDate
                         interval:0
                         target:self
                         selector:@selector(updateBatteryLevel:)
                         userInfo:nil
                         repeats:NO];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:batteryLevelTimer forMode:NSDefaultRunLoopMode];
}

- (void)updateBatteryLevel:(NSTimer *)timer {
    for (TTDevice *device in foundDevices) {
        CBCharacteristic *characteristic = [self characteristicInPeripheral:device.peripheral
                                                             andServiceUUID:DEVICE_V1_SERVICE_BATTERY_UUID
                                                      andCharacteristicUUID:DEVICE_V1_CHARACTERISTIC_BATTERY_LEVEL_UUID];
        if (!characteristic) return;
        [device.peripheral readValueForCharacteristic:characteristic];
    }
    
    [self delayBatteryLevelReading];
}

#pragma mark - Pairing

- (void)pairDeviceSuccess:(CBPeripheral *)peripheral {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSMutableArray *pairedDevices = [[preferences objectForKey:@"TT:devices:paired"] mutableCopy];
    if (!pairedDevices) {
        pairedDevices = [[NSMutableArray alloc] init];
    }
    [pairedDevices addObject:peripheral.identifier.UUIDString];
    [preferences setObject:pairedDevices forKey:@"TT:devices:paired"];
    [preferences synchronize];
    
    [buttonTimer resetPairingState];
    [self countDevices];
    [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    [appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_SUCCESS];

#ifdef DEBUG_CONNECT
//    NSLog(@" ---> (%X) [Pairing success] Canceling peripheral connection: %@", bluetoothState, foundDevice);
#endif
//    [manager cancelPeripheralConnection:peripheral];
}

- (void)disconnectUnpairedDevices {
    for (TTDevice *device in foundDevices) {
        if (!device.isPaired) {
#ifdef DEBUG_CONNECT
            NSLog(@" ---> (%X) [Disconnecting] Canceling peripheral connection: %@", bluetoothState, device);
#endif
            [manager cancelPeripheralConnection:device.peripheral];
        }
    }
    
    [self stopScan];
}

#pragma mark - Convenience methods

- (CBCharacteristic *)characteristicInPeripheral:(CBPeripheral *)peripheral
                                  andServiceUUID:(NSString *)serviceUUID
                           andCharacteristicUUID:(NSString *)characteristicUUID {
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:serviceUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristicUUID]]) {
                    return characteristic;
                }
            }
        }
    }
    
    return nil;
}

@end
