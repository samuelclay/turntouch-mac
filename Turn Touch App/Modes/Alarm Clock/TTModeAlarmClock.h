//
//  TTModeAlarmClock.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/8/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "TTMode.h"
#import "TTActionHUDWindowController.h"
#import "iTunes.h"

@class SBElementArray;

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
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) iTunesFileTrack *currentTrack;

- (NSDate *)nextRepeatAlarmDate;
+ (SBElementArray *)playlists;
+ (NSView *)songInfoView:(NSRect)rect withTrack:(iTunesTrack *)currentTrack;

@end
