//
//  TTModeSpotify.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/17/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeSpotify.h"

@implementation TTModeSpotify

const NSInteger SPOTIFY_VOLUME_PCT_CHANGE = 6;
NSString *const kSpotifyVolumeJump = @"spotifyVolumeJump";

#pragma mark - Mode

+ (NSString *)title {
    return @"Spotify";
}

+ (NSString *)description {
    return @"Control Spotify music";
}

+ (NSString *)imageName {
    return @"mode_spotify.png";
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeSpotifyVolumeUp";
}
- (NSString *)defaultEast {
    return @"TTModeSpotifyNextTrack";
}
- (NSString *)defaultWest {
    return @"TTModeSpotifyPlayPause";
}
- (NSString *)defaultSouth {
    return @"TTModeSpotifyVolumeDown";
}
#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeSpotifyVolumeUp",
             @"TTModeSpotifyVolumeDown",
             @"TTModeSpotifyPause",
             @"TTModeSpotifyPlay",
             @"TTModeSpotifyPlayPause",
             @"TTModeSpotifyNextTrack",
             @"TTModeSpotifyPreviousTrack",
             @"TTModeSpotifyVolumeJump",
             @"TTModeSpotifySleep"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeSpotifyVolumeUp {
    return @"Spotify Volume up";
}
- (NSString *)titleTTModeSpotifyVolumeDown {
    return @"Spotify Volume down";
}
- (NSString *)titleTTModeSpotifyPause {
    return @"Pause";
}
- (NSString *)titleTTModeSpotifyPlay {
    return @"Play";
}
- (NSString *)titleTTModeSpotifyPlayPause {
    return @"Play/pause";
}
- (NSString *)doubleTitleTTModeSpotifyPause {
    return @"Previous track";
}
- (NSString *)doubleTitleTTModeSpotifyPlayPause {
    return @"Previous track";
}
- (NSString *)doubleTitleTTModeSpotifyPlay {
    return @"Previous track";
}
- (NSString *)actionTitleTTModeSpotifyPause {
    return @"Pause";
}
- (NSString *)actionTitleTTModeSpotifyPlay {
    return @"Play";
}
- (NSString *)actionTitleTTModeSpotifyPlayPause {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    if (spotify.playerState != SpotifyEPlSPlaying) {
        return @"Pause";
    }
    return @"Play";
}
- (NSString *)titleTTModeSpotifyNextTrack {
    return @"Next track";
}
- (NSString *)doubleTitleTTModeSpotifyNextTrack {
    return @"Next album";
}
- (NSString *)titleTTModeSpotifyPreviousTrack {
    return @"Previous track";
}
- (NSString *)titleTTModeSpotifyVolumeJump {
    return @"Volume jump";
}
- (NSString *)titleTTModeSpotifySleep {
    return @"Sleep";
}

#pragma mark - Action Images

- (NSString *)imageTTModeSpotifyVolumeUp {
    return @"music_volume_up.png";
}
- (NSString *)imageTTModeSpotifyVolumeDown {
    return @"music_volume_down.png";
}
- (NSString *)imageTTModeSpotifyPause {
    return @"music_pause.png";
}
- (NSString *)imageTTModeSpotifyPlay {
    return @"music_play.png";
}
- (NSString *)imageTTModeSpotifyPlayPause {
    return @"music_play.png";
}
- (NSString *)imageTTModeSpotifyNextTrack {
    return @"music_ff.png";
}
- (NSString *)imageTTModeSpotifyPreviousTrack {
    return @"music_rewind.png";
}
- (NSString *)imageTTModeSpotifyVolumeJump {
    return @"music_volume.png";
}
- (NSString *)imageTTModeSpotifySleep {
    return @"hue_sleep.png";
}
- (NSString *)imageActionHudTTModeSpotifyPlayPause {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    if (spotify.playerState == SpotifyEPlSPaused) {
        return @"music_pause.png";
    }
    return @"music_play.png";
}

#pragma mark - Progress

- (NSInteger)progressVolume {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    return spotify.soundVolume;
}

- (NSInteger)progressTTModeSpotifyVolumeUp {
    return [self progressVolume];
}

- (NSInteger)progressTTModeSpotifyVolumeDown {
    return [self progressVolume];
}

- (NSInteger)progressTTModeSpotifyVolumeMute {
    return [self progressVolume];
}

- (NSInteger)progressTTModeSpotifyVolumeJump {
    return [self progressVolume];
}

#pragma mark - Layout

