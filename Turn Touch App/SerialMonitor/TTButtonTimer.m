//
//  TTButtonTimer.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTButtonTimer.h"
#import "TTDiamond.h"

const double MODE_CHANGE_DURATION = 0.5f;

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
    
    if (anyActive) {
        if (activeModeDirection) {
            // Ignore other button presses while waiting on another button
        } else {
            if ([[buttons objectAtIndex:0] boolValue]) {
                activeModeDirection = NORTH;
            } else if ([[buttons objectAtIndex:1] boolValue]) {
                activeModeDirection = EAST;
            } else if ([[buttons objectAtIndex:2] boolValue]) {
                activeModeDirection = SOUTH;
            } else if ([[buttons objectAtIndex:3] boolValue]) {
                activeModeDirection = WEST;
            }
            NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:MODE_CHANGE_DURATION];
            activeModeTimer = [[NSTimer alloc]
                               initWithFireDate:fireDate
                               interval:0
                               target:self
                               selector:@selector(activeModeTimerFire:)
                               userInfo:@{@"activeModeDirection":
                                              [NSNumber numberWithInt:activeModeDirection]}
                               repeats:NO];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            [runLoop addTimer:activeModeTimer forMode:NSDefaultRunLoopMode];
            [self activateButton];
        }
    } else {
        if (activeModeDirection) {
            [self fireButton];
            if (activeModeTimer) {
                NSLog(@"Invalidating timer.");
                [activeModeTimer invalidate];
                activeModeTimer = nil;
            }
            activeModeDirection = 0;
        } else {
            
        }
    }
}

- (void)activeModeTimerFire:(NSTimer *)timer {
    NSLog(@"Firing active mode timer: %d", activeModeDirection);
    activeModeTimer = nil;
    
    if (activeModeDirection == [[timer.userInfo objectForKey:@"activeModeDirection"] integerValue]) {
        [self selectActiveMode];
    }
}

- (void)selectActiveMode {
    NSLog(@"Selecting mode: %d", activeModeDirection);
    [appDelegate.diamond setActiveModeDirection:0];
    [appDelegate.diamond setSelectedModeDirection:activeModeDirection];
}

- (void)activateButton {
    NSLog(@"Activating button: %d", activeModeDirection);
    [appDelegate.diamond setActiveModeDirection:activeModeDirection];
}

- (void)fireButton {
    NSLog(@"Firing button: %d", activeModeDirection);
    [appDelegate.diamond runActiveButton];
    [appDelegate.diamond setActiveModeDirection:0];
}

@end
