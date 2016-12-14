//
//  TTModeSpotify.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/17/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "TTModeProtocol.h"
#import "Spotify.h"

extern NSString *const kSpotifyVolumeJump;

@interface TTModeSpotify : TTMode {
    NSInteger originalVolume;
    CGFloat volumeFadeMultiplier;
    NSTimer *volumeFadeTimer;
    NSImageView *artworkImageView;
    NSCache *artworkCache;
}

@end