- (ActionLayout)layoutTTModeSpotifyPause {
    return ACTION_LAYOUT_IMAGE_TITLE;
}
- (ActionLayout)layoutTTModeSpotifyPlay {
    return ACTION_LAYOUT_IMAGE_TITLE;
}
- (ActionLayout)layoutTTModeSpotifyPlayPause {
    return ACTION_LAYOUT_IMAGE_TITLE;
}
- (ActionLayout)layoutTTModeSpotifyVolumeUp {
    return ACTION_LAYOUT_PROGRESSBAR;
}
- (ActionLayout)layoutTTModeSpotifyVolumeDown {
    return ACTION_LAYOUT_PROGRESSBAR;
}

- (NSView *)viewForLayoutTTModeSpotifyPause:(NSRect)rect {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    SpotifyTrack *current = [spotify currentTrack];
    return [self.class songInfoView:rect withTrack:current];
}
- (NSView *)viewForLayoutTTModeSpotifyPlay:(NSRect)rect {
    return [self viewForLayoutTTModeSpotifyPause:rect];
}
- (NSView *)viewForLayoutTTModeSpotifyPlayPause:(NSRect)rect {
    return [self viewForLayoutTTModeSpotifyPause:rect];
}

- (ActionLayout)layoutTTModeSpotifyNextTrack {
    return ACTION_LAYOUT_IMAGE_TITLE;
}

- (NSView *)viewForLayoutTTModeSpotifyNextTrack:(NSRect)rect {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    SpotifyTrack *current = [spotify currentTrack];
    return [self.class songInfoView:rect withTrack:current];
}

+ (NSView *)songInfoView:(NSRect)rect withTrack:(SpotifyTrack *)currentTrack {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 128);
    NSColor *textColor = NSColorFromRGB(0x604050);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:fontSize],
                                      NSForegroundColorAttributeName: textColor,
                                      NSParagraphStyleAttributeName: style
                                      };
    NSSize textSize = [(currentTrack.name ? currentTrack.name : @"Spotify") sizeWithAttributes:labelAttributes];
    rect.size.height = textSize.height * 3;
    rect.size.width *= 1.25;
    rect.origin.x -= NSWidth(rect)*0.25/2;
    rect.origin.y -= rect.size.height + 16;
    NSView *view = [[NSView alloc] initWithFrame:rect];
    NSRect hudFrame = rect;
    
    // Album art
    NSImage *songArtwork;
    // TODO: Fetch track.artworkUrl and update image when loaded and cached
//    iTunesArtwork *artwork = (iTunesArtwork *)[[[currentTrack artworks] get] lastObject];
//    if (artwork != nil) {
//        songArtwork = [[NSImage alloc] initWithData:[artwork rawData]];
//    } else {
        songArtwork = [NSImage imageNamed:@"icon_music.png"];
