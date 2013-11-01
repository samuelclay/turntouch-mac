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
        if (tempMode) {
            [self releaseButton];
            tempMode = 0;
        } else {
            
        }
    } else {
        if (tempMode) {
            
        } else {
            startTimer = [NSDate date];
            if ([[buttons objectAtIndex:0] boolValue]) {
                tempMode = NORTH;
            } else if ([[buttons objectAtIndex:1] boolValue]) {
                tempMode = EAST;
            } else if ([[buttons objectAtIndex:2] boolValue]) {
                tempMode = SOUTH;
            } else if ([[buttons objectAtIndex:3] boolValue]) {
                tempMode = WEST;
            }
        }
    }
}

- (void)releaseButton {
    NSTimeInterval dateDiff = [[NSDate date] timeIntervalSinceDate:startTimer];

    if (dateDiff > 0.5f) {
        // Long press
        [self activateMode];
    } else {
        // Momentary press
        [self activateButton];
    }
}

- (void)activateMode {
    NSLog(@"Activating mode: %d", tempMode);
    [appDelegate.diamond setActiveMode:tempMode];
}

- (void)activateButton {
    NSLog(@"Activating button: %d", tempMode);
}

@end
