//
//  TTButtonTimer.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTButtonTimer.h"
#import "TTModeMap.h"

//const double MODE_CHANGE_DURATION = 0.5f;

@implementation TTButtonTimer

- (id)init {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
    }
    
    return self;
}

- (void)readButtons:(NSArray *)buttons {
//    NSLog(@"Serial buttons: %@", buttons);
    
    if ([[buttons objectAtIndex:0] integerValue] == PRESS_ACTIVE) {
        [self activateButton:NORTH];
    } else if ([[buttons objectAtIndex:1] integerValue] == PRESS_ACTIVE) {
        [self activateButton:EAST];
    } else if ([[buttons objectAtIndex:2] integerValue] == PRESS_ACTIVE) {
        [self activateButton:WEST];
    } else if ([[buttons objectAtIndex:3] integerValue] == PRESS_ACTIVE) {
        [self activateButton:SOUTH];
    } else if ([[buttons objectAtIndex:0] integerValue] == PRESS_TOGGLE) {
        [self fireButton:NORTH];
    } else if ([[buttons objectAtIndex:1] integerValue] == PRESS_TOGGLE) {
        [self fireButton:EAST];
    } else if ([[buttons objectAtIndex:2] integerValue] == PRESS_TOGGLE) {
        [self fireButton:WEST];
    } else if ([[buttons objectAtIndex:3] integerValue] == PRESS_TOGGLE) {
        [self fireButton:SOUTH];
    } else if ([[buttons objectAtIndex:0] integerValue] == PRESS_MODE) {
        [self selectActiveMode:NORTH];
    } else if ([[buttons objectAtIndex:1] integerValue] == PRESS_MODE) {
        [self selectActiveMode:EAST];
    } else if ([[buttons objectAtIndex:2] integerValue] == PRESS_MODE) {
        [self selectActiveMode:WEST];
    } else if ([[buttons objectAtIndex:3] integerValue] == PRESS_MODE) {
        [self selectActiveMode:SOUTH];
    }
}

- (void)selectActiveMode:(TTModeDirection)direction {
//    NSLog(@"Selecting mode: %d", activeModeDirection);
    [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    [appDelegate.modeMap setSelectedModeDirection:direction];
}

- (void)activateButton:(TTModeDirection)direction {
//    NSLog(@"Activating button: %d", activeModeDirection);
    [appDelegate.modeMap setActiveModeDirection:direction];
}

- (void)deactivateButton {
    NSLog(@"Deactivate button: %d", activeModeDirection);
}
- (void)fireButton:(TTModeDirection)direction {
    [appDelegate.modeMap setActiveModeDirection:direction];
    [appDelegate.modeMap runActiveButton];
    [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
}

@end
