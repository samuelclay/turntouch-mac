//
//  TTDevice.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

@interface TTDevice : NSObject

@property (nonatomic) NSString *nickname;
@property (nonatomic) CBUUID *uuid;
@property (nonatomic) CBPeripheral *peripheral;
@property (nonatomic) NSNumber *batteryPct;
@property (nonatomic) NSDate *lastActionDate;

- (id)initWithPeripheral:(CBPeripheral *)peripheral;

@end
