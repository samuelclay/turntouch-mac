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
        buttonState = [@[[NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO]] mutableCopy];
        inMultitouch = NO;
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

- (void)readBluetoothData:(NSData *)data {
    int state = *(int *)[[data subdataWithRange:NSMakeRange(0, 1)] bytes];
//    int press = *(int *)[[data subdataWithRange:NSMakeRange(1, 1)] bytes]; // Unreliable
    int pos = *(int *)[[data subdataWithRange:NSMakeRange(2, 1)] bytes];
    BOOL anyButtonPressed = NO;
    BOOL anyButtonHeld = NO;
    NSInteger buttonLifted = -1;
//    NSLog(@"Buttons: %d, %d: %@", state, pos, buttonState);
    
    NSMutableArray *newButtonState = [@[[NSNumber numberWithBool:(state & 0x01) == 0x01],
                                        [NSNumber numberWithBool:(state & 0x02) == 0x02],
                                        [NSNumber numberWithBool:(state & 0x04) == 0x04],
                                        [NSNumber numberWithBool:(state & 0x08) == 0x08]] mutableCopy];
    NSInteger i = buttonState.count;
    while (i--) {
        BOOL buttonDown = ((state & (1 << i)) == (1 << i));
//        NSLog(@"Checking button #%ld: %d / %d", (long)i, buttonDown, anyButtonPressed);
        if (buttonDown && anyButtonPressed) {
            inMultitouch = YES;
        }
        // Press button down
        if (![[buttonState objectAtIndex:i] boolValue] && buttonDown) {
            anyButtonPressed = YES;
            [newButtonState replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:buttonDown]];
        }
        // Lift button
        else if ([[buttonState objectAtIndex:i] boolValue] && !buttonDown) {
            [newButtonState replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
            if (!inMultitouch) {
                buttonLifted = i;
            }
        }
        // Button remains pressed down
        else {
            if (buttonDown) anyButtonPressed = YES;
            [newButtonState replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:buttonDown]];
        }
    }
    buttonState = newButtonState;
    anyButtonHeld = !inMultitouch && pos == 0xFF;
    
    // Hold button
    if (anyButtonHeld) {
        NSLog(@" ---> Button held: %d", state);
        if (state == 0x01) {
            // Don't fire action on button release
            [buttonState replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:NO]];
            [self selectActiveMode:NORTH];
        } else if (state == 0x02) {
            [buttonState replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:NO]];
            [self selectActiveMode:EAST];
        } else if (state == 0x04) {
            [buttonState replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:NO]];
            [self selectActiveMode:WEST];
        } else if (state == 0x08) {
            [buttonState replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:NO]];
            [self selectActiveMode:SOUTH];
        }
        [self activateButton:NO_DIRECTION];
    } else
    // Press button
    if (anyButtonPressed) {
        NSLog(@" ---> Button down%@: %d", inMultitouch ? @" (multi-touch)" : @"", state);
        if (inMultitouch) {
            if (!holdToastStart) {
                holdToastStart = [NSDate date];
                [appDelegate.hudController holdToastActiveMode];
            }
            [self activateButton:NO_DIRECTION];
        } else if ((state & 0x01) == 0x01) {
            [self activateButton:NORTH];
        } else if ((state & 0x02) == 0x02) {
            [self activateButton:EAST];
        } else if ((state & 0x04) == 0x04) {
            [self activateButton:WEST];
        } else if ((state & 0x08) == 0x08) {
            [self activateButton:SOUTH];
        } else if (state == 0x00) {
            [self activateButton:NO_DIRECTION];
        }
    }
    // Lift button
    else if (buttonLifted >= 0) {
        NSLog(@" ---> Button lifted%@: %ld", inMultitouch ? @" (multi-touch)" : @"", (long)buttonLifted);
        if (buttonLifted == 0) {
            [self fireButton:NORTH];
        } else if (buttonLifted == 1) {
            [self fireButton:EAST];
        } else if (buttonLifted == 2) {
            [self fireButton:WEST];
        } else if (buttonLifted == 3) {
            [self fireButton:SOUTH];
        } else {
            [self activateButton:NO_DIRECTION];
        }
    } else if (!anyButtonPressed && inMultitouch) {
        NSLog(@" ---> Nothing pressed%@: %d", inMultitouch ? @" (multi-touch)" : @"", state);
        if (state == 0x00) {
            [self activateButton:NO_DIRECTION];
            [self maybeReleaseToastActiveMode];
            inMultitouch = NO;
        }
    }
    
    
}

- (void)maybeReleaseToastActiveMode {
    if (!holdToastStart || [[NSDate date] timeIntervalSinceDate:holdToastStart] > 2.5) {
        [appDelegate.hudController releaseToastActiveMode];
    } else {
        [appDelegate.hudController toastActiveMode];
    }
    holdToastStart = nil;
}

- (void)selectActiveMode:(TTModeDirection)direction {
//    NSLog(@"Selecting mode: %d", activeModeDirection);
    [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    [appDelegate.modeMap setSelectedModeDirection:direction];
    
    [appDelegate.hudController toastActiveMode];
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

    [appDelegate.hudController toastActiveAction:direction];
}

@end
