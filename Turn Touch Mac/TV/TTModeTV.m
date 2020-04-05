//
//  TTModeTV.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeTV.h"
#import <Cocoa/Cocoa.h>
#import "TV.h"

@interface TTModeTV ()

@property (nonatomic, strong, readonly) TVApplication *tvApp;
@property (nonatomic, readonly) BOOL isPlaying;

@end

@implementation TTModeTV

const NSInteger TV_VOLUME_PCT_CHANGE = 6;
NSString *const kTVVolumeJump = @"tvVolumeJump";
NSString *const kTVPlaylistSingle = @"tvPlaylistSingle";
NSString *const kTVPlaylistShuffleSingle = @"tvPlaylistShuffleSingle";
NSString *const kTVPlaylistDouble = @"tvPlaylistDouble";
NSString *const kTVPlaylistShuffleDouble = @"tvPlaylistShuffleDouble";

+ (TVApplication *)tvApp {
    return [SBApplication applicationWithBundleIdentifier:@"com.apple.TV"];
}

- (TVApplication *)tvApp {
    return [self.class tvApp];
}

- (BOOL)isPlaying {
    TVApplication *tv = self.tvApp;
    return tv.playerState == TVEPlSPlaying;
    
    return NO;
}

#pragma mark - Mode

+ (NSString *)title {
    return @"TV";
}

+ (NSString *)description {
    return @"Control TV";
}

