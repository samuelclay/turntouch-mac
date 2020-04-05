//
//  TTModeTV.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTMode.h"
#import "TTModeProtocol.h"
#import "TV.h"

extern NSString *const kTVVolumeJump;
extern NSString *const kTVPlaylistSingle;
extern NSString *const kTVPlaylistShuffleSingle;
extern NSString *const kTVPlaylistDouble;
extern NSString *const kTVPlaylistShuffleDouble;

@interface TTModeTV : TTMode {
    NSInteger originalVolume;
    CGFloat volumeFadeMultiplier;
    NSTimer *volumeFadeTimer;
}

+ (TVApplication *)tvApp;

+ (NSView *)songInfoView:(NSRect)rect withTrack:(TVTrack *)currentTrack;

@end
