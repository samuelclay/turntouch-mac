//
//  TTModeAlarmClock.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/8/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeAlarmClock.h"
#import "NSDate+Extras.h"
#import "TTModeMusic.h"

@implementation TTModeAlarmClock

NSString *const kRepeatAlarmEnabled = @"repeatAlarmEnabled";
NSString *const kOnetimeAlarmEnabled = @"onetimeAlarmEnabled";
NSString *const kRepeatAlarmDays = @"repeatAlarmDays";
NSString *const kRepeatAlarmTime = @"repeatAlarmTime";
NSString *const kOnetimeAlarmDate = @"onetimeAlarmDate";
NSString *const kOnetimeAlarmTime = @"onetimeAlarmTime";
NSString *const kAlarmVolume = @"alarmVolume";
NSString *const kAlarmDuration = @"alarmDuration";
NSString *const kAlarmPlaylist = @"alarmPlaylist";
NSString *const kAlarmShuffle = @"alarmShuffle";

@synthesize repeatAlarmTimer;
@synthesize onetimeAlarmTimer;
@synthesize actionHUDController;
@synthesize audioPlayer;
@synthesize currentTrack;

#pragma mark - Mode

- (void)activate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self runAlarm];
    });
}

+ (NSString *)title {
    return @"Alarm";
}

+ (NSString *)description {
    return @"Wake up on time with music";
}

+ (NSString *)imageName {
    return @"mode_alarm.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeAlarmSnooze",
             @"TTModeAlarmNextSong",
             @"TTModeAlarmSongInfo",
             @"TTModeAlarmStop",
             @"TTModeAlarmVolumeUp",
             @"TTModeAlarmVolumeDown"
             ];
}

- (NSArray *)optionlessActions {
    return @[@"TTModeAlarmStop"];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeAlarmSnooze {
    return @"Snooze";
}
- (NSString *)titleTTModeAlarmNextSong {
    return @"Next Song";
}
- (NSString *)titleTTModeAlarmSongInfo {
    return @"Alarm Clock";
}
- (NSString *)titleTTModeAlarmStop {
    return @"Stop alarm";
}
- (NSString *)titleTTModeAlarmVolumeUp {
    return @"Volume up";
}
- (NSString *)titleTTModeAlarmVolumeDown {
    return @"Volume down";
}

#pragma mark - Action Images

- (NSString *)imageTTModeAlarmSnooze {
    return @"snooze.png";
}
- (NSString *)imageTTModeAlarmNextSong {
    return @"next_song.png";
}
- (NSString *)imageTTModeAlarmSongInfo {
    return @"song_info.png";
}
- (NSString *)imageTTModeAlarmStop {
    return @"stop_alarm.png";
}
- (NSString *)imageTTModeAlarmVolumeUp {
    return @"volume_up.png";
}
- (NSString *)imageTTModeAlarmVolumeDown {
    return @"volume_down.png";
}

#pragma mark - Action methods

- (void)runTTModeAlarmSnooze {
    NSLog(@"Running runTTModeAlarmSnooze");
}
- (void)runTTModeAlarmNextSong {
    NSLog(@"Running runTTModeAlarmNextSong");
    [self playNextSong];
    [self updateAlarmSongInfo];
}
- (void)runTTModeAlarmSongInfo {
    NSLog(@"Running runTTModeAlarmSongInfo");
}
- (void)runTTModeAlarmStop {
    NSLog(@"Running runTTModeAlarmStop");
}
- (void)runTTModeAlarmVolumeUp {
    NSLog(@"Running runTTModeAlarmVolumeUp");
}
- (void)runTTModeAlarmVolumeDown {
    NSLog(@"Running runTTModeAlarmVolumeDown");
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
    return @"TTModeAlarmVolumeDown";
}
- (NSString *)defaultInfo {
    return @"TTModeAlarmSongInfo";
}

#pragma mark - Layouts

- (ActionLayout)layoutTTModeAlarmSongInfo {
    return ACTION_LAYOUT_IMAGE_TITLE;
}

- (NSView *)viewForLayoutTTModeAlarmSongInfo:(NSRect)rect {
    return [TTModeMusic songInfoView:rect withTrack:currentTrack];
}

#pragma mark - Timer

- (NSDate *)nextRepeatAlarmDate {
    BOOL repeatAlarmEnabled = [[NSAppDelegate.modeMap mode:self optionValue:kRepeatAlarmEnabled] boolValue];
    NSInteger repeatAlarmTime = [[NSAppDelegate.modeMap mode:self optionValue:kRepeatAlarmTime] integerValue];
    NSArray *repeatDays = [NSAppDelegate.modeMap mode:self optionValue:kRepeatAlarmDays];
    
    if (!repeatAlarmEnabled) return nil;
    
    NSDate *midnightToday = [NSDate midnightToday];
    NSTimeInterval timeInterval = repeatAlarmTime * 5 * 60;
    NSDate *time = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:midnightToday];
    NSDateFormatter *dowFormatter = [[NSDateFormatter alloc] init];
    [dowFormatter setDateFormat:@"c"]; // Day of week, 7 = saturday
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSInteger offsetDayOfWeek = 0;
    NSInteger todayDayOfWeek = 0;

//    NSLog(@"Today's alarm: %@ / %@", time, midnightToday);
    NSString *dayOfWeekString = [dowFormatter stringFromDate:time];
    NSNumber *dayOfWeekNumber = [numberFormatter numberFromString:dayOfWeekString];
    todayDayOfWeek = [dayOfWeekNumber integerValue] - 1; // 0-6, not 1-7
    if ([time timeIntervalSinceDate:[NSDate date]] > 0) {
        // Alarm is later in the day
//        NSLog(@"Alarm is later in the day : %@ (%@)", time, dayOfWeekNumber);
        offsetDayOfWeek = [dayOfWeekNumber integerValue] - 1;
    } else {
        // Alarm is earlier in the day
//        NSLog(@"Alarm is earlier in the day : %@ (%@)", time, dayOfWeekNumber);
        offsetDayOfWeek = [dayOfWeekNumber integerValue];
    }
    
    // get day of week, compare to repeatDays, then cycle
    NSInteger d = 0;
    while (d < 7) {
        NSInteger dayOfWeek = (d + offsetDayOfWeek) % 7;
//        NSLog(@"Checking %ld (%ld+%ld - %ld) day of week...", (long)dayOfWeek, (long)d, (long)offsetDayOfWeek, (long)todayDayOfWeek);
        if ([[repeatDays objectAtIndex:dayOfWeek] boolValue]) {
            time = [time dateByAddingTimeInterval:60*60*24*(d+offsetDayOfWeek - todayDayOfWeek)];
//            NSLog(@"Found next date: %@", time);
            return time;
        }
        d++;
    }
    
    return nil;
}

