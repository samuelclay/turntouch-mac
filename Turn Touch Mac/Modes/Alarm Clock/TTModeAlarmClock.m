//
//  TTModeAlarmClock.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/8/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeAlarmClock.h"
#import "NSDate+Extras.h"
#import "TTModeMusic.h"
#import "TTModeMac.h"

@interface TTModeAlarmClock ()

@property (nonatomic) NSInteger trackIndex;
@property (nonatomic, strong) SBElementArray *tracks;
@property (nonatomic) CGFloat originalSystemVolume;
@property (nonatomic) CGFloat volumeFadeMultiplier;
@property (nonatomic) TTModeAlarmClockStatus status;
@property (nonatomic, strong) NSTimer *volumeFadeTimer;

@end

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
NSString *const kAlarmSnoozeDuration = @"alarmSnoozeDuration";

#pragma mark - Mode

- (void)activate {
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self runAlarm];
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
- (NSString *)doubleTitleTTModeAlarmSnooze {
    return @"Stop alarm";
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
    return @"alarm_snooze.png";
}
- (NSString *)imageTTModeAlarmNextSong {
    return @"music_ff.png";
}
- (NSString *)imageTTModeAlarmSongInfo {
    return @"song_info.png";
}
- (NSString *)imageTTModeAlarmStop {
    return @"alarm_off.png";
}
- (NSString *)imageTTModeAlarmVolumeUp {
    return @"music_volume_up.png";
}
- (NSString *)imageTTModeAlarmVolumeDown {
    return @"music_volume_down.png";
}

#pragma mark - Action methods

- (void)runTTModeAlarmSnooze {
    NSLog(@"Running runTTModeAlarmSnooze");
    [self snoozeAlarm];
}
- (void)doubleRunTTModeAlarmSnooze {
    NSLog(@"Running doubleRunTTModeAlarmSnooze");
    [self stopAlarm];
}
- (void)runTTModeAlarmNextSong {
    NSLog(@"Running runTTModeAlarmNextSong");
    [self playNextSong];
}
- (void)runTTModeAlarmSongInfo {
    NSLog(@"Running runTTModeAlarmSongInfo");
}
- (void)runTTModeAlarmStop {
    NSLog(@"Running runTTModeAlarmStop");
    [self stopAlarm];
}
- (void)runTTModeAlarmVolumeUp {
    CGFloat volume = [TTModeMac volume];
    [TTModeMac setVolume:volume + 0.03f];
    NSLog(@"Running runTTModeAlarmVolumeUp: from %f to %f", volume, volume + 0.03f);
}
- (void)runTTModeAlarmVolumeDown {
    CGFloat volume = [TTModeMac volume];
    if (volume <= 0.03f) volume = 0.03f;
    NSLog(@"Running runTTModeAlarmVolumeDown: from %f to %f", volume, volume - 0.03f);
    [TTModeMac setVolume:volume - 0.03f];
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeAlarmVolumeUp";
}
- (NSString *)defaultEast {
    return @"TTModeAlarmNextSong";
}
- (NSString *)defaultWest {
    return @"TTModeAlarmSnooze";
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
    return [TTModeMusic songInfoView:rect withTrack:self.currentTrack];
}

