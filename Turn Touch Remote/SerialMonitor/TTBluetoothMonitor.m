//
//  TTBluetoothMonitor.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/19/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTBluetoothMonitor.h"
#import "NSData+Conversion.h"

#define DEVICE_BUTTON_SERVICE_UUID @"ddea706a-9d53-4bbb-ac0b-74ba819e7d9c"
#define DEVICE_BATTERY_SERVICE_UUID @"180F"
#define DEVICE_CHARACTERISTIC_BUTTON_STATUS_UUID @"f1c7c102-27bc-4074-aee6-35c58a3b31f6"
#define DEVICE_CHARACTERISTIC_BATTERY_LEVEL_UUID @"2a19"

@implementation TTBluetoothMonitor

@synthesize batteryPct;

- (instancetype)init {
    if (self = [super init]) {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        buttonTimer = [[TTButtonTimer alloc] init];
        batteryPct = [[NSNumber alloc] init];
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
    [self isLECapableHardware];
}


- (void) terminate {
    if (peripheral) {
        [manager cancelPeripheralConnection:peripheral];
    }
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
    
    [self stopScan];
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
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    NSLog(@"Disconnected peripheral: %@", aPeripheral);
    if( peripheral ) {
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
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
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

@end
