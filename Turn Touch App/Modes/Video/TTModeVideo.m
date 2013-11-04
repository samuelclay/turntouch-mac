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
//    NSInteger volume = quicktime.audioVolume;
//    NSLog(@"Video mode North: %ld", (long)volume);
//    [quicktime.audioVolume setSoundVolume:MIN(100, volume+10)];
}

- (void)runEast {

}

- (void)runSouth {
//    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
//    
//    NSInteger volume = iTunes.soundVolume;
//    NSLog(@"Music mode South: %ld", (long)volume);
//    [iTunes setSoundVolume:MAX(0, volume-10)];
}

- (void)runWest {
//    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
//    
//    [iTunes playpause];
}

@end