- (BOOL)hideActionMenu {
    return YES;
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
    if (self.repeatAlarmTimer)  [self.repeatAlarmTimer invalidate];
    if (self.onetimeAlarmTimer) [self.onetimeAlarmTimer invalidate];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    NSDate *nextRepeatAlarmDate = [self nextRepeatAlarmDate];
    NSDate *nextOnetimeAlarmDate = [self nextOnetimeAlarmDate];

    if (nextRepeatAlarmDate &&
        [nextRepeatAlarmDate timeIntervalSinceDate:[NSDate date]] > 0) {
        self.repeatAlarmTimer = [[NSTimer alloc] initWithFireDate:nextRepeatAlarmDate
                                                    interval:0.f
                                                      target:self
                                                    selector:@selector(fireRepeatAlarm)
                                                    userInfo:nil repeats:NO];
        [runner addTimer:self.repeatAlarmTimer forMode: NSDefaultRunLoopMode];
        NSLog(@"Setting repeat alarm: %@", nextRepeatAlarmDate);
    }

    if (nextOnetimeAlarmDate &&
        [nextOnetimeAlarmDate timeIntervalSinceDate:[NSDate date]] > 0) {
        self.onetimeAlarmTimer = [[NSTimer alloc] initWithFireDate:nextOnetimeAlarmDate
                                                     interval:0.f
                                                       target:self
                                                     selector:@selector(fireOnetimeAlarm)
                                                     userInfo:nil repeats:NO];
        [runner addTimer:self.onetimeAlarmTimer forMode: NSDefaultRunLoopMode];
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
    [self runAlarm];
    [NSAppDelegate.modeMap changeMode:self option:kOnetimeAlarmEnabled to:[NSNumber numberWithBool:NO]];
}

- (void)startStopAlarmTimer {
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    NSInteger alarmDuration = [[NSAppDelegate.modeMap mode:self optionValue:kAlarmDuration] integerValue];
    NSDate *stopAlarmDate = [[NSDate date] dateByAddingTimeInterval:alarmDuration * 60];
    self.stopAlarmTimer = [[NSTimer alloc] initWithFireDate:stopAlarmDate
                                                interval:0.f
                                                  target:self
                                                selector:@selector(stopAlarm)
                                                userInfo:nil repeats:NO];
    [runner addTimer:self.stopAlarmTimer forMode: NSDefaultRunLoopMode];
    NSLog(@"Setting stop alarm timer: %@", stopAlarmDate);
}

#pragma mark - Alarm clock modal

- (void)runAlarm {
    if (self.status != ALARM_CLOCK_STATUS_OFF) {
        [self stopAlarm];
    }
    
    self.status = ALARM_CLOCK_STATUS_ON;
    self.originalSystemVolume = [TTModeMac volume];
    self.volumeFadeMultiplier = 0.10;
    NSInteger prefVolume = [[NSAppDelegate.modeMap mode:self optionValue:kAlarmVolume] integerValue];
    [TTModeMac setVolume:(prefVolume / 100.f) * self.volumeFadeMultiplier];
    
    self.tracks = [self selectedPlaylistTracks];
    [self seedRandomTracks:self.tracks.count];
    [self playNextSong];
    [self startStopAlarmTimer];
    [self switchSelectedModeTo:self];
    [self fadeVolumeIn];
}

- (SBElementArray *)selectedPlaylistTracks {
    NSString *selectedPlaylist = (NSString *)[NSAppDelegate.modeMap mode:self optionValue:kAlarmPlaylist];
    SBElementArray *playlists = [self.class playlists];
    
    iTunesLibraryPlaylist *playlist;
    for (iTunesLibraryPlaylist *pl in playlists) {
        if ([pl.persistentID isEqualToString:selectedPlaylist]) {
            playlist = pl;
            break;
        }
    }
    
    SBElementArray *playlistTracks = playlist.tracks;
    return playlistTracks;
}

- (void)playNextSong {
    if (self.status == ALARM_CLOCK_STATUS_OFF) return;
    
    if (!self.tracks) {
        self.tracks = [self selectedPlaylistTracks];
    }
    NSInteger tracksCount = self.tracks.count;
    if (!tracksCount) return;
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
    NSInteger randomTrackIndex = [[self.randomTracks objectAtIndex:(self.trackIndex % tracksCount)] integerValue];
    self.currentTrack = [[self.tracks objectAtIndex:randomTrackIndex] get];
    NSLog(@"Random track: %ld / %ld: %@", (long)self.trackIndex, (long)randomTrackIndex, self.currentTrack);
    self.trackIndex += 1;

    if (![self.currentTrack respondsToSelector:@selector(location)]) {
        NSLog(@" ---> !! Track has no location, skipping...");
        [self playNextSong];
        return;
    }
    
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.currentTrack.location error:nil];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    [self.audioPlayer setDelegate:self];
    
    [self updateAlarmSongInfo];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [self playNextSong];
    }
}