//    }
    NSInteger imageMargin = NSWidth(screen.frame)/512;
    NSInteger imageSize = rect.size.height - imageMargin*2;
    NSInteger infoX = imageMargin*2 + imageSize + imageMargin;
    NSInteger infoWidth = NSWidth(hudFrame) - infoX - imageMargin;
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(imageMargin, imageMargin, imageSize, imageSize)];
    [imageView setImage:songArtwork];
    [view addSubview:imageView];
    
    // Check if song playing
    if (!currentTrack.name) {
        NSTextView *songTitleView = [[NSTextView alloc] initWithFrame:NSMakeRect(infoX, textSize.height, infoWidth, textSize.height)];
        [songTitleView setString:@"Spotify isn't playing anything"];
        [songTitleView setTextColor:NSColorFromRGB(0x604050)];
        [songTitleView setFont:[NSFont fontWithName:@"Effra" size:fontSize]];
        [songTitleView setBackgroundColor:[NSColor clearColor]];
        [view addSubview:songTitleView];
    } else {
        // Song title
        NSTextField *songTitleView = [[NSTextField alloc] initWithFrame:NSMakeRect(infoX, textSize.height*2, infoWidth, textSize.height)];
        [songTitleView setStringValue:currentTrack.name];
        [songTitleView setTextColor:NSColorFromRGB(0x604050)];
        [songTitleView setFont:[NSFont fontWithName:@"Effra" size:fontSize]];
        [songTitleView setBackgroundColor:[NSColor clearColor]];
        [songTitleView setLineBreakMode:NSLineBreakByTruncatingTail];
        [songTitleView setBezeled:NO];
        [songTitleView setEditable:NO];
        [songTitleView setSelectable:NO];
        [songTitleView setDrawsBackground:NO];
        [view addSubview:songTitleView];
        
        // Artist
        NSTextField *artistView = [[NSTextField alloc] initWithFrame:NSMakeRect(infoX, textSize.height*1, infoWidth, textSize.height)];
        [artistView setStringValue:currentTrack.artist];
        [artistView setTextColor:NSColorFromRGB(0x9080A0)];
        [artistView setFont:[NSFont fontWithName:@"Effra" size:fontSize]];
        [artistView setBackgroundColor:[NSColor clearColor]];
        [artistView setLineBreakMode:NSLineBreakByTruncatingTail];
        [artistView setBezeled:NO];
        [artistView setEditable:NO];
        [artistView setSelectable:NO];
        [artistView setDrawsBackground:NO];
        [view addSubview:artistView];
        
        // Album
        NSTextField *albumView = [[NSTextField alloc] initWithFrame:NSMakeRect(infoX, textSize.height*0, infoWidth, textSize.height)];
        [albumView setStringValue:currentTrack.album];
        [albumView setTextColor:NSColorFromRGB(0x9080A0)];
        [albumView setFont:[NSFont fontWithName:@"Effra" size:fontSize]];
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

- (void)runTTModeSpotifyVolumeUp {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    NSInteger volume = spotify.soundVolume;
    [spotify setSoundVolume:MIN(100, volume+SPOTIFY_VOLUME_PCT_CHANGE)];
}

- (void)runTTModeSpotifyVolumeDown {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    NSInteger volume = spotify.soundVolume;
    [spotify setSoundVolume:MAX(0, volume-SPOTIFY_VOLUME_PCT_CHANGE)];
}

- (void)runTTModeSpotifyPause {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    if (spotify.playerState == SpotifyEPlSPlaying) {
        [spotify playpause];
    }
}
- (void)doubleRunTTModeSpotifyPause {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    if (spotify.playerState == SpotifyEPlSPlaying) {
        [spotify playpause];
    }
}

- (void)runTTModeSpotifyPlay {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    if (spotify.playerState != SpotifyEPlSPlaying) {
        [spotify playpause];
    }
}
- (void)doubleRunTTModeSpotifyPlay {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    if (spotify.playerState != SpotifyEPlSPlaying) {
        [spotify playpause];
    }
}

- (void)runTTModeSpotifyPlayPause {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    [spotify playpause];
}
- (void)doubleRunTTModeSpotifyPlayPause {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    [spotify previousTrack];
    if (spotify.playerState != SpotifyEPlSPlaying) {
        [spotify playpause];
    }
}

- (void)runTTModeSpotifyNextTrack {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    [spotify nextTrack];
}
- (void)doubleRunTTModeSpotifyNextTrack {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];

    NSString *original = [[spotify currentTrack] album];
    SpotifyTrack *current;
    int tries = 30;
    
    while (tries--) {
        [spotify nextTrack];
        current = [spotify currentTrack];
        if (![original isEqualToString:current.album]) {
            break;
        }
    }
}

- (void)runTTModeSpotifyPreviousTrack {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];

    [spotify previousTrack];
}

- (void)runTTModeSpotifyVolumeJump:(TTModeDirection)direction {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];

    NSInteger volume = spotify.soundVolume;
    NSInteger volumeJump = [[self.action optionValue:kSpotifyVolumeJump inDirection:direction] integerValue];
    if (volume != volumeJump) originalVolume = volume;
    
    [spotify setSoundVolume:(volume == volumeJump ? originalVolume : volumeJump)];
}

- (void)runTTModeSpotifySleep:(TTModeDirection)direction {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];

    NSInteger volume = spotify.soundVolume;
    NSInteger volumeJump = [[self.action optionValue:kSpotifyVolumeJump inDirection:direction] integerValue];
    if (volume != volumeJump) originalVolume = volume;
    originalVolume = volume;
    [spotify setSoundVolume:(volume == volumeJump ? originalVolume : volumeJump)];
}

- (void)fadeVolumeDown {
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];

    volumeFadeMultiplier -= 1;
    
    [spotify setSoundVolume:volumeFadeMultiplier];
    
    if (volumeFadeTimer) {
        [volumeFadeTimer invalidate];
    }
    
    if (volumeFadeMultiplier <= 0.f) {
        NSLog(@"Done fading out volume.");
        if (spotify.playerState == SpotifyEPlSPlaying) {
            [spotify playpause];
        }
        [spotify setSoundVolume:originalVolume];
        return;
    }
    
    NSDate *volumeBumpDate = [[NSDate date] dateByAddingTimeInterval:(10)/100.f];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    volumeFadeTimer = [[NSTimer alloc] initWithFireDate:volumeBumpDate
                                               interval:0.f
                                                 target:self
                                               selector:@selector(fadeVolumeOut)
                                               userInfo:nil repeats:NO];
    [runner addTimer:volumeFadeTimer forMode: NSDefaultRunLoopMode];
    NSLog(@"Bumping volume: %f", volumeFadeMultiplier);
}

@end