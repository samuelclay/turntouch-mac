//
//  TTModeMac.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/23/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import <AudioToolbox/AudioServices.h>

@interface TTModeMac : TTMode {
    BOOL turnedOffMonitor;
}

+ (AudioDeviceID)defaultOutputDeviceID;

@property float volume;

+ (float)volume;
+ (void)setVolume:(float)newVolume;

@end
