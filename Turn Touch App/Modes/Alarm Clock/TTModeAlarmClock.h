//
//  TTModeAlarmClock.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/8/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "TTActionHUDWindowController.h"

@interface TTModeAlarmClock : TTMode

extern NSString *const kRepeatAlarmEnabled;
extern NSString *const kOnetimeAlarmEnabled;
extern NSString *const kRepeatAlarmDays;
extern NSString *const kRepeatAlarmTime;
extern NSString *const kOnetimeAlarmDate;
extern NSString *const kOnetimeAlarmTime;
extern NSString *const kAlarmVolume;
extern NSString *const kAlarmDuration;
extern NSString *const kAlarmPlaylist;
extern NSString *const kAlarmShuffle;

@property (nonatomic, readwrite) NSTimer *repeatAlarmTimer;
@property (nonatomic, readwrite) NSTimer *onetimeAlarmTimer;
@property (nonatomic) TTActionHUDWindowController *actionHUDController;

- (NSDate *)nextRepeatAlarmDate;

@end
