//
//  TTModeAlarmClock.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/8/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeAlarmClock.h"

@implementation TTModeAlarmClock

#pragma mark - Mode

+ (NSString *)title {
    return @"Alarm";
}

+ (NSString *)description {
    return @"Wake up on time with music";
}

+ (NSString *)imageName {
    return @"clock.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTAlarmSnooze",
             @"TTAlarmNextSong",
             @"TTAlarmStop",
             @"TTAlarmQuiet"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTAlarmSnooze {
    return @"Snooze";
}
- (NSString *)titleTTAlarmNextSong {
    return @"Next Song";
}
- (NSString *)titleTTAlarmStop {
    return @"Stop alarm";
}
- (NSString *)titleTTAlarmQuiet {
    return @"Quiet down";
}

#pragma mark - Action methods

- (void)runTTAlarmSnooze {
    NSLog(@"Running runTTAlarmSnooze");
}
- (void)runTTAlarmNextSong {
    NSLog(@"Running runTTAlarmNextSong");
}
- (void)runTTAlarmStop {
    NSLog(@"Running runTTAlarmStop");
}
- (void)runTTAlarmQuiet {
    NSLog(@"Running runTTAlarmQuiet");
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTAlarmSnooze";
}
- (NSString *)defaultEast {
    return @"TTAlarmNextSong";
}
- (NSString *)defaultWest {
    return @"TTAlarmStop";
}
- (NSString *)defaultSouth {
    return @"TTAlarmQuiet";
}

@end
