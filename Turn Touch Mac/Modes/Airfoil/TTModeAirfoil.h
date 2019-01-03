//
//  TTModeAirfoil.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTMode.h"
#import "TTModeProtocol.h"
#import "Airfoil.h"

extern NSString *const kAirfoilVolumeJump;

@interface TTModeAirfoil : TTMode {
    NSInteger originalVolume;
    CGFloat volumeFadeMultiplier;
    NSTimer *volumeFadeTimer;
}

@end
