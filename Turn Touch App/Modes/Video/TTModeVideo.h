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

@interface TTModeVideo : TTMode {
    QuicktimeApplication *quicktime;
    VLCApplication *vlc;
}

@end
