//
//  TTBluetoothMonitor.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/19/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTBluetoothMonitor.h"
#import "NSData+Conversion.h"

#define DEVICE_BATTERY_SERVICE_UUID                 @"180F"
#define DEVICE_BUTTON_SERVICE_UUID                  @"88c3907a-dc4f-41b1-bb04-4e4deb81fadd"
#define DEVICE_FIRMWARE_SETTINGS_SERVICE_UUID       @"2f850855-71c4-4543-bcd3-9bc29d435390"

#define DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID    @"2a19"
#define DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID    @"47099164-4d08-4338-bedf-7fc043dbec5c"
#define DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID     @"0a02cefb-f546-4a56-ad2b-4aeadca0da6e"
#define DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID     @"50a71e79-f950-4973-9cbd-1ce5439603be"
#define DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID     @"3b6ef6e7-d9dc-4010-960a-a48bbe114935"
#define DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID     @"c6d87b9e-70c3-47ff-a534-e1ceb2bdf435"

const int BATTERY_LEVEL_READING_DELAY = 60*60*6; // every 6 hours

@implementation TTBluetoothMonitor

@synthesize batteryPct;
@synthesize foundDevices;
@synthesize connectedDevices;
@synthesize connectedDevicesCount;

- (instancetype)init {
    if (self = [super init]) {

        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        buttonTimer = [[TTButtonTimer alloc] init];
        batteryPct = [[NSNumber alloc] init];
        connectedDevicesCount = [[NSNumber alloc] init];
        connectedDevices = [[NSMutableArray alloc] init];
        foundDevices = [[NSMutableArray alloc] init];
        characteristics = [[NSMutableDictionary alloc] init];

//        [self startScan];
    }
    return self;
}

#pragma mark - Start/Stop Scan methods

- (void) startScan {
    [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:DEVICE_BUTTON_SERVICE_UUID]] options:nil];
}

- (void) stopScan {
    [manager stopScan];
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
    for (CBPeripheral *device in connectedDevices) {
        [manager cancelPeripheralConnection:device];
    }
}

- (void)countDevices {
    NSLog(@"Counting: %@", connectedDevices);
    NSMutableArray *updatedConnectedDevices = [[NSMutableArray alloc] init];
    for (CBPeripheral *device in connectedDevices) {
        if (device.state == CBPeripheralStateConnected) {
            [updatedConnectedDevices addObject:device];
        }
    }
    connectedDevices = updatedConnectedDevices;
    [self setValue:@(connectedDevices.count) forKey:@"connectedDevicesCount"];
}

/*
 Invoked when the central discovers peripheral while scanning.
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
      advertisementData:(NSDictionary *)advertisementData
                   RSSI:(NSNumber *)RSSI
{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    NSLog(@"Found bluetooth peripheral: %@/%@ (%@)", localName, peripheral.identifier.UUIDString, RSSI);
    NSArray *peripherals = [manager retrievePeripheralsWithIdentifiers:@[(id)peripheral.identifier]];
    
    for (CBPeripheral *device in peripherals) {
        [foundDevices addObject:device];
        [manager connectPeripheral:device options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES],
                                                        CBCentralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES]}];
    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral.
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:peripheral.identifier.UUIDString forKey:@"CB:last_identifier"];
    [preferences synchronize];
    
    [peripheral setDelegate:self];
    [peripheral discoverServices:@[[CBUUID UUIDWithString:DEVICE_BUTTON_SERVICE_UUID],
                                   [CBUUID UUIDWithString:DEVICE_BATTERY_SERVICE_UUID],
                                   [CBUUID UUIDWithString:DEVICE_FIRMWARE_SETTINGS_SERVICE_UUID]]];
    
    [connectedDevices addObject:peripheral];
    [self countDevices];
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected peripheral: %@", peripheral);
    NSMutableArray *updatedConnectedDevices = [[NSMutableArray alloc] init];
    for (CBPeripheral *device in connectedDevices) {
        if (device == peripheral) {
            [peripheral setDelegate:nil];
            peripheral = nil;
        } else {
            [updatedConnectedDevices addObject:device];
        }
    }
    connectedDevices = updatedConnectedDevices;
    [self countDevices];
    
    [self startScan];
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", peripheral, [error localizedDescription]);
    NSMutableArray *updatedConnectedDevices = [[NSMutableArray alloc] init];
    for (CBPeripheral *device in connectedDevices) {
        if (device == peripheral) {
            [peripheral setDelegate:nil];
            peripheral = nil;
        } else {
            [updatedConnectedDevices addObject:device];
        }
    }
    connectedDevices = updatedConnectedDevices;
    [self countDevices];

    [self startScan];
}

#pragma mark - CBPeripheral delegate methods

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
//        NSLog(@"Service found with UUID: %@", service.UUID);

        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_BUTTON_SERVICE_UUID]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID]]
                                     forService:service];
        }

        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_FIRMWARE_SETTINGS_SERVICE_UUID]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID]]
                                     forService:service];
        }
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_BATTERY_SERVICE_UUID]]) {
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
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_BUTTON_SERVICE_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_FIRMWARE_SETTINGS_SERVICE_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID]]) {
                [peripheral readValueForCharacteristic:aChar];
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_BATTERY_SERVICE_UUID]]) {
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
    /* Updated value for heart rate measurement received */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID]]) {
        if( (characteristic.value)  || !error ) {
//            NSLog(@"Characteristic value: %@", [characteristic.value hexadecimalString]);
            [buttonTimer readBluetoothData:characteristic.value];
        } else {
            NSLog(@"Characteristic error: %@ / %@", characteristic.value, error);
        }
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID]]) {
        if( (characteristic.value)  || !error ) {
            const uint8_t *bytes = [characteristic.value bytes]; // pointer to the bytes in data
            uint16_t value = bytes[0]; // first byte
            NSLog(@"Battery level: %d%%", value);
            [self setValue:@(value) forKey:@"batteryPct"];
        }
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID]]) {
        [characteristics setObject:characteristic forKey:@"interval_min"];
        [self device:peripheral sentFirmwareSettings:FIRMWARE_INTERVAL_MIN];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID]]) {
        [characteristics setObject:characteristic forKey:@"interval_max"];
        [self device:peripheral sentFirmwareSettings:FIRMWARE_INTERVAL_MAX];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID]]) {
        [characteristics setObject:characteristic forKey:@"conn_latency"];
        [self device:peripheral sentFirmwareSettings:FIRMWARE_CONN_LATENCY];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID]]) {
        [characteristics setObject:characteristic forKey:@"conn_timeout"];
        [self device:peripheral sentFirmwareSettings:FIRMWARE_CONN_TIMEOUT];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) {
//        NSString * deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        NSLog(@"Device Name = %@", deviceName);
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) {
        manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        NSLog(@"Manufacturer Name = %@", manufacturer);
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
    NSLog(@"Did write value: %d", value);
}


