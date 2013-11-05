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

@implementation TTModeVideo

- (void)activate {
    quicktime = [SBApplication applicationWithBundleIdentifier:@"com.apple.QuickTimePlayerX"];
    vlc = [SBApplication applicationWithBundleIdentifier:@"org.videolan.vlc"];
}

- (void)runNorth {
    [self moveVolume:UP];
}

- (void)runEast {
    if ([quicktime isRunning]) {
        
    }
    
    if ([vlc isRunning]) {
        
    }
}

- (void)runSouth {
    [self moveVolume:DOWN];
}

- (void)runWest {
    if ([quicktime isRunning]) {

    }
    
    if ([vlc isRunning]) {

    }
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
        NSString *vlcSource = [NSString stringWithFormat:@"tell application \"VLC\" to volume%@",
                               direction == UP ? @"Up" : @"Down"];
        NSAppleScript *vlcScript = [[NSAppleScript alloc] initWithSource:vlcSource];
        [vlcScript executeAndReturnError:nil];
    }
}

@end
