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

@implementation TTBluetoothMonitor

@synthesize batteryPct;
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
        characteristics = [[NSMutableDictionary alloc] init];
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
            [aPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID]]
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
//                NSLog(@"Found button status characteristic");
                [appDelegate.hudController toastActiveMode];
            }
//            /* Read body sensor location */
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
//            {
//                [aPeripheral readValueForCharacteristic:aChar];
//                NSLog(@"Found a Body Sensor Location Characteristic");
//            }
//            /* Write heart rate control point */
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])
//            {
//                uint8_t val = 1;
//                NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
//                [aPeripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
//            }
        }
    }
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_BATTERY_SERVICE_UUID]] ) {
        for (CBCharacteristic *aChar in service.characteristics) {
            /* Read device name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
                [aPeripheral readValueForCharacteristic:aChar];
//                NSLog(@"Found a Battery Characteristic");
            }
        }
    }

    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] ) {
        for (CBCharacteristic *aChar in service.characteristics) {
            /* Read device name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) {
                [aPeripheral readValueForCharacteristic:aChar];
//                NSLog(@"Found a Device Name Characteristic");
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            /* Read manufacturer name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) {
                [aPeripheral readValueForCharacteristic:aChar];
//                NSLog(@"Found a Device Manufacturer Name Characteristic: %@", aChar.value);
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
//            NSLog(@"Battery level: %d%%", value);
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
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DEVICE_CHARACTERISTIC_INTERVAL_MIN_UUID]]
                             forService:buttonStatusService];
}

- (void)peripheral:(CBPeripheral *)_peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    NSLog(@"did Update notification: %@ - %@ (%@)", _peripheral, characteristic, error);
}

- (void)deviceSentFirmwareSettings:(FirmwareSetting)setting {
    NSLog(@"Device sent firmware settings: %@", @(setting));
}

- (void)writeFirmwareConnectionValues {
    for (FirmwareSetting setting in @[FIRMWARE_INTERVAL_MIN, FIRMWARE_INTERVAL_MAX, FIRMWARE_CONN_LATENCY, FIRMWARE_CONN_TIMEOUT]) {
        CBCharacteristic *characteristic = 
    }
    peripheral writeValue:data forCharacteristic:<#(CBCharacteristic *)#> type:<#(CBCharacteristicWriteType)#>
}

@end