#pragma mark - Connection Attributes Firmware Updates

/*
 Invoked upon the peripheral notifying the server about a characteristic's value changing.
 */
- (void)retrieveFirmwareSettings:(CBPeripheral *)peripheral {
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_FIRMWARE_SETTINGS_SERVICE_UUID]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID],
                                                  [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID]]
                                     forService:service];
        }
    }
}

- (void)device:(CBPeripheral *)peripheral sentFirmwareSettings:(FirmwareSetting)setting {
    NSLog(@"Device sent firmware settings: %d", setting);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    uint16_t firmwareIntervalMin = [[prefs objectForKey:@"TT:firmware:interval_min"] intValue];
    uint16_t firmwareIntervalMax = [[prefs objectForKey:@"TT:firmware:interval_max"] intValue];
    uint16_t firmwareConnLatency = [[prefs objectForKey:@"TT:firmware:conn_latency"] intValue];
    uint16_t firmwareConnTimeout = [[prefs objectForKey:@"TT:firmware:conn_timeout"] intValue];
    
    if (setting == FIRMWARE_INTERVAL_MIN) {
        CBCharacteristic *characteristic = [characteristics objectForKey:@"interval_min"];
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
        CBCharacteristic *characteristic = [characteristics objectForKey:@"interval_max"];
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
        CBCharacteristic *characteristic = [characteristics objectForKey:@"conn_latency"];
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
        CBCharacteristic *characteristic = [characteristics objectForKey:@"conn_timeout"];
        if (!characteristic.value) return;
        uint16_t value;
        [characteristic.value getBytes:&value length:2];
        if (firmwareConnTimeout != value) {
            NSLog(@"Server %d, remote %d", firmwareConnTimeout, value);
            NSData *data = [NSData dataWithBytes:(void*)&firmwareConnTimeout length:2];
            [peripheral writeValue:data forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
        }
    }
}

- (void)resetToDefaults {
    for (CBPeripheral *peripheral in connectedDevices) {
        CBCharacteristic *characteristic = [self characteristicInPeripheral:peripheral
                                                             andServiceUUID:DEVICE_BATTERY_SERVICE_UUID
                                                      andCharacteristicUUID:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID];
        NSData *data = [[NSData alloc] initWithBytes:nil length:0];
        [peripheral writeValue:data forCharacteristic:characteristic
                          type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - Battery level

- (void)delayBatteryLevelReading {
    if (batteryLevelTimer) {
        [batteryLevelTimer invalidate];
        batteryLevelTimer = nil;
    }
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:BATTERY_LEVEL_READING_DELAY];
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
    for (CBPeripheral *peripheral in connectedDevices) {
        CBCharacteristic *characteristic = [self characteristicInPeripheral:peripheral
                                                             andServiceUUID:DEVICE_BATTERY_SERVICE_UUID
                                                      andCharacteristicUUID:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID];
        [peripheral readValueForCharacteristic:characteristic];
    }
    
    [self delayBatteryLevelReading];
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
