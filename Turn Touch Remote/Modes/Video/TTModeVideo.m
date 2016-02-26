//
//  TTModeVideo.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/4/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeVideo.h"
#import "Quicktime.h"
#import "VLC.h"
#import <CoreAudio/CoreAudio.h>

@implementation TTModeVideo

#pragma mark - Mode

+ (NSString *)title {
    return @"Video";
}

+ (NSString *)description {
    return @"Control movies and tv";
}

+ (NSString *)imageName {
    return @"mode_video.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeVideoVolumeUp",
             @"TTModeVideoVolumeDown",
             @"TTModeVideoFF",
             @"TTModeVideoRewind",
             @"TTModeVideoPause",
             @"TTModeVideoFullScreen",
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeVideoVolumeUp {
    return @"Volume up";
}
- (NSString *)titleTTModeVideoVolumeDown {
    return @"Volume down";
}
- (NSString *)titleTTModeVideoFF {
    return @"Fast forward";
}
- (NSString *)titleTTModeVideoRewind {
    return @"Rewind";
}
- (NSString *)titleTTModeVideoPause {
    return @"Play/pause";
}
- (NSString *)titleTTModeVideoFullScreen {
    return @"Full screen";
}

#pragma mark - Action Images

- (NSString *)imageTTModeVideoVolumeUp {
    return @"volume_up.png";
}
- (NSString *)imageTTModeVideoVolumeDown {
    return @"volume_down.png";
}
- (NSString *)imageTTModeVideoFF {
    return @"fast_forward.png";
}
- (NSString *)imageTTModeVideoRewind {
    return @"rewind.png";
}
- (NSString *)imageTTModeVideoPause {
    return @"play.png";
}
- (NSString *)imageTTModeVideoFullScreen {
    return @"full_screen.png";
}

#pragma mark - Action methods

- (void)runTTModeVideoFullScreen {
    if ([quicktime isRunning]) {
        SBElementArray *quicktimeItems = [quicktime documents];
        NSEnumerator *quicktimeEnumerator = [quicktimeItems objectEnumerator];
        QuicktimeDocument *quicktimeItem;
        while (quicktimeItem = [quicktimeEnumerator nextObject]) {
            [quicktimeItem present];
        }
    }
}

- (void)runTTModeVideoVolumeUp {
    [self moveVolume:UP];
}

- (void)runTTModeVideoVolumeDown {
    [self moveVolume:DOWN];
}

- (void)runTTModeVideoFF {
    if ([quicktime isRunning]) {
        SBElementArray *quicktimeItems = [quicktime documents];
        NSEnumerator *quicktimeEnumerator = [quicktimeItems objectEnumerator];
        QuicktimeDocument *quicktimeItem;
        while (quicktimeItem = [quicktimeEnumerator nextObject]) {
            double currentTime = [quicktimeItem currentTime];
            [quicktimeItem setCurrentTime:currentTime+10];
        }
    }
    
    if ([vlc isRunning]) {
        SBElementArray *vlcItems = [vlc windows];
        NSEnumerator *vlcEnumerator = [vlcItems objectEnumerator];
        VLCWindow *vlcWindow;
        while (vlcWindow = [vlcEnumerator nextObject]) {
            [vlcWindow.document stepForward];
            break;
        }
    }
}

- (void)runTTModeVideoRewind {
    if ([quicktime isRunning]) {
        SBElementArray *quicktimeItems = [quicktime documents];
        NSEnumerator *quicktimeEnumerator = [quicktimeItems objectEnumerator];
        QuicktimeDocument *quicktimeItem;
        while (quicktimeItem = [quicktimeEnumerator nextObject]) {
            double currentTime = [quicktimeItem currentTime];
            [quicktimeItem setCurrentTime:currentTime-10];
        }
    }
    
    if ([vlc isRunning]) {
        SBElementArray *vlcItems = [vlc windows];
        NSEnumerator *vlcEnumerator = [vlcItems objectEnumerator];
        VLCWindow *vlcWindow;
        while (vlcWindow = [vlcEnumerator nextObject]) {
            [vlcWindow.document stepBackward];
            break;
        }
    }
}

- (void)runTTModeVideoPause {
    if ([quicktime isRunning] && quicktime.frontmost) {
        SBElementArray *quicktimeItems = [quicktime documents];
        NSEnumerator *quicktimeEnumerator = [quicktimeItems objectEnumerator];
        QuicktimeDocument *quicktimeItem;
        while (quicktimeItem = [quicktimeEnumerator nextObject]) {
            if ([quicktimeItem playing]) {
                [quicktimeItem pause];
            } else {
                [quicktimeItem play];
            }
        }
    }
    
    if ([vlc isRunning]) {
        SBElementArray *vlcItems = [vlc windows];
        NSEnumerator *vlcEnumerator = [vlcItems objectEnumerator];
        VLCWindow *vlcWindow;
        while (vlcWindow = [vlcEnumerator nextObject]) {
            [vlcWindow.document play];
            break;
        }
    }
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeVideoVolumeUp";
}
- (NSString *)defaultEast {
    return @"TTModeVideoPause";
}
- (NSString *)defaultWest {
    return @"TTModeVideoFullScreen";
}
- (NSString *)defaultSouth {
    return @"TTModeVideoVolumeDown";
}

#pragma mark - Mode specific

- (void)activate {
    quicktime = [SBApplication applicationWithBundleIdentifier:@"com.apple.QuickTimePlayerX"];
    vlc = [SBApplication applicationWithBundleIdentifier:@"org.videolan.vlc"];
}

- (void)moveVolume:(VideoVolumeDirection)direction {
    if ([quicktime isRunning]) {
        SBElementArray *quicktimeItems = [quicktime documents];
        NSEnumerator *quicktimeEnumerator = [quicktimeItems objectEnumerator];
        QuicktimeDocument *quicktimeItem;
        while (quicktimeItem = [quicktimeEnumerator nextObject]) {
            double volume = quicktimeItem.audioVolume;
            if (direction == UP) {
                [quicktimeItem setAudioVolume:MIN(1, volume+0.1f)];
            } else if (direction == DOWN) {
                [quicktimeItem setAudioVolume:MAX(0, volume-0.1f)];
            }
            NSLog(@"Video mode (Quicktime), volume %@: %f",
                  direction == UP ? @"up" : @"down", quicktimeItem.audioVolume);
        }
    }
    
    if ([vlc isRunning]) {
        SBElementArray *vlcItems = [vlc windows];
        NSEnumerator *vlcEnumerator = [vlcItems objectEnumerator];
        VLCWindow *vlcWindow;
        while (vlcWindow = [vlcEnumerator nextObject]) {
            if (direction == UP) {
                [vlcWindow.document volumeUp];
            } else if (direction == DOWN) {
                [vlcWindow.document volumeDown];
            }
            break;
        }
    }
}

@end
