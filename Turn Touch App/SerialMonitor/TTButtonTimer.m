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
        buttonState = @[[NSNumber numberWithBool:NO],
                        [NSNumber numberWithBool:NO],
                        [NSNumber numberWithBool:NO],
                        [NSNumber numberWithBool:NO]];
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

- (void)readBTData:(NSData *)data {
    int state = *(int *)[[data subdataWithRange:NSMakeRange(0, 1)] bytes];
//    int press = *(int *)[[data subdataWithRange:NSMakeRange(1, 1)] bytes]; // Unreliable
    int pos = *(int *)[[data subdataWithRange:NSMakeRange(2, 1)] bytes];
    BOOL press;
    NSLog(@"Buttons: %d=%d, %d", state, pos == 0xFF, pos);
    
    NSArray *newButtonState = @[[NSNumber numberWithBool:(state & 0x01) == 0x01],
                                [NSNumber numberWithBool:(state & 0x02) == 0x02],
                                [NSNumber numberWithBool:(state & 0x04) == 0x04],
                                [NSNumber numberWithBool:(state & 0x08) == 0x08]];
    NSInteger i = newButtonState.count;
    while (i--) {
        if ([newButtonState objectAtIndex:i] != [buttonState objectAtIndex:i]) {
            if (![[buttonState objectAtIndex:i] boolValue]) {
                // Pressed
                if (press) inMultitouch = YES;
                press = YES;
            }
        }
    }
    
    // Everything released means cleanup the stack
    if (!press) {
        
    }

    if (!inMultitouch && pos == 0xFF) {
        if (state == 0x01) {
            [self selectActiveMode:NORTH];
        } else if (state == 0x02) {
            [self selectActiveMode:EAST];
        } else if (state == 0x04) {
            [self selectActiveMode:WEST];
        } else if (state == 0x08) {
            [self selectActiveMode:SOUTH];
        }
    } else
    // Press button
    if (press == 1) {
        if (inMultitouch) {
            [appDelegate.hudController toastActiveMode];
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
    else if (!press && !inMultitouch) {
        if (state == 0x01) {
            [self fireButton:NORTH];
        } else if (state == 0x02) {
            [self fireButton:EAST];
        } else if (state == 0x04) {
            [self fireButton:WEST];
        } else if (state == 0x08) {
            [self fireButton:SOUTH];
        } else if (state == 0x00) {
            [self activateButton:NO_DIRECTION];
        }
    } else if (!press && inMultitouch) {
        if (state == 0x00) {
            [self activateButton:NO_DIRECTION];
            inMultitouch = NO;
        }
    }
    
    
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
    
    [appDelegate.hudController toastActiveAction];
}

@end
