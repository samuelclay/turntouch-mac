//
//  TTButtonTimer.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTButtonTimer.h"
#import "TTDiamond.h"

//const double MODE_CHANGE_DURATION = 0.5f;

@implementation TTButtonTimer

- (id)init {
    if (self = [super init]) {
        appDelegate = [NSApp delegate];
    }
    
    return self;
}

- (void)readButtons:(NSArray *)buttons {
    NSLog(@"Serial buttons: %@", buttons);
    
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
    [appDelegate.diamond setActiveModeDirection:0];
    [appDelegate.diamond setSelectedModeDirection:direction];
}

- (void)activateButton:(TTModeDirection)direction {
//    NSLog(@"Activating button: %d", activeModeDirection);
    [appDelegate.diamond setActiveModeDirection:direction];
}

- (void)deactivateButton {
    NSLog(@"Deactivate button: %d", activeModeDirection);
}
- (void)fireButton:(TTModeDirection)direction {
    [appDelegate.diamond setActiveModeDirection:direction];
    [appDelegate.diamond runActiveButton];
    [appDelegate.diamond setActiveModeDirection:0];
}

@end
