//
//  TTModeMusic.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMusic.h"
#import "iTunes.h"

@implementation TTModeMusic

const NSInteger ITUNES_VOLUME_PCT_CHANGE = 8;
NSString *const kMusicVolumeJump = @"musicVolumeJump";

#pragma mark - Mode

+ (NSString *)title {
    return @"Music";
}

+ (NSString *)description {
    return @"Control iTunes";
}

+ (NSString *)imageName {
    return @"mode_music.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeMusicVolumeUp",
             @"TTModeMusicVolumeDown",
             @"TTModeMusicPause",
             @"TTModeMusicNextTrack",
             @"TTModeMusicPreviousTrack",
             @"TTModeMusicVolumeJump"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeMusicVolumeUp {
    return @"iTunes Volume up";
}
- (NSString *)titleTTModeMusicVolumeDown {
    return @"iTunes Volume down";
}
- (NSString *)titleTTModeMusicPause {
    return @"Play/pause";
}
- (NSString *)titleTTModeMusicNextTrack {
    return @"Next track";
}
- (NSString *)titleTTModeMusicPreviousTrack {
    return @"Previous track";
}
- (NSString *)titleTTModeMusicVolumeJump {
    return @"Volume jump";
}

#pragma mark - Action Images

- (NSString *)imageTTModeMusicVolumeUp {
    return @"volume_up.png";
}
- (NSString *)imageTTModeMusicVolumeDown {
    return @"volume_down.png";
}
- (NSString *)imageTTModeMusicPause {
    return @"play.png";
}
- (NSString *)imageTTModeMusicNextTrack {
    return @"next_track.png";
}
- (NSString *)imageTTModeMusicPreviousTrack {
    return @"previous_track.png";
}
- (NSString *)imageTTModeMusicVolumeJump {
    return @"volume_jump.png";
}

#pragma mark - Progress

- (NSInteger)progressVolume {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    return iTunes.soundVolume;
}

- (NSInteger)progressTTModeMusicVolumeUp {
    return [self progressVolume];
}

- (NSInteger)progressTTModeMusicVolumeDown {
    return [self progressVolume];
}

- (NSInteger)progressTTModeMusicVolumeMute {
    return [self progressVolume];
}

- (NSInteger)progressTTModeMusicVolumeJump {
    return [self progressVolume];
}

#pragma mark - Action methods

- (void)runTTModeMusicVolumeUp {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    NSInteger volume = iTunes.soundVolume;
    NSLog(@"Music mode North: %ld", (long)volume);
    [iTunes setSoundVolume:MIN(100, volume+ITUNES_VOLUME_PCT_CHANGE)];
}

- (void)runTTModeMusicVolumeDown {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    NSInteger volume = iTunes.soundVolume;
    NSLog(@"Music mode South: %ld", (long)volume);
    [iTunes setSoundVolume:MAX(0, volume-ITUNES_VOLUME_PCT_CHANGE)];
}

- (void)runTTModeMusicPause {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    [iTunes playpause];
}

- (void)runTTModeMusicNextTrack {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    [iTunes nextTrack];
}

- (void)runTTModeMusicPreviousTrack {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    [iTunes previousTrack];
}

- (void)runTTModeMusicVolumeJump:(TTModeDirection)direction {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    NSInteger volume = iTunes.soundVolume;
    NSInteger volumeJump = [[NSAppDelegate.modeMap actionOptionValue:kMusicVolumeJump inDirection:direction] integerValue];
    if (volume != volumeJump) originalVolume = volume;

    NSLog(@"Music mode volume jump: %ld (%ld) %ld", (long)volume, (long)originalVolume, (long)volumeJump);
    [iTunes setSoundVolume:(volume == volumeJump ? originalVolume : volumeJump)];
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeMusicVolumeUp";
}
- (NSString *)defaultEast {
    return @"TTModeMusicNextTrack";
}
- (NSString *)defaultWest {
    return @"TTModeMusicPause";
}
- (NSString *)defaultSouth {
    return @"TTModeMusicVolumeDown";
}

@end
