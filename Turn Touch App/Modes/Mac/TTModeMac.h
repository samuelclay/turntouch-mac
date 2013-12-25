//
//  TTModeMac.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/23/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import <AudioToolbox/AudioServices.h>

@interface TTModeMac : TTMode

- (AudioDeviceID)defaultOutputDeviceID;

@property float volume;

@end
