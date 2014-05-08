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

#pragma mark - Mode

+ (NSString *)title {
    return @"Music";
}

+ (NSString *)description {
    return @"Control iTunes";
}

+ (NSString *)imageName {
    return @"vinyl.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeMusicVolumeUp",
             @"TTModeMusicVolumeDown",
             @"TTModeMusicPause",
             @"TTModeMusicNextTrack"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeMusicVolumeUp {
    return @"Volume up";
}
- (NSString *)titleTTModeMusicVolumeDown {
    return @"Volume down";
}
- (NSString *)titleTTModeMusicPause {
    return @"Play/pause";
}
- (NSString *)titleTTModeMusicNextTrack {
    return @"Next track";
}

#pragma mark - Action methods

- (void)runTTModeMusicVolumeUp {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    NSInteger volume = iTunes.soundVolume;
    NSLog(@"Music mode North: %ld", (long)volume);
    [iTunes setSoundVolume:MIN(100, volume+10)];
}

- (void)runTTModeMusicVolumeDown {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    NSInteger volume = iTunes.soundVolume;
    NSLog(@"Music mode South: %ld", (long)volume);
    [iTunes setSoundVolume:MAX(0, volume-10)];
}

- (void)runTTModeMusicPause {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    [iTunes playpause];
}

- (void)runTTModeMusicNextTrack {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    [iTunes nextTrack];
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
