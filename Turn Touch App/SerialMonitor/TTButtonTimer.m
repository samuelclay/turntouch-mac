//
//  TTButtonTimer.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTButtonTimer.h"
#import "TTDiamond.h"

@implementation TTButtonTimer

- (id)init {
    if (self = [super init]) {
        appDelegate = [NSApp delegate];
    }
    
    return self;
}

- (void)readButtons:(NSArray *)buttons {
    bool anyActive;
    
    for (NSNumber *button in buttons) {
        if ([button boolValue]) {
            anyActive = YES;
            break;
        }
    }
    
    if (!anyActive) {
        if (activeMode) {
            [self releaseButton];
            if (activeModeTimer) {
                NSLog(@"Invalidating timer.");
                [activeModeTimer invalidate];
                activeModeTimer = nil;
            }
            activeMode = 0;
        } else {
            
        }
    } else {
        if (activeMode) {
            
        } else {
            startTimer = [NSDate date];
            if ([[buttons objectAtIndex:0] boolValue]) {
                activeMode = NORTH;
            } else if ([[buttons objectAtIndex:1] boolValue]) {
                activeMode = EAST;
            } else if ([[buttons objectAtIndex:2] boolValue]) {
                activeMode = SOUTH;
            } else if ([[buttons objectAtIndex:3] boolValue]) {
                activeMode = WEST;
            }
            NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
            activeModeTimer = [[NSTimer alloc]
                               initWithFireDate:fireDate
                               interval:0
                               target:self
                               selector:@selector(activeModeTimerFire:)
                               userInfo:@{@"activeMode": [NSNumber numberWithInt:activeMode]}
                               repeats:NO];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            [runLoop addTimer:activeModeTimer forMode:NSDefaultRunLoopMode];
            [self activateButton];
        }
    }
}

- (void)activeModeTimerFire:(NSTimer *)timer {
    NSLog(@"Firing active mode timer: %d", activeMode);
    activeModeTimer = nil;
    
    if (activeMode == [[timer.userInfo objectForKey:@"activeMode"] integerValue]) {
        [self releaseButton];
    }
}

- (void)releaseButton {
    NSTimeInterval dateDiff = [[NSDate date] timeIntervalSinceDate:startTimer];

    if (dateDiff > 0.5f) {
        // Long press
        [self selectActiveMode];
    } else {
        // Momentary press
        [self deactivateButton];
    }
}

- (void)selectActiveMode {
    NSLog(@"Selecting mode: %d", activeMode);
    [appDelegate.diamond setActiveMode:0];
    [appDelegate.diamond setSelectedMode:activeMode];
}

- (void)activateButton {
    NSLog(@"Activating button: %d", activeMode);
    [appDelegate.diamond setActiveMode:activeMode];
}

- (void)deactivateButton {
    NSLog(@"Deactivating button: %d", activeMode);
    [appDelegate.diamond setActiveMode:0];
}

@end
