//
//  TTDevice.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTDevice.h"

@implementation TTDevice

@synthesize nickname;

- (id)initWithPeripheral:(CBPeripheral *)peripheral {
    if (self = [super init]) {
        self.peripheral = peripheral;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ / %@ (%@)", [self.peripheral.identifier.UUIDString substringToIndex:8], self.nickname, self.isPaired ? @"PAIRED" : @"unpaired"];
}

- (void)setNickname:(NSData *)nicknameData {
    NSMutableData *fixedNickname = [[NSMutableData alloc] init];

    const char *bytes = [nicknameData bytes];
    int dataLength = 0;
    for (int i=0; i < [nicknameData length]; i++) {
        if ((unsigned char)bytes[i] != 0x00) {
            dataLength = i;
        } else {
            break;
        }
    }
    [fixedNickname appendBytes:bytes length:dataLength+1];

    nickname = [[NSString alloc] initWithData:fixedNickname encoding:NSUTF8StringEncoding];
}

@end
