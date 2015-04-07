//
//  TTBluetoothMonitor.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/19/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTBluetoothMonitor.h"
#import "NSData+Conversion.h"

#define DEVICE_BUTTON_SERVICE_UUID @"88c3907a-dc4f-41b1-bb04-4e4deb81fadd"
#define DEVICE_BATTERY_SERVICE_UUID @"180F"
#define DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID @"2a19"
#define DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID @"47099164-4d08-4338-bedf-7fc043dbec5c"
#define DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID @"0a02cefb-f546-4a56-ad2b-4aeadca0da6e"
#define DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID @"50a71e79-f950-4973-9cbd-1ce5439603be"
#define DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID @"3b6ef6e7-d9dc-4010-960a-a48bbe114935"
#define DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID @"c6d87b9e-70c3-47ff-a534-e1ceb2bdf435"

const int BATTERY_LEVEL_READING_DELAY = 60*60*24; // every 24 hours

@implementation TTBluetoothMonitor

@synthesize batteryPct;
@synthesize connectedDevices;
@synthesize connectedDevicesCount;
@synthesize firmwareIntervalMin;
@synthesize firmwareIntervalMax;
@synthesize firmwareConnLatency;
@synthesize firmwareConnTimeout;

- (instancetype)init {
    if (self = [super init]) {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        buttonTimer = [[TTButtonTimer alloc] init];
        batteryPct = [[NSNumber alloc] init];
        connectedDevicesCount = [[NSNumber alloc] init];
        connectedDevices = [[NSMutableArray alloc] init];
        characteristics = [[NSMutableDictionary alloc] init];
        firmwareIntervalMin = [[NSNumber alloc] init];
        firmwareIntervalMax = [[NSNumber alloc] init];
        firmwareConnLatency = [[NSNumber alloc] init];
        firmwareConnTimeout = [[NSNumber alloc] init];
        [self startScan];
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
    if (peripheral) {
        [manager cancelPeripheralConnection:peripheral];
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
 Invoked when the central discovers heart rate peripheral while scanning.
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral
      advertisementData:(NSDictionary *)advertisementData
                   RSSI:(NSNumber *)RSSI
{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    NSLog(@"Found bluetooth peripheral: %@/%@ (%@)", localName, advertisementData, RSSI);
    NSArray *peripherals = [manager retrievePeripheralsWithIdentifiers:@[(id)aPeripheral.identifier]];
    
    for (CBPeripheral *aPeripheral in peripherals) {
        peripheral = aPeripheral;
        [manager connectPeripheral:aPeripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES],
                                                         CBCentralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES]}];
    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:aPeripheral.identifier.UUIDString forKey:@"CB:last_identifier"];
    [preferences synchronize];
    
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:@[[CBUUID UUIDWithString:DEVICE_BUTTON_SERVICE_UUID],
                                    [CBUUID UUIDWithString:DEVICE_BATTERY_SERVICE_UUID]]];
    
    [connectedDevices addObject:aPeripheral];
    [self setValue:@(connectedDevices.count) forKey:@"connectedDevicesCount"];
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    NSLog(@"Disconnected peripheral: %@", aPeripheral);
    NSMutableArray *updatedConnectedDevices = [[NSMutableArray alloc] init];
    for (CBPeripheral *device in connectedDevices) {
        if (device == aPeripheral) continue;
        [updatedConnectedDevices addObject:device];
    }
    connectedDevices = updatedConnectedDevices;
    [self setValue:@(connectedDevices.count) forKey:@"connectedDevicesCount"];

    if(peripheral) {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }
    
    [self startScan];
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    if( peripheral ) {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }
    [self startScan];
}

