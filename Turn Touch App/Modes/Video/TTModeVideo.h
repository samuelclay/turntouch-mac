//
//  TTModeVideo.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/4/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "Quicktime.h"
#import "VLC.h"

typedef enum {
    UP = 1,
    DOWN = 2
} VideoVolumeDirection;

@interface TTModeVideo : TTMode {
    QuicktimeApplication *quicktime;
    VLCApplication *vlc;
}

- (void)moveVolume:(VideoVolumeDirection)direction;

@end
