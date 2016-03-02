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
@synthesize firmwareVersion;
@synthesize isFirmwareOld;

- (id)initWithPeripheral:(CBPeripheral *)peripheral {
    if (self = [super init]) {
        self.peripheral = peripheral;
        self.uuid = peripheral.identifier.UUIDString;
        
        // Init with latest firmware version, correct later
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        firmwareVersion = [[prefs objectForKey:@"TT:firmware:version"] intValue];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ / %@ (%@-%@)",
            [self.uuid substringToIndex:8],
            self.nickname,
            self.state == TTDeviceStateConnected ? @"connected" : @"X",
            self.isPaired ? @"PAIRED" : @"unpaired"];
}

- (void)setNicknameData:(NSData *)nicknameData {
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

- (void)setFirmwareVersion:(int)_firmwareVersion {
    firmwareVersion = _firmwareVersion;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger latestVersion = [[prefs objectForKey:@"TT:firmware:version"] integerValue];

    if (firmwareVersion < latestVersion) {
        isFirmwareOld = YES;
    } else {
        isFirmwareOld = NO;
    }
}
@end
