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

- (void)runNorth {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    NSInteger volume = iTunes.soundVolume;
    [iTunes setSoundVolume:MIN(100, volume+10)];
}

- (void)runEast {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    [iTunes nextTrack];
}

- (void)runSouth {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    NSInteger volume = iTunes.soundVolume;
    [iTunes setSoundVolume:MAX(0, volume-10)];
}

- (void)runWest {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    [iTunes playpause];
}

@end
