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

#define CLEAR_PAIRED_DEVICES 0

@implementation TTBluetoothMonitor

@synthesize manager;
@synthesize buttonTimer;
@synthesize batteryPct;
@synthesize lastActionDate;
@synthesize foundDevices;
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
        pairedDevicesCount = [[NSNumber alloc] initWithInteger:0];
        unpairedDevicesCount = [[NSNumber alloc] initWithInteger:0];
    }
    return self;
}

- (BOOL) isLECapableHardware {
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
        default:
            state = @"Bluetooth not in any state!";
            
            break;
    }
    
    NSLog(@"Central manager state: %@ - %@/%ld", state, manager, manager.state);
    
    return FALSE;
}

#pragma mark - Start/Stop Scan methods

- (void)startScan:(BOOL)findUnpaired {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if (CLEAR_PAIRED_DEVICES || NO) {
        [preferences setObject:nil forKey:@"TT:devices:paired"];
        [preferences synchronize];
    }

    [self countDevices];

    if (findUnpaired || ![self knownPeripheralIdentifiers].count) {
        NSLog(@" ---> Scanning");
//        [manager scanForPeripheralsWithServices:nil options:nil];
        [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:DEVICE_V1_SERVICE_BUTTON_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_V2_SERVICE_BUTTON_UUID],
                                                  [CBUUID UUIDWithString:@"1523"]]
                                        options:nil];
    } else {
//        NSLog(@" ---> Retrieving known: %@", [self knownPeripheralIdentifiers]);
        NSArray *peripherals = [manager retrievePeripheralsWithIdentifiers:[self knownPeripheralIdentifiers]];
        for (CBPeripheral *peripheral in peripherals) {
            if ([foundDevices deviceForPeripheral:peripheral] && peripheral.state != CBPeripheralStateDisconnected) {
//                NSLog(@" ---> Already connected: %@/%@", [foundDevices deviceForPeripheral:peripheral], peripheral);
                continue;
            }
//            NSLog(@" ---> Connecting to known: %@", peripheral);
            [foundDevices addPeripheral:peripheral];
            NSDictionary *options = @{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES],
                                      CBCentralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES]};
            [manager connectPeripheral:peripheral options:options];
            static dispatch_once_t onceKnownToken;
            dispatch_once(&onceKnownToken, ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * connectionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    onceKnownToken = 0;
                    [self maybeScan:NO];
                });
            });

            static dispatch_once_t onceUnknownToken;
            dispatch_once(&onceUnknownToken, ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    onceUnknownToken = 0;
                    [self maybeScan:YES];
                    NSLog(@" ---> Starting scan for unpaired...");
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        NSLog(@" ---> Stopping scan for unpaired");
                        [self stopScan];
                    });
                });
            });
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * connectionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self countDevices];
        });
    }
}

- (void) stopScan {
    [manager stopScan];
}

- (void)maybeScan:(BOOL)findUnpaired {
    [self countDevices];
    NSInteger knownCount = [[self knownPeripheralIdentifiers] count];
    NSInteger connectedCount = [[self pairedDevicesCount] integerValue];
    
    if (knownCount > connectedCount) {
        connectionDelay = MIN(1*60, 1+connectionDelay);
        NSLog(@" ---> Attemping connect to %ld/%ld still unconnected devices, delay: %ld sec", (knownCount-connectedCount), (long)knownCount, connectionDelay);
        [self stopScan];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self startScan:findUnpaired];
        });
    } else {
        connectionDelay = 4;
    }
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

#pragma mark - CBCentralManager delegate methods

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"centralManagerDidUpdateState: %ld vs %ld", (long)central.state, (long)manager.state);
    manager = central;
    [self updateBluetoothState:NO];
}

