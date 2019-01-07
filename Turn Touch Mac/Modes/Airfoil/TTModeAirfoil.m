//
//  TTModeAirfoil.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeAirfoil.h"

@implementation TTModeAirfoil

const double AIRFOIL_VOLUME_PCT_CHANGE = 0.03;
NSString *const kAirfoilVolumeJump = @"AirfoilVolumeJump";
NSString *const kAirfoilPlaylistSingle = @"AirfoilPlaylistSingle";
NSString *const kAirfoilPlaylistShuffleSingle = @"AirfoilPlaylistShuffleSingle";
NSString *const kAirfoilPlaylistDouble = @"AirfoilPlaylistDouble";
NSString *const kAirfoilPlaylistShuffleDouble = @"AirfoilPlaylistShuffleDouble";

#pragma mark - Mode

+ (NSString *)title {
    return @"Airfoil";
}

+ (NSString *)description {
    return @"Control connected speakers with Airfoil";
}

+ (NSString *)imageName {
    return @"app_airfoil.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeAirfoilVolumeUp",
             @"TTModeAirfoilVolumeDown",
             @"TTModeAirfoilVolumeJump",
             @"TTModeAirfoilMute"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeAirfoilVolumeUp {
    return @"Volume up";
}
- (NSString *)titleTTModeAirfoilVolumeDown {
    return @"Volume down";
}
- (NSString *)titleTTModeAirfoilVolumeJump {
    return @"Volume jump";
}
- (NSString *)titleTTModeAirfoilMute {
    return @"Mute";
}

#pragma mark - Action Images

- (NSString *)imageTTModeAirfoilVolumeUp {
    return @"music_volume_up.png";
}
- (NSString *)imageTTModeAirfoilVolumeDown {
    return @"music_volume_down.png";
}
- (NSString *)imageTTModeAirfoilVolumeJump {
    return @"music_volume.png";
}
- (NSString *)imageTTModeAirfoilMute {
    return @"music_mute.png";
}

#pragma mark - Progress

- (NSInteger)progressVolume {
    NSArray *speakers = [self airfoilSpeakers];
    
    for (AirfoilSpeaker *speaker in speakers) {
        double volume = speaker.volume;
        return volume * 100;
    }
    
    return 0;
}

- (NSInteger)progressTTModeAirfoilVolumeUp {
    return [self progressVolume];
}

- (NSInteger)progressTTModeAirfoilVolumeDown {
    return [self progressVolume];
}

- (NSInteger)progressTTModeAirfoilVolumeMute {
    return [self progressVolume];
}

- (NSInteger)progressTTModeAirfoilVolumeJump {
    return [self progressVolume];
}

#pragma mark - Layout

- (ActionLayout)layoutTTModeAirfoilVolumeUp {
    return ACTION_LAYOUT_PROGRESSBAR;
}
- (ActionLayout)layoutTTModeAirfoilVolumeDown {
    return ACTION_LAYOUT_PROGRESSBAR;
}

#pragma mark - Action methods

- (NSArray *)airfoilSpeakers {
    AirfoilApplication *airfoil = [SBApplication applicationWithBundleIdentifier:@"com.rogueamoeba.Airfoil"];
    NSArray *speakers = airfoil.speakers;
    
    // TODO: Preferences for individual speakers
    
    return speakers;
}
- (void)runTTModeAirfoilVolumeUp {
    NSArray *speakers = [self airfoilSpeakers];

    for (AirfoilSpeaker *speaker in speakers) {
        double volume = speaker.volume;
        speaker.volume = MIN(1, volume + AIRFOIL_VOLUME_PCT_CHANGE);
    }
}

- (void)runTTModeAirfoilVolumeDown {
    NSArray *speakers = [self airfoilSpeakers];

    for (AirfoilSpeaker *speaker in speakers) {
        double volume = speaker.volume;
        speaker.volume = MAX(0, volume - AIRFOIL_VOLUME_PCT_CHANGE);
    }
}

- (void)runTTModeAirfoilVolumeJump:(TTModeDirection)direction {
    NSArray *speakers = [self airfoilSpeakers];

    for (AirfoilSpeaker *speaker in speakers) {
        double volume = speaker.volume;
        double volumeJump = [[self.action optionValue:kAirfoilVolumeJump inDirection:direction] doubleValue];
        if (volume != volumeJump) originalVolume = volume;
        
        speaker.volume = (volume == volumeJump ? originalVolume : volumeJump);
    }
}

- (void)runTTModeAirfoilMute:(TTModeDirection)direction {
    NSArray *speakers = [self airfoilSpeakers];
    
    for (AirfoilSpeaker *speaker in speakers) {
        double volume = speaker.volume;
        if (volume != 0) originalVolume = volume;
        
        speaker.volume = (volume == 0 ? originalVolume : 0);
    }
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeAirfoilVolumeUp";
}
- (NSString *)defaultEast {
    return @"TTModeAirfoilVolumeJump";
}
- (NSString *)defaultWest {
    return @"TTModeAirfoilVolumeJump";
}
- (NSString *)defaultSouth {
    return @"TTModeAirfoilVolumeDown";
}

@end
