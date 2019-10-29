//
//  TTModeMusic.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTMode.h"
#import "TTModeProtocol.h"
#import "iTunes.h"

extern NSString *const kMusicVolumeJump;
extern NSString *const kMusicPlaylistSingle;
extern NSString *const kMusicPlaylistShuffleSingle;
extern NSString *const kMusicPlaylistDouble;
extern NSString *const kMusicPlaylistShuffleDouble;

@interface TTModeMusic : TTMode {
    NSInteger originalVolume;
    CGFloat volumeFadeMultiplier;
    NSTimer *volumeFadeTimer;
}

+ (BOOL)isITunes;
+ (iTunesApplication *)musicApp;

+ (NSView *)songInfoView:(NSRect)rect withTrack:(iTunesTrack *)currentTrack;
+ (SBElementArray *)userPlaylists;

@end
