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
    return @[@"TTModeAlarmSnooze",
             @"TTModeAlarmNextSong",
             @"TTModeAlarmStop",
             @"TTModeAlarmQuiet"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeAlarmSnooze {
    return @"Snooze";
}
- (NSString *)titleTTModeAlarmNextSong {
    return @"Next Song";
}
- (NSString *)titleTTModeAlarmStop {
    return @"Stop alarm";
}
- (NSString *)titleTTModeAlarmQuiet {
    return @"Quiet down";
}

#pragma mark - Action Images

- (NSString *)imageTTModeAlarmSnooze {
    return @"snooze.png";
}
- (NSString *)imageTTModeAlarmNextSong {
    return @"next_song.png";
}
- (NSString *)imageTTModeAlarmStop {
    return @"stop_alarm.png";
}
- (NSString *)imageTTModeAlarmQuiet {
    return @"quiet_down.png";
}

#pragma mark - Action methods

- (void)runTTModeAlarmSnooze {
    NSLog(@"Running runTTModeAlarmSnooze");
}
- (void)runTTModeAlarmNextSong {
    NSLog(@"Running runTTModeAlarmNextSong");
}
- (void)runTTModeAlarmStop {
    NSLog(@"Running runTTModeAlarmStop");
}
- (void)runTTModeAlarmQuiet {
    NSLog(@"Running runTTModeAlarmQuiet");
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeAlarmSnooze";
}
- (NSString *)defaultEast {
    return @"TTModeAlarmNextSong";
}
- (NSString *)defaultWest {
    return @"TTModeAlarmStop";
}
- (NSString *)defaultSouth {
    return @"TTModeAlarmQuiet";
}

@end
