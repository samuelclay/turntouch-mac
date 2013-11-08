//
//  TTModeVideo.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/4/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeVideo.h"
#import "Quicktime.h"
#import "VLC.h"
#import <CoreAudio/CoreAudio.h>

@implementation TTModeVideo

- (NSString *)title {
    return @"Video";
}

- (NSString *)imageName {
    return @"icon_movie.png";
}

- (NSString *)titleNorth {
    return @"Volume Up";
}

- (NSString *)titleEast {
    return @"Play/Pause";
}

- (NSString *)titleWest {
    return @"Rewind 30s";
}

- (NSString *)titleSouth {
    return @"Volume Down";
}

- (void)activate {
    quicktime = [SBApplication applicationWithBundleIdentifier:@"com.apple.QuickTimePlayerX"];
//    vlc = [SBApplication applicationWithBundleIdentifier:@"org.videolan.vlc"];
}

- (void)runNorth {
    [self moveVolume:UP];
}

- (void)runEast {
    if ([quicktime isRunning]) {
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
    
//    if ([vlc isRunning]) {
//    
//    }
}

- (void)runSouth {
    [self moveVolume:DOWN];
}

- (void)runWest {
    if ([quicktime isRunning]) {
        SBElementArray *quicktimeItems = [quicktime documents];
        NSEnumerator *quicktimeEnumerator = [quicktimeItems objectEnumerator];
        QuicktimeDocument *quicktimeItem;
        while (quicktimeItem = [quicktimeEnumerator nextObject]) {
            double currentTime = quicktimeItem.currentTime;
            [quicktimeItem setCurrentTime:(currentTime - 30.0f)];
        }
    }
    
//    if ([vlc isRunning]) {
//        
//    }
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
    
//    if ([vlc isRunning]) {
//        NSString *vlcSource = [NSString stringWithFormat:@"tell application \"VLC\" to volume%@",
//                               direction == UP ? @"Up" : @"Down"];
//    NSString *vlcSource2 = [NSString stringWithFormat:@"set current_volume to output volume of (get volume settings)"
//                            "if current_volume is less than 100 then "
//                            "  set current_volume to current_volume + 2 "
//                            "end if "
//                            "set volume output volume current_volume"];
//        NSAppleScript *vlcScript = [[NSAppleScript alloc] initWithSource:vlcSource];
//        [vlcScript executeAndReturnError:nil];
//
//        NSAppleScript *vlcVolumeScript = [[NSAppleScript alloc] initWithSource:@"tell application \"VLC\" return volume;"];
//        NSDictionary* errorInfo = [NSDictionary dictionary];
//        NSAppleEventDescriptor *vlcDesc = [vlcVolumeScript executeAndReturnError:&errorInfo];
//        if (vlcDesc == nil) { // there was a compile error
//            NSString* error = [errorInfo objectForKey:NSAppleScriptErrorMessage];
//            NSLog(@"doAppleScript error = %@", error); NSBeep();
//        } else {
//            NSLog(@"VLC Desc: %@", [vlcDesc description]);
//        }
//    }
    
}

@end
