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
- (NSString *)actionTitleTTModeMusicPause {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    if (iTunes.playerState == iTunesEPlSPlaying) {
        return @"Play";
    }
    return @"Pause";
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

#pragma mark - Layout

- (ActionLayout)layoutTTModeMusicPause {
    return ACTION_LAYOUT_IMAGE_TITLE;
}

- (NSView *)viewForLayoutTTModeMusicPause:(NSRect)rect {
    iTunesApplication * iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    iTunesTrack *current = [iTunes currentTrack];
    return [self.class songInfoView:rect withTrack:current];
}

- (ActionLayout)layoutTTModeMusicNextTrack {
    return ACTION_LAYOUT_IMAGE_TITLE;
}

- (NSView *)viewForLayoutTTModeMusicNextTrack:(NSRect)rect {
    iTunesApplication * iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    iTunesTrack *current = [iTunes currentTrack];
    return [self.class songInfoView:rect withTrack:current];
}

//- (ActionLayout)layoutTTModeMusicVolumeUp {
//    return ACTION_LAYOUT_IMAGE_TITLE;
//}
//
//- (NSView *)viewForLayoutTTModeMusicVolumeUp:(NSRect)rect {
//    return [self songInfoView:rect];
//}
//
//- (ActionLayout)layoutTTModeMusicVolumeDown {
//    return ACTION_LAYOUT_IMAGE_TITLE;
//}
//
//- (NSView *)viewForLayoutTTModeMusicVolumeDown:(NSRect)rect {
//    return [self songInfoView:rect];
//}

+ (NSView *)songInfoView:(NSRect)rect withTrack:(iTunesTrack *)currentTrack {
    NSView *view = [[NSView alloc] initWithFrame:rect];
    
    // Album art
    NSImage *songArtwork;
    iTunesArtwork *artwork = (iTunesArtwork *)[[[currentTrack artworks] get] lastObject];
    if (artwork != nil) {
        songArtwork = [[NSImage alloc] initWithData:[artwork rawData]];
    } else {
        songArtwork = [NSImage imageNamed:@"icon_music.png"];
    }
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(300, 20, 86, 86)];
    [imageView setImage:songArtwork];
    [view addSubview:imageView];
    
    // Check if song playing
    if (!currentTrack.name) {
        NSTextView *songTitleView = [[NSTextView alloc] initWithFrame:NSMakeRect(400, 48, 400, 36)];
        [songTitleView setString:@"iTunes isn't playing anything"];
        [songTitleView setTextColor:NSColorFromRGB(0x604050)];
        [songTitleView setFont:[NSFont fontWithName:@"Effra" size:24]];
        [songTitleView setBackgroundColor:[NSColor clearColor]];
        [view addSubview:songTitleView];
    } else {
        // Song title
        NSTextField *songTitleView = [[NSTextField alloc] initWithFrame:NSMakeRect(400, 76, 350, 36)];
        [songTitleView setStringValue:currentTrack.name];
        [songTitleView setTextColor:NSColorFromRGB(0x604050)];
        [songTitleView setFont:[NSFont fontWithName:@"Effra" size:24]];
        [songTitleView setBackgroundColor:[NSColor clearColor]];
        [songTitleView setLineBreakMode:NSLineBreakByTruncatingTail];
        [songTitleView setBezeled:NO];
        [songTitleView setEditable:NO];
        [songTitleView setSelectable:NO];
        [songTitleView setDrawsBackground:NO];
        [view addSubview:songTitleView];
        
        // Artist
        NSTextField *artistView = [[NSTextField alloc] initWithFrame:NSMakeRect(400, 48, 400, 36)];
        [artistView setStringValue:currentTrack.artist];
        [artistView setTextColor:NSColorFromRGB(0x9080A0)];
        [artistView setFont:[NSFont fontWithName:@"Effra" size:24]];
        [artistView setBackgroundColor:[NSColor clearColor]];
        [artistView setLineBreakMode:NSLineBreakByTruncatingTail];
        [artistView setBezeled:NO];
        [artistView setEditable:NO];
        [artistView setSelectable:NO];
        [artistView setDrawsBackground:NO];
        [view addSubview:artistView];
        
        // Album
        NSTextField *albumView = [[NSTextField alloc] initWithFrame:NSMakeRect(400, 20, 450, 36)];
        [albumView setStringValue:currentTrack.album];
        [albumView setTextColor:NSColorFromRGB(0x9080A0)];
        [albumView setFont:[NSFont fontWithName:@"Effra" size:24]];
        [albumView setBackgroundColor:[NSColor clearColor]];
        [albumView setLineBreakMode:NSLineBreakByTruncatingTail];
        [albumView setBezeled:NO];
        [albumView setEditable:NO];
        [albumView setSelectable:NO];
        [albumView setDrawsBackground:NO];
        [view addSubview:albumView];
    }
    
    return view;
}

#pragma mark - Action methods

- (void)runTTModeMusicVolumeUp {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    NSInteger volume = iTunes.soundVolume;
    [iTunes setSoundVolume:MIN(100, volume+ITUNES_VOLUME_PCT_CHANGE)];
}

- (void)runTTModeMusicVolumeDown {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    NSInteger volume = iTunes.soundVolume;
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