- (void)seedRandomTracks:(NSInteger)count {
    self.trackIndex = 0;
    self.randomTracks = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < count; ++i) {
        [self.randomTracks addObject:[NSNumber numberWithInteger:i]];
    }
    
    NSMutableArray *copy = [self.randomTracks mutableCopy];
    self.randomTracks = [[NSMutableArray alloc] init];
    while ([copy count] > 0) {
        int index = arc4random_uniform((int)[copy count]);
        id objectToMove = [copy objectAtIndex:index];
        [self.randomTracks addObject:objectToMove];
        [copy removeObjectAtIndex:index];
    }
}

- (void)updateAlarmSongInfo {
    if (!self.actionHUDController) {
        self.actionHUDController = [[TTActionHUDWindowController alloc]
                               initWithWindowNibName:@"TTActionHUDView"];
    }
    [self.actionHUDController fadeIn:@"TTModeAlarmSongInfo" inDirection:INFO withMode:self];
}

- (void)snoozeAlarm {
    if (self.status != ALARM_CLOCK_STATUS_ON) return;

    self.status = ALARM_CLOCK_STATUS_SNOOZING;
    [self.audioPlayer stop];
    [self.actionHUDController fadeOut:nil];
    [TTModeMac setVolume:self.originalSystemVolume];
    
    NSTimeInterval snoozeDuration = [[NSAppDelegate.modeMap mode:self optionValue:kAlarmSnoozeDuration] integerValue];
    NSDate *snoozeDate = [[NSDate date] dateByAddingTimeInterval:snoozeDuration*60];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    self.repeatAlarmTimer = [[NSTimer alloc] initWithFireDate:snoozeDate
                                                interval:0.f
                                                  target:self
                                                selector:@selector(fireRepeatAlarm)
                                                userInfo:nil repeats:NO];
    [runner addTimer:self.repeatAlarmTimer forMode: NSDefaultRunLoopMode];
    NSLog(@"Snoozing for %f minutes: %@", snoozeDuration, snoozeDate);
}

- (void)stopAlarm {
    if (self.status != ALARM_CLOCK_STATUS_SNOOZING && self.status != ALARM_CLOCK_STATUS_ON) return;
    
    self.status = ALARM_CLOCK_STATUS_OFF;
    if (self.stopAlarmTimer) [self.stopAlarmTimer invalidate];
    [self.audioPlayer stop];
    [self.actionHUDController fadeOut:nil];
    if (self.originalSystemVolume) {
        [TTModeMac setVolume:self.originalSystemVolume];
    }
    if (self.volumeFadeTimer) {
        [self.volumeFadeTimer invalidate];
    }
    [self activateTimers];
}

- (void)fadeVolumeIn {
    self.volumeFadeMultiplier += 0.01;
    NSInteger prefVolume = [[NSAppDelegate.modeMap mode:self optionValue:kAlarmVolume] integerValue];
    [TTModeMac setVolume:(prefVolume / 100.f) * self.volumeFadeMultiplier];
    
    if (self.volumeFadeTimer) {
        [self.volumeFadeTimer invalidate];
    }
    
    if (self.volumeFadeMultiplier >= 1.0) {
        NSLog(@"Done fading in volume.");
        return;
    }
    
    if (![self.stopAlarmTimer isValid]) {
        NSLog(@"Alarm stopped before volume fade completed.");
        return;
    }
    
    NSDate *volumeBumpDate = [[NSDate date] dateByAddingTimeInterval:(10)/100.f];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    self.volumeFadeTimer = [[NSTimer alloc] initWithFireDate:volumeBumpDate
                                               interval:0.f
                                                 target:self
                                               selector:@selector(fadeVolumeIn)
                                               userInfo:nil repeats:NO];
    [runner addTimer:self.volumeFadeTimer forMode: NSDefaultRunLoopMode];
    NSLog(@"Bumping volume: %f", self.volumeFadeMultiplier);
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

+ (SBElementArray *)userPlaylists {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    iTunesSource *librarySource = nil;
    
    for (iTunesSource *source in iTunes.sources) {
        if ([source kind] == iTunesESrcLibrary) {
            librarySource = source;
            break;
        }
    }
    
    SBElementArray *playlists = [librarySource userPlaylists];
    
    return playlists;
}

@end