#pragma mark - CBPeripheral delegate methods

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services) {
//        NSLog(@"Service found with UUID: %@", aService.UUID);

        if ([aService.UUID isEqual:[CBUUID UUIDWithString:DEVICE_BUTTON_SERVICE_UUID]]) {
            buttonStatusService = aService;
            [aPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID],
                                                   [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID],
                                                   [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID],
                                                   [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID],
                                                   [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID]]
                                      forService:aService];
        }
        
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:DEVICE_BATTERY_SERVICE_UUID]]) {
            [aPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID]]
                                      forService:aService];
        }
        
        /* Device Information Service */
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
            [aPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"2A29"]]
                                      forService:aService];
        }
        
        /* GAP (Generic Access Profile) for Device Name */
        if ( [aService.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] ) {
            [aPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CBUUIDDeviceNameString]]
                                      forService:aService];
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_BUTTON_SERVICE_UUID]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
                [appDelegate.hudController toastActiveMode];
            }
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
                [aPeripheral readValueForCharacteristic:aChar];
                [self delayBatteryLevelReading];
            }
        }
    }

    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] ) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) {
                [aPeripheral readValueForCharacteristic:aChar];
            }
        }
    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral
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
            int value = bytes[0]; // first byte
            NSLog(@"Battery level: %d%%", value);
            [self setValue:@(value) forKey:@"batteryPct"];
        }
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID]]) {
        [characteristics setObject:characteristic forKey:@"interval_min"];
        [self deviceSentFirmwareSettings:FIRMWARE_INTERVAL_MIN];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID]]) {
        [characteristics setObject:characteristic forKey:@"interval_max"];
        [self deviceSentFirmwareSettings:FIRMWARE_INTERVAL_MAX];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID]]) {
        [characteristics setObject:characteristic forKey:@"conn_latency"];
        [self deviceSentFirmwareSettings:FIRMWARE_CONN_LATENCY];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID]]) {
        [characteristics setObject:characteristic forKey:@"conn_timeout"];
        [self deviceSentFirmwareSettings:FIRMWARE_CONN_TIMEOUT];
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

#pragma mark - Connection Attributes Firmware Updates

/*
 Invoked upon the peripheral notifying the server about a characteristic's value changing.
 */
- (void)retrieveFirmwareSettings {
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID],
                                          [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MAX_UUID],
                                          [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_LATENCY_UUID],
                                          [CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_CONN_TIMEOUT_UUID]]
                             forService:buttonStatusService];
}

- (void)peripheral:(CBPeripheral *)_peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    NSLog(@"did Update notification: %@ - %d (%@)", characteristic.UUID, characteristic.isNotifying, error);
}


- (void)deviceSentFirmwareSettings:(FirmwareSetting)setting {
    NSLog(@"Device sent firmware settings: %d", setting);
    if (setting == FIRMWARE_INTERVAL_MIN) {
        CBCharacteristic *characteristic = [characteristics objectForKey:@"interval_min"];
        if (!characteristic.value) return;
        int value;
        [characteristic.value getBytes:&value length:2];
        NSLog(@"Was %@, now %@", firmwareIntervalMin, @(value));
        [self setValue:@(value) forKey:@"firmwareIntervalMin"];
    }
    if (setting == FIRMWARE_INTERVAL_MAX) {
        CBCharacteristic *characteristic = [characteristics objectForKey:@"interval_max"];
        if (!characteristic.value) return;
        int value;
        [characteristic.value getBytes:&value length:2];
        NSLog(@"Was %@, now %@", firmwareIntervalMax, @(value));
        [self setValue:@(value) forKey:@"firmwareIntervalMax"];
    }
    if (setting == FIRMWARE_CONN_LATENCY) {
        CBCharacteristic *characteristic = [characteristics objectForKey:@"conn_latency"];
        if (!characteristic.value) return;
        int value;
        [characteristic.value getBytes:&value length:2];
        NSLog(@"Was %@, now %@", firmwareConnLatency, @(value));
        [self setValue:@(value) forKey:@"firmwareConnLatency"];
    }
    if (setting == FIRMWARE_CONN_TIMEOUT) {
        CBCharacteristic *characteristic = [characteristics objectForKey:@"conn_timeout"];
        if (!characteristic.value) return;
        int value;
        [characteristic.value getBytes:&value length:2];
//        if (firmwareConnTimeout.intValue != value) {
            NSLog(@"Was %@, now %@", firmwareConnTimeout, @(value));
            [self setValue:@(value) forKey:@"firmwareConnTimeout"];
            [self writeFirmwareConnectionValues];
//        }
    }
}

- (void)writeFirmwareConnectionValues {
    NSLog(@"Writing firmware connection values...");
    CBCharacteristic *characteristic = [characteristics objectForKey:@"interval_min"];
    uint16_t value = firmwareIntervalMin.intValue - 10;
    NSLog(@"  interval_min length: %s - %d", (void*)&value, sizeof(value));
    NSData *data = [NSData dataWithBytes:(void*)&value length:2];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    
    characteristic = [characteristics objectForKey:@"interval_max"];
    value = firmwareIntervalMax.intValue - 10;
    data = [NSData dataWithBytes:(void*)&value length:2];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    
    characteristic = [characteristics objectForKey:@"conn_latency"];
    value = firmwareConnLatency.intValue;
    data = [NSData dataWithBytes:(void*)&value length:2];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];

    characteristic = [characteristics objectForKey:@"conn_timeout"];
    value = firmwareConnTimeout.intValue;
    data = [NSData dataWithBytes:(void*)&value length:2];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    int value;
    [characteristic.value getBytes:&value length:2];
    NSLog(@"Did write value: %d", value);
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
        for (CBService *service in peripheral.services) {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_BATTERY_SERVICE_UUID]]) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID]]) {
                        [peripheral readValueForCharacteristic:characteristic];
                    }
                }
            }
        }
    }
    
    [self delayBatteryLevelReading];
}

@end
