//
//  TTDevice.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTDevice.h"

@implementation TTDevice

- (id)initWithPeripheral:(CBPeripheral *)peripheral {
    if (self = [super init]) {
        self.peripheral = peripheral;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ / %@ (%@)", [self.uuid.UUIDString substringToIndex:8], self.nickname, self.isPaired ? @"PAIRED" : @"unpaired"];
}

@end
