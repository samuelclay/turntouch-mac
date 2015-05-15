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

#define DEVICE_SERVICE_BATTERY_UUID                 @"180F"
#define DEVICE_SERVICE_BUTTON_UUID                  @"88c3907a-dc4f-41b1-bb04-4e4deb81fadd"
#define DEVICE_SERVICE_FIRMWARE_SETTINGS_UUID       @"2f850855-71c4-4543-bcd3-9bc29d435390"

#define DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID    @"2a19"
#define DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID    @"47099164-4d08-4338-bedf-7fc043dbec5c"
#define DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID     @"0a02cefb-f546-4a56-ad2b-4aeadca0da6e"
#define DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID     @"50a71e79-f950-4973-9cbd-1ce5439603be"
#define DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID     @"3b6ef6e7-d9dc-4010-960a-a48bbe114935"
#define DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID     @"c6d87b9e-70c3-47ff-a534-e1ceb2bdf435"
#define DEVICE_CHARACTERISTIC_MODE_DURATION_UUID    @"bc382b21-1617-48cc-9e93-f4104561f71d"
#define DEVICE_CHARACTERISTIC_NICKNAME_UUID         @"6b8d8785-0b9b-4b13-bfe5-d71dd3b6ccc2"

const int BATTERY_LEVEL_READING_INTERVAL = 60*60*6; // every 6 hours

#define CLEAR_PAIRED_DEVICES 0

@implementation TTBluetoothMonitor

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
        default:
            return FALSE;
    }
    
    NSLog(@"Central manager state: %@", state);
    
    return FALSE;
}

#pragma mark - Start/Stop Scan methods

- (void)startScan {
    [self startScan:NO];
}

- (void)startScan:(BOOL)findUnpaired {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if (CLEAR_PAIRED_DEVICES || NO) {
        [preferences setObject:nil forKey:@"TT:devices:paired"];
        [preferences synchronize];
    }

    [self countDevices];

    if (findUnpaired || ![self knownPeripheralIdentifiers].count) {
        NSLog(@" ---> Scanning");
        [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:DEVICE_SERVICE_BUTTON_UUID]] options:nil];
    } else {
        NSLog(@" ---> Retrieving known: %@", [self knownPeripheralIdentifiers]);
        NSArray *peripherals = [manager retrievePeripheralsWithIdentifiers:[self knownPeripheralIdentifiers]];
        for (CBPeripheral *peripheral in peripherals) {
            if (peripheral.state != CBPeripheralStateDisconnected) {
                NSLog(@" ---> Already connected: %@", peripheral);
                continue;
            }
            NSLog(@" ---> Connecting to known: %@", peripheral);
            [foundDevices addPeripheral:peripheral];
            [manager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES],
                                                            CBCentralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES]}];
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * connectionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    onceToken = 0;
                    [self maybeScan];
                });
            });
        }
    }
}

- (void) stopScan {
    [manager stopScan];
}

- (void)maybeScan {
    [self countDevices];
    NSInteger knownCount = [[self knownPeripheralIdentifiers] count];
    NSInteger connectedCount = [[self pairedDevicesCount] integerValue];
    
    if (knownCount > connectedCount) {
        connectionDelay = MIN(5*60, 2*connectionDelay);
        NSLog(@" ---> Attemping connect to %ld/%ld still unconnected devices, delay: %ld sec", (knownCount-connectedCount), (long)knownCount, connectionDelay);
        [self stopScan];
        [self startScan];
    } else {
        connectionDelay = 5;
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
    if ([self isLECapableHardware]) {
        [self startScan];
    } else {
        [self stopScan];
        [self countDevices];
    }
}


- (void) terminate {
    for (TTDevice *device in foundDevices) {
        [manager cancelPeripheralConnection:device.peripheral];
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
    NSArray *peripherals = [manager retrievePeripheralsWithIdentifiers:@[(id)peripheral.identifier]];
    
    BOOL noPairedDevices = ![foundDevices totalPairedCount];
    
    for (CBPeripheral *peripheral in peripherals) {
        NSLog(@"Connecting bluetooth peripheral: %@ / %d", [peripheral.identifier.UUIDString substringToIndex:8], noPairedDevices);
        [foundDevices addPeripheral:peripheral];
        if (noPairedDevices) {
            [appDelegate showPreferences:@"pairing"];
        }

        [manager connectPeripheral:peripheral
                           options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES],
                                     CBCentralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES]}];
    }
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
        [peripheral discoverServices:@[[CBUUID UUIDWithString:DEVICE_SERVICE_BUTTON_UUID],
                                       [CBUUID UUIDWithString:DEVICE_SERVICE_BATTERY_UUID],
                                       [CBUUID UUIDWithString:DEVICE_SERVICE_FIRMWARE_SETTINGS_UUID]]];

        
        device.needsReconnection = NO;

        [self countDevices];
    } else {
        // Never seen device before, start the pairing process
        [peripheral discoverServices:@[[CBUUID UUIDWithString:DEVICE_SERVICE_BUTTON_UUID],
                                       [CBUUID UUIDWithString:DEVICE_SERVICE_BATTERY_UUID]]];
        
        device.needsReconnection = NO;
        
        [buttonTimer resetPairingState];
        [self countDevices];
    }

    [self startScan];
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected peripheral: %@", peripheral);
    
    [foundDevices removePeripheral:peripheral];
    [self countDevices];
    [self startScan];
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", peripheral, [error localizedDescription]);

    [foundDevices removePeripheral:peripheral];
    [self countDevices];
    [self startScan];
}