+ (NSString *)imageName {
    return @"mode_tv.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeTVVolumeUp",
             @"TTModeTVVolumeDown",
             @"TTModeTVPause",
             @"TTModeTVPlay",
             @"TTModeTVPlayPause",
             @"TTModeTVNextTrack",
             @"TTModeTVPreviousTrack",
             @"TTModeTVFullScreen",
             @"TTModeTVSleep",
             @"TTModeTVVolumeJump"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeTVVolumeUp {
    return @"TV volume up";
}
- (NSString *)titleTTModeTVVolumeDown {
    return @"TV volume down";
}
- (NSString *)titleTTModeTVPause {
    return @"Pause";
}
- (NSString *)titleTTModeTVPlay {
    return @"Play";
}
- (NSString *)titleTTModeTVPlayPause {
    return @"Play/pause";
}
- (NSString *)doubleTitleTTModeTVPause {
    return @"Previous video";
}
- (NSString *)actionTitleTTModeTVPause {
    return @"Pause";
}
- (NSString *)actionTitleTTModeTVPlay {
    return @"Play";
}
- (NSString *)actionTitleTTModeTVPlayPause {
    return self.isPlaying ? @"Play" : @"Pause";
}
- (NSString *)titleTTModeTVNextTrack {
    return @"Next video";
}
- (NSString *)titleTTModeTVPreviousTrack {
    return @"Previous video";
}
- (NSString *)titleTTModeTVFullScreen {
    return @"Full screen";
}
- (NSString *)titleTTModeTVVolumeJump {
    return @"Volume jump";
}
- (NSString *)titleTTModeTVSleep {
    return @"Fade out";
}

#pragma mark - Action Images

- (NSString *)imageTTModeTVVolumeUp {
    return @"music_volume_up.png";
}
- (NSString *)imageTTModeTVVolumeDown {
    return @"music_volume_down.png";
}
- (NSString *)imageTTModeTVPause {
    return @"music_pause.png";
}
- (NSString *)imageTTModeTVPlay {
    return @"music_play.png";
}
- (NSString *)imageTTModeTVPlayPause {
    return @"music_play_pause.png";
}
- (NSString *)imageTTModeTVNextTrack {
    return @"music_ff.png";
}
- (NSString *)imageTTModeTVPreviousTrack {
    return @"music_rewind.png";
}
- (NSString *)imageTTModeTVFullScreen {
    return @"fullscreen.png";
}
- (NSString *)imageTTModeTVVolumeJump {
    return @"music_volume.png";
}
- (NSString *)imageTTModeTVSleep {
    return @"hue_sleep.png";
}
- (NSString *)imageActionHudTTModeTVPlayPause {
    return self.isPlaying ? @"music_play.png" : @"music_pause.png";
}

#pragma mark - Progress

- (NSInteger)progressVolume {
    TVApplication *tv = self.tvApp;
    return tv.soundVolume;
}

- (NSInteger)progressTTModeTVVolumeUp {
    return [self progressVolume];
}

- (NSInteger)progressTTModeTVVolumeDown {
    return [self progressVolume];
}

- (NSInteger)progressTTModeTVVolumeMute {
    return [self progressVolume];
}

- (NSInteger)progressTTModeTVVolumeJump {
    return [self progressVolume];
}

#pragma mark - Layout

- (ActionLayout)layoutTTModeTVPause {
    return ACTION_LAYOUT_IMAGE_TITLE;
}
- (ActionLayout)layoutTTModeTVPlay {
    return ACTION_LAYOUT_IMAGE_TITLE;
}
- (ActionLayout)layoutTTModeTVPlayPause {
    return ACTION_LAYOUT_IMAGE_TITLE;
}
- (ActionLayout)layoutTTModeTVVolumeUp {
    return ACTION_LAYOUT_PROGRESSBAR;
}
- (ActionLayout)layoutTTModeTVVolumeDown {
    return ACTION_LAYOUT_PROGRESSBAR;
}

- (NSView *)viewForLayoutTTModeTVPause:(NSRect)rect {
    TVApplication *tv = self.tvApp;
    TVTrack *current = [tv currentTrack];
    return [self.class songInfoView:rect withTrack:current];
}
- (NSView *)viewForLayoutTTModeTVPlay:(NSRect)rect {
    return [self viewForLayoutTTModeTVPause:rect];
}
- (NSView *)viewForLayoutTTModeTVPlayPause:(NSRect)rect {
    return [self viewForLayoutTTModeTVPause:rect];
}

- (ActionLayout)layoutTTModeTVNextTrack {
    return ACTION_LAYOUT_IMAGE_TITLE;
}

- (NSView *)viewForLayoutTTModeTVNextTrack:(NSRect)rect {
    TVApplication *tv = self.tvApp;
    TVTrack *current = [tv currentTrack];
    return [self.class songInfoView:rect withTrack:current];
}

+ (NSView *)songInfoView:(NSRect)rect withTrack:(TVTrack *)currentTrack {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 128);
    NSColor *textColor = NSColorFromRGB(0x604050);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:fontSize],
                                      NSForegroundColorAttributeName: textColor,
                                      NSParagraphStyleAttributeName: style
                                      };
    NSSize textSize = [(currentTrack.name ? currentTrack.name : @"Music") sizeWithAttributes:labelAttributes];
    rect.size.height = textSize.height * 3;
    rect.size.width *= 1.25;
    rect.origin.x -= NSWidth(rect)*0.25/2;
    rect.origin.y -= rect.size.height + 16;
    NSView *view = [[NSView alloc] initWithFrame:rect];
    NSRect hudFrame = rect;
    
    // Album art
    NSImage *songArtwork;
    TVArtwork *artwork = (TVArtwork *)[[[currentTrack artworks] get] lastObject];
    NSImage *image = artwork.data;
    NSData *data = artwork.rawData;
    
    // Not working reliably in Catalina; see: https://forums.developer.apple.com/thread/124557
    if ([image isKindOfClass:[NSImage class]]) {
        songArtwork = image;
    } else if ([data isKindOfClass:[NSData class]]) {
        songArtwork = [[NSImage alloc] initWithData:data];
    } else {
        songArtwork = [NSImage imageNamed:@"icon_music.png"];
    }
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
        [songTitleView setString:@"TV isn't playing anything"];
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
        [artistView setStringValue:currentTrack.show];
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
        [albumView setStringValue:[NSString stringWithFormat:@"Season %ld, Episode %ld", (long)currentTrack.seasonNumber, (long)currentTrack.episodeNumber]];
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

- (void)runTTModeTVVolumeUp {
    TVApplication *tv = self.tvApp;
    NSInteger volume = tv.soundVolume;
    [tv setSoundVolume:MIN(100, volume+TV_VOLUME_PCT_CHANGE)];
}

