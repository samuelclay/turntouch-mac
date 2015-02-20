//
//  TTModeMusic.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTMode.h"
#import "TTModeProtocol.h"

extern NSString *const kMusicVolumeJump;

@interface TTModeMusic : TTMode {
    NSInteger originalVolume;
}

@end