#pragma mark - CBPeripheral delegate methods

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
//        NSLog(@"Service found with UUID: %@", service.UUID);

        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SERVICE_BUTTON_UUID]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID]]
                                     forService:service];
        }

        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SERVICE_FIRMWARE_SETTINGS_UUID]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_MODE_DURATION_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_NICKNAME_UUID]]
                                     forService:service];
        }
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SERVICE_BATTERY_UUID]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID]]
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
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SERVICE_BUTTON_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SERVICE_FIRMWARE_SETTINGS_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_MODE_DURATION_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_NICKNAME_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID]]) {
//                [peripheral readValueForCharacteristic:aChar];
//            }
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID]]) {
//                [peripheral readValueForCharacteristic:aChar];
//            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SERVICE_BATTERY_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID]]) {
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
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID]]) {
        NSLog(@"Subscribed to button status notifications: %@", peripheral.identifier.UUIDString);
        
        TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
        device.isNotified = YES;
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

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID]]) {
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
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID]]) {
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
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID]]) {
        [characteristics setObject:characteristic forKey:@"interval_min"];
        [self device:peripheral sentFirmwareSettings:FIRMWARE_INTERVAL_MIN];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID]]) {
        [characteristics setObject:characteristic forKey:@"interval_max"];
        [self device:peripheral sentFirmwareSettings:FIRMWARE_INTERVAL_MAX];
//    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID]]) {
//        [characteristics setObject:characteristic forKey:@"conn_latency"];
//        [self device:peripheral sentFirmwareSettings:FIRMWARE_CONN_LATENCY];
//    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID]]) {
//        [characteristics setObject:characteristic forKey:@"conn_timeout"];
//        [self device:peripheral sentFirmwareSettings:FIRMWARE_CONN_TIMEOUT];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_NICKNAME_UUID]]) {
        if (!characteristic || !characteristic.value) return;
        TTDevice *device = [foundDevices deviceForPeripheral:peripheral];
        device.nickname = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        NSLog(@" ---> Hello %@", device);
        
        [self ensureNicknameOnDevice:device];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) {
//        NSString * deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        NSLog(@"Device Name = %@", deviceName);
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) {
        manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        NSLog(@"Manufacturer Name = %@", manufacturer);
    } else {
//        NSLog(@"Unidentified characteristic: %@", characteristic);
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
    NSLog(@"Did write value: %d", value);
    
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
                                                             andServiceUUID:DEVICE_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID];
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
                                                             andServiceUUID:DEVICE_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID];
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
                                                             andServiceUUID:DEVICE_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID];
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
                                                             andServiceUUID:DEVICE_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID];
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
                                                             andServiceUUID:DEVICE_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_CHARACTERISTIC_MODE_DURATION_UUID];
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
                                                             andServiceUUID:DEVICE_SERVICE_BATTERY_UUID
                                                      andCharacteristicUUID:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID];
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

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *preferenceKey = [NSString stringWithFormat:@"TT:device:%@:nickname", device.uuid.UUIDString];
    NSString *newNickname;
    NSString *localNickname = [prefs objectForKey:preferenceKey];
    NSMutableData *emptyNickname = [NSMutableData dataWithLength:32];
    NSMutableData *localNicknameData = [NSMutableData dataWithData:[localNickname dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *deviceNicknameData = [device.nickname dataUsingEncoding:NSUTF8StringEncoding];
    if (deviceNicknameData) {
        [localNicknameData increaseLengthBy:(deviceNicknameData.length-localNicknameData.length)];
    }
    
    BOOL hasLocalNickname = ![localNicknameData isEqualToData:emptyNickname];
    BOOL hasDeviceNickname = ![deviceNicknameData isEqualToData:emptyNickname];
    
    if (!hasLocalNickname && !hasDeviceNickname) {
        NSLog(@"Generating emoji nickname...");
        NSArray *emoji = @[@"🐱", @"🐼", @"🐶", @"🍒", @"⚽️", @"🎻", @"🎱", @"☀️", @"🌎", @"🌴", @"🌻"];
        NSString *randomEmoji = [emoji objectAtIndex:arc4random_uniform((uint32_t)emoji.count)];
        newNickname = [NSString stringWithFormat:@"The %@ Turn Touch Remote", randomEmoji];
        device.nickname = newNickname;
    } else if (hasLocalNickname && !hasDeviceNickname) {
        NSLog(@"Found local nickname, but no remote nickname...");
        newNickname = localNickname;
        device.nickname = localNickname;
    } else if (!hasLocalNickname && hasDeviceNickname) {
        NSLog(@"Found remote nickname, but no local nickname...");
        newNickname = device.nickname;
    } else if (hasLocalNickname && hasDeviceNickname) {
        if ([localNicknameData isEqualToData:deviceNicknameData]) {
            NSLog(@"Nicknames same: %@", device);
        } else {
            NSLog(@"Nicknames diff: %@ will get %@", device, localNickname);
            newNickname = localNickname;
        }
    }
    
    if (newNickname.length) {
        NSLog(@"New Nickname, Local %@, remote %@ => %@", localNickname, device.nickname, newNickname);
        NSData *data = [newNickname dataUsingEncoding:NSUTF8StringEncoding];
        CBCharacteristic *characteristic = [self characteristicInPeripheral:device.peripheral
                                                             andServiceUUID:DEVICE_SERVICE_FIRMWARE_SETTINGS_UUID
                                                      andCharacteristicUUID:DEVICE_CHARACTERISTIC_NICKNAME_UUID];
        
        [device.peripheral writeValue:data forCharacteristic:characteristic
                                 type:CBCharacteristicWriteWithResponse];

        [prefs setObject:newNickname forKey:preferenceKey];
        [prefs synchronize];
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
                                                             andServiceUUID:DEVICE_SERVICE_BATTERY_UUID
                                                      andCharacteristicUUID:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID];
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