- (void)runTTModeTVVolumeDown {
    TVApplication *tv = self.tvApp;
    
    NSInteger volume = tv.soundVolume;
    [tv setSoundVolume:MAX(0, volume-TV_VOLUME_PCT_CHANGE)];
}

- (void)runTTModeTVPause {
    TVApplication *tv = self.tvApp;
    
    if (tv.playerState == TVEPlSPlaying) {
        [tv playpause];
    }
}
- (void)doubleRunTTModeTVPause {
    TVApplication *tv = self.tvApp;
    
    if (tv.playerState == TVEPlSPlaying) {
        [tv playpause];
    }
}

- (void)runTTModeTVPlay {
    TVApplication *tv = self.tvApp;
    
    if (tv.playerState != TVEPlSPlaying) {
        [tv playpause];
    }
}
- (void)doubleRunTTModeTVPlay {
    TVApplication *tv = self.tvApp;
    
    if (tv.playerState != TVEPlSPlaying) {
        [tv playpause];
    }
}

- (void)runTTModeTVPlayPause {
    TVApplication *tv = self.tvApp;
    
    [tv playpause];
}
- (void)doubleRunTTModeTVPlayPause {
    TVApplication *tv = self.tvApp;
    
    [tv previousTrack];
    if (tv.playerState != TVEPlSPlaying) {
        [tv playpause];
    }
}

- (void)runTTModeTVNextTrack {
    TVApplication *tv = self.tvApp;
    
    [tv nextTrack];
}

- (void)runTTModeTVPreviousTrack {
    TVApplication *tv = self.tvApp;
    
    [tv previousTrack];
}

- (void)runTTModeTVFullScreen {
    TVApplication *tv = self.tvApp;
     SBElementArray *tvItems = [tv videoWindows];
     NSEnumerator *tvEnumerator = [tvItems objectEnumerator];
     TVWindow *tvWindow;
     while (tvWindow = [tvEnumerator nextObject]) {
         [tvWindow setFullScreen:YES];
     }
}

- (void)runTTModeTVVolumeJump:(TTModeDirection)direction {
    TVApplication *tv = self.tvApp;
    NSInteger volume = tv.soundVolume;
    NSInteger volumeJump = [[self.action optionValue:kTVVolumeJump inDirection:direction] integerValue];
    if (volume != volumeJump) originalVolume = volume;

    [tv setSoundVolume:(volume == volumeJump ? originalVolume : volumeJump)];
}

- (void)runTTModeTVSleep:(TTModeDirection)direction {
    volumeFadeMultiplier = 100;
    
    [self fadeVolumeDown];
}

- (void)fadeVolumeDown {
    TVApplication *tv = self.tvApp;
    volumeFadeMultiplier -= 1;
    
    [tv setSoundVolume:volumeFadeMultiplier];
    
    if (volumeFadeTimer) {
        [volumeFadeTimer invalidate];
    }
    
    if (volumeFadeMultiplier <= 0.f) {
        NSLog(@"Done fading out volume.");
        if (tv.playerState == TVEPlSPlaying) {
            [tv playpause];
        }
        [tv setSoundVolume:originalVolume];
        return;
    }
    
    NSDate *volumeBumpDate = [[NSDate date] dateByAddingTimeInterval:(10)/100.f];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    volumeFadeTimer = [[NSTimer alloc] initWithFireDate:volumeBumpDate
                                               interval:0.f
                                                 target:self
                                               selector:@selector(fadeVolumeDown)
                                               userInfo:nil repeats:NO];
    [runner addTimer:volumeFadeTimer forMode: NSDefaultRunLoopMode];
    NSLog(@"Bumping volume: %f", volumeFadeMultiplier);
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeTVVolumeUp";
}
- (NSString *)defaultEast {
    return @"TTModeTVNextTrack";
}
- (NSString *)defaultWest {
    return @"TTModeTVPlayPause";
}
- (NSString *)defaultSouth {
    return @"TTModeTVVolumeDown";
}

@end