- (NSDate *)nextOnetimeAlarmDate {
    BOOL onetimeAlarmEnabled = [[NSAppDelegate.modeMap mode:self optionValue:kOnetimeAlarmEnabled] boolValue];
    NSDate *oneTimeAlarmDate = [NSAppDelegate.modeMap mode:self optionValue:kOnetimeAlarmDate];
    NSInteger onetimeAlarmTime = [[NSAppDelegate.modeMap mode:self optionValue:kOnetimeAlarmTime] integerValue];
    
    if (!onetimeAlarmEnabled) return nil;
    
    NSTimeInterval timeInterval = onetimeAlarmTime * 5 * 60;
    NSDate *time = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:oneTimeAlarmDate];

    return time;
}

- (void)activateTimers {
    if (repeatAlarmTimer)  [repeatAlarmTimer invalidate];
    if (onetimeAlarmTimer) [onetimeAlarmTimer invalidate];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    NSDate *nextRepeatAlarmDate = [self nextRepeatAlarmDate];
    NSDate *nextOnetimeAlarmDate = [self nextOnetimeAlarmDate];

    if (nextRepeatAlarmDate &&
        [nextRepeatAlarmDate timeIntervalSinceDate:[NSDate date]] > 0) {
        repeatAlarmTimer = [[NSTimer alloc] initWithFireDate:nextRepeatAlarmDate
                                                    interval:0.f
                                                      target:self
                                                    selector:@selector(fireRepeatAlarm)
                                                    userInfo:nil repeats:NO];
        [runner addTimer:repeatAlarmTimer forMode: NSDefaultRunLoopMode];
        NSLog(@"Setting repeat alarm: %@", nextRepeatAlarmDate);
    }

    if (nextOnetimeAlarmDate &&
        [nextOnetimeAlarmDate timeIntervalSinceDate:[NSDate date]] > 0) {
        onetimeAlarmTimer = [[NSTimer alloc] initWithFireDate:nextOnetimeAlarmDate
                                                     interval:0.f
                                                       target:self
                                                     selector:@selector(fireOnetimeAlarm)
                                                     userInfo:nil repeats:NO];
        [runner addTimer:onetimeAlarmTimer forMode: NSDefaultRunLoopMode];
        NSLog(@"Setting one-time alarm: %@", nextOnetimeAlarmDate);
    }
}

- (void)fireRepeatAlarm {
    NSLog(@"Repeat Alarm fired: %@", [NSDate date]);
    dispatch_time_t time = dispatch_walltime(NULL, NSEC_PER_SEC * 1);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self activateTimers];
    });
    [self runAlarm];
}

- (void)fireOnetimeAlarm {
    NSLog(@"One-time Alarm fired: %@", [NSDate date]);
    [NSAppDelegate.modeMap changeMode:self option:kOnetimeAlarmEnabled to:[NSNumber numberWithBool:NO]];
    [self runAlarm];
}

#pragma mark - Alarm clock modal

- (void)runAlarm {
    [self playNextSong];
    [self updateAlarmSongInfo];
}

- (void)playNextSong {
    NSString *selectedPlaylist = (NSString *)[NSAppDelegate.modeMap mode:self optionValue:kAlarmPlaylist];
    SBElementArray *playlists = [self.class playlists];

    iTunesLibraryPlaylist *playlist;
    for (iTunesLibraryPlaylist *pl in playlists) {
        if ([pl.persistentID isEqualToString:selectedPlaylist]) {
            playlist = pl;
            break;
        }
    }
    
    SBElementArray *tracks = playlist.tracks;
    NSInteger tracksCount = tracks.count;
    NSLog(@"Playing %@ with %ld tracks: %@", playlist.name, (long)tracksCount, [tracks objectAtIndex:tracksCount/2]);
    if (audioPlayer) {
        [audioPlayer stop];
    }
    currentTrack = [[tracks objectAtIndex:round(arc4random()%tracksCount)] get];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:currentTrack.location error:nil];
    [audioPlayer play];
}

- (void)updateAlarmSongInfo {
    if (!actionHUDController) {
        actionHUDController = [[TTActionHUDWindowController alloc]
                               initWithWindowNibName:@"TTActionHUDView"];
    }
    [actionHUDController fadeIn:INFO withMode:self];
}

#pragma mark - Playlists

+ (SBElementArray *)playlists {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    iTunesSource *librarySource = nil;
    
    for (iTunesSource *source in iTunes.sources) {
        if ([source kind] == iTunesESrcLibrary) {
            librarySource = source;
            break;
        }
    }
    
    SBElementArray *playlists = [librarySource playlists];
    
    return playlists;
}

@end