- (void)updateBluetoothState:(BOOL)renew {
    if (renew) {
        NSLog(@"Renewing CB manager. Old: %@/%ld", manager, (long)manager.state);
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    if ([self isLECapableHardware]) {
        [self startScan:NO];
    } else {
        [self stopScan];
        [self countDevices];
    }
}

- (void) reconnect {
    [self stopScan];
    [self terminate];
    [self updateBluetoothState:YES];
}

- (void) terminate {
    for (TTDevice *device in foundDevices) {
        if (!device.peripheral) return;
        [manager cancelPeripheralConnection:device.peripheral];
        [foundDevices removeDevice:device];
    }
    manager = nil;
}

- (void)countDevices {
//    NSLog(@"Counting %d: %@", (int)foundDevices.count, foundDevices);
    
    [foundDevices ensureDevicesConnected];
    
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
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    NSLog(@"Found bluetooth peripheral: %@/%@ (%@)", localName, [peripheral.identifier.UUIDString substringToIndex:8], RSSI);
//    NSArray *peripherals = [manager retrievePeripheralsWithIdentifiers:@[(id)peripheral.identifier]];
    
    BOOL noPairedDevices = ![foundDevices totalPairedCount];
    
//    for (CBPeripheral *peripheral in peripherals) {
        NSLog(@"Connecting bluetooth peripheral: %@ / %d", [peripheral.identifier.UUIDString substringToIndex:8], noPairedDevices);
        [foundDevices addPeripheral:peripheral];
        if (noPairedDevices) {
            [appDelegate showPreferences:@"pairing"];
        }

        [manager connectPeripheral:peripheral
                           options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES],
                                     CBCentralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES]}];
//    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral.
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral setDelegate:self];
    NSLog(@"Connected bluetooth peripheral: %@", [peripheral.identifier.UUIDString substringToIndex:8]);

    TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
    if (device.isPaired) {
        // Seen device before, connect and discover services
        [peripheral discoverServices:@[[CBUUID UUIDWithString:DEVICE_V1_SERVICE_BUTTON_UUID],
                                       [CBUUID UUIDWithString:DEVICE_V1_SERVICE_BATTERY_UUID],
                                       [CBUUID UUIDWithString:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID],
                                       [CBUUID UUIDWithString:DEVICE_V2_SERVICE_BUTTON_UUID],
                                       [CBUUID UUIDWithString:DEVICE_V2_SERVICE_BATTERY_UUID]]];

        device.state = TTDeviceStateConnecting;
        device.needsReconnection = NO;

        [self countDevices];
    } else {
        // Never seen device before, start the pairing process
        [peripheral discoverServices:@[[CBUUID UUIDWithString:DEVICE_V1_SERVICE_BUTTON_UUID],
                                       [CBUUID UUIDWithString:DEVICE_V1_SERVICE_BATTERY_UUID],
                                       [CBUUID UUIDWithString:DEVICE_V2_SERVICE_BUTTON_UUID],
                                       [CBUUID UUIDWithString:DEVICE_V2_SERVICE_BATTERY_UUID]]];
        
        device.state = TTDeviceStateConnecting;
        device.needsReconnection = NO;

        [buttonTimer resetPairingState];
        [self countDevices];
    }

    [self startScan:NO];
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected peripheral: %@", peripheral);

    [foundDevices removePeripheral:peripheral];
    [self countDevices];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startScan:NO];
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
    
    NSLog(@"Fail to connect to peripheral: %@ (%@) with error = %@", peripheral.name, [peripheral.identifier.UUIDString substringToIndex:8], [error localizedDescription]);
    
    [foundDevices removePeripheral:peripheral];
    [self countDevices];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startScan:YES];
    });
}

#pragma mark - CBPeripheral delegate methods

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        NSLog(@"Service found with UUID: %@", service.UUID);
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
            device.firmwareVersion = 2;
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID]]
                                     forService:service];
        }

        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_V2_SERVICE_BATTERY_UUID]]) {
            device.firmwareVersion = 2;
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID]]
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
        NSLog(@"Subscribed to button status notifications: %@", [peripheral.identifier.UUIDString substringToIndex:8]);
        
        TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
        device.isNotified = YES;
        device.state = TTDeviceStateConnected;
        [self countDevices];
