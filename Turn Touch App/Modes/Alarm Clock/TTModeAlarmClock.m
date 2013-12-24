//
//  TTModeAlarmClock.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/8/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeAlarmClock.h"

@implementation TTModeAlarmClock

+ (NSString *)title {
    return @"Alarm Clock";
}

- (NSString *)imageName {
    return @"sun.png";
}

- (NSString *)titleNorth {
    return @"Snooze";
}

- (NSString *)titleEast {
    return @"Next Song";
}

- (NSString *)titleWest {
    return @"Unread Emails";
}

- (NSString *)titleSouth {
    return @"Stop Alarm";
}


@end