//        [appDelegate.hudController toastActiveMode];
    } else {
        NSLog(@"Subscribed to notifications: %@/%@", peripheral.identifier.UUIDString, characteristic.UUID.UUIDString);
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
            device.uuid = [CBUUID UUIDWithNSUUID:peripheral.identifier];
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
            NSLog(@" ---> !!! %@ has no nickname", peripheral);
        }
        TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
        device.nickname = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        NSLog(@" ---> Hello %@ / %@", characteristic.value, device);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self ensureNicknameOnDevice:device];
        });
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) {
        NSString * deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Device Name = %@", deviceName);
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) {
        manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Manufacturer Name = %@", manufacturer);
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

- (void)resetToDefaults {
    for (TTDevice *device in foundDevices) {
        if (!device.isPaired) continue;

        CBCharacteristic *characteristic = [self characteristicInPeripheral:device.peripheral
                                                             andServiceUUID:DEVICE_V1_SERVICE_BATTERY_UUID
                                                      andCharacteristicUUID:DEVICE_V1_CHARACTERISTIC_BATTERY_LEVEL_UUID];
        NSData *data = [[NSData alloc] initWithBytes:nil length:0];
        [device.peripheral writeValue:data forCharacteristic:characteristic
                                 type:CBCharacteristicWriteWithResponse];
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
    if (!device.isPaired) return;

    NSString *newNickname;
    NSMutableData *emptyNickname = [NSMutableData dataWithLength:32];
    NSData *deviceNicknameData = [device.nickname dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL hasDeviceNickname = ![deviceNicknameData isEqualToData:emptyNickname] && device.nickname.length;
    BOOL force = YES;
    force = NO;
    
    if (!hasDeviceNickname || force) {
        NSArray *emoji = @[@"🐱", @"🐼", @"🐶", @"🍒", @"⚽️", @"🎻", @"🎱", @"☀️", @"🌎", @"🌴", @"🌻", @"🌀", @"📚", @"🔮", @"📡", @"⛵️", @"🚲", @"⛄️", @"🍉"];
        NSString *randomEmoji = [emoji objectAtIndex:arc4random_uniform((uint32_t)emoji.count)];
        newNickname = [NSString stringWithFormat:@"%@ Turn Touch Remote", randomEmoji];

        NSLog(@"Generating emoji nickname: %@", newNickname);

        [self writeNickname:newNickname toDevice:device];
    }
}

- (void)writeNickname:(NSString *)newNickname toDevice:(TTDevice *)device {
    NSMutableData *data = [NSMutableData dataWithData:[newNickname dataUsingEncoding:NSUTF8StringEncoding]];

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
    
    if (device.firmwareVersion == 1) {
        characteristic = [self characteristicInPeripheral:device.peripheral
                                           andServiceUUID:DEVICE_V1_SERVICE_FIRMWARE_SETTINGS_UUID
                                    andCharacteristicUUID:DEVICE_V1_CHARACTERISTIC_NICKNAME_UUID];
    } else if (device.firmwareVersion == 2) {
        characteristic = [self characteristicInPeripheral:device.peripheral
                                           andServiceUUID:DEVICE_V2_SERVICE_BUTTON_UUID
                                    andCharacteristicUUID:DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID];
    }

    NSLog(@"New Nickname: => %@ (%@)", newNickname, data);
    
    [device.peripheral writeValue:data forCharacteristic:characteristic
                             type:CBCharacteristicWriteWithResponse];
    
    // Clear it again since it was padded out
    [self clearDataOfNullBytes:data];

    device.nickname = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
    [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    [appDelegate showPreferences:@"devices"];

    [manager cancelPeripheralConnection:peripheral];
}

- (void)disconnectUnpairedDevices {
    for (TTDevice *device in foundDevices) {
        if (!device.isPaired) {
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
