//
//  TTButtonTimer.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTButtonTimer.h"
#import "TTModeMap.h"

@implementation TTButtonTimer

@synthesize pairingActivatedCount;
@synthesize lastButtonState;
@synthesize inMultitouch;

- (id)init {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        lastButtonState = [[TTButtonState alloc] init];
        pairingActivatedCount = [[NSNumber alloc] init];
        inMultitouch = NO;
    }
    
    return self;
}

- (uint8_t)stateFromData:(NSData *)data {
    return ~(*(int *)[[data subdataWithRange:NSMakeRange(0, 1)] bytes]) & 0x0F;
}

- (int)heldStateFromData:(NSData *)data {
    return *(int *)[[data subdataWithRange:NSMakeRange(1, 1)] bytes];
}

- (void)readBluetoothData:(NSData *)data {
    uint8_t state = [self stateFromData:data];
    int heldData = [self heldStateFromData:data];

    BOOL anyButtonPressedDown = NO;
    BOOL anyButtonHeld = NO;
    NSInteger buttonLifted = -1;
    
    TTButtonState *newButtonState = [[TTButtonState alloc] init];
    newButtonState.north = (state & (1 << 0));
    newButtonState.east = (state & (1 << 1));
    newButtonState.west = (state & (1 << 2));
    newButtonState.south = (state & (1 << 3));
    
    NSInteger i = newButtonState.count;
    while (i--) {
        BOOL buttonDown = ((state & (1 << i)) == (1 << i));
        if (buttonDown && anyButtonPressedDown) {
            inMultitouch = YES;
        }

        if (![lastButtonState state:i] && buttonDown) {
            // Press button down
            anyButtonPressedDown = YES;
            [newButtonState replaceState:i withState:buttonDown];
        } else if ([lastButtonState state:i] && !buttonDown) {
            // Lift button
            [newButtonState replaceState:i withState:NO];
            if (!inMultitouch) {
                buttonLifted = i;
            }
        } else {
            // Button remains pressed down
            if (buttonDown) anyButtonPressedDown = YES;
            [newButtonState replaceState:i withState:buttonDown];
        }
    }
    
    lastButtonState = newButtonState;
    anyButtonHeld = !inMultitouch && heldData == 0xFF;
    
    if (anyButtonHeld) {
        // Hold button
        if (state == 0x01) {
            // Don't fire action on button release
            lastButtonState.north = NO;
            [self activateMode:NORTH];
        } else if (state == 0x02) {
            lastButtonState.east = NO;
            [self activateMode:EAST];
        } else if (state == 0x04) {
            lastButtonState.west = NO;
            [self activateMode:WEST];
        } else if (state == 0x08) {
            lastButtonState.south = NO;
            [self activateMode:SOUTH];
        }
        [self activateButton:NO_DIRECTION];
    } else if (anyButtonPressedDown) {
        // Press down button
        if (inMultitouch) {
            if (!holdToastStart) {
                holdToastStart = [NSDate date];
                [appDelegate.hudController holdToastActiveMode:NO];
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
    } else if (buttonLifted >= 0) {
        // Press up button
        NSLog(@" ---> Button lifted%@: %ld", inMultitouch ? @" (multi-touch)" : @"", (long)buttonLifted);
        TTModeDirection buttonPressedDirection;
        switch (buttonLifted) {
            case 0:
                buttonPressedDirection = NORTH;
                break;
            case 1:
                buttonPressedDirection = EAST;
                break;
            case 2:
                buttonPressedDirection = WEST;
                break;
            case 3:
                buttonPressedDirection = SOUTH;
                break;
                
            default:
                buttonPressedDirection = NO_DIRECTION;
                break;
        }
        
        // Check for double click and setup double click timer
        if (lastButtonPressedDirection != NO_DIRECTION &&
            buttonPressedDirection == lastButtonPressedDirection &&
            [[NSDate date] timeIntervalSinceDate:lastButtonPressStart] < DOUBLE_CLICK_ACTION_DURATION) {
            // Double click detected
            [self fireDoubleButton:buttonPressedDirection];
            lastButtonPressedDirection = NO_DIRECTION;
            lastButtonPressStart = nil;
        } else {
            lastButtonPressedDirection = buttonPressedDirection;
            lastButtonPressStart = [NSDate date];
            
            [self fireButton:buttonPressedDirection];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DOUBLE_CLICK_ACTION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                lastButtonPressedDirection = NO_DIRECTION;
                lastButtonPressStart = nil;
            });
        }
    } else if (!anyButtonPressedDown) {
//        NSLog(@" ---> Nothing pressed%@: %d", inMultitouch ? @" (multi-touch)" : @"", state);
        if (state == 0x00) {
            [self activateButton:NO_DIRECTION];
            [self maybeReleaseToastActiveMode];
            inMultitouch = NO;
        }
    }
    
//    NSLog(@"Buttons: %d, %d: %@", state, heldData, lastButtonState);
}

- (void)maybeReleaseToastActiveMode {
    if (!holdToastStart || [[NSDate date] timeIntervalSinceDate:holdToastStart] > 1.0) {
        [appDelegate.hudController releaseToastActiveMode];
    } else {
        [appDelegate.hudController toastActiveMode];
    }
    holdToastStart = nil;
}

- (void)activateMode:(TTModeDirection)direction {
//    NSLog(@"Selecting mode: %d", activeModeDirection);
    [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    [appDelegate.modeMap setSelectedModeDirection:direction];
    
    [appDelegate.hudController holdToastActiveMode:YES];

    NSString *soundFile = [[NSBundle mainBundle]
                           pathForResource:[NSString stringWithFormat:@"%@ tone",
                                            direction == NORTH ? @"north" :
                                            direction == EAST ? @"east" :
                                            direction == WEST ? @"west" :
                                            @"south"] ofType:@"wav"];
    NSSound *sound = [[NSSound alloc]
                      initWithContentsOfFile:soundFile
                      byReference: YES];
    
//    [sound setDelegate:self];
    [sound play];
}

- (void)activateButton:(TTModeDirection)direction {
//    NSLog(@"Activating button: %d", activeModeDirection);
    [appDelegate.modeMap setActiveModeDirection:direction];
    [appDelegate.hudController holdToastActiveAction:direction];
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    CGFloat deviceInterval = [[preferences objectForKey:@"TT:firmware:interval_max"] integerValue] / 1000.f;
    CGFloat modeChangeDuration = [[preferences objectForKey:@"TT:firmware:mode_duration"] floatValue] / 1000.f;
    CGFloat buttonHoldTimeInterval = MAX(MIN(.15f, modeChangeDuration*0.3f), deviceInterval * 1.05f);
//    NSLog(@"Mode change duration (%f): %f -- %f", buttonHoldTimeInterval, modeChangeDuration*.3f, deviceInterval*1.05f);
    if (direction != NO_DIRECTION) {
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:buttonHoldTimeInterval];
        activeModeTimer = [[NSTimer alloc]
                           initWithFireDate:fireDate
                           interval:0
                           target:self
                           selector:@selector(activeModeTimerFire:)
                           userInfo:@{@"activeModeDirection": [NSNumber numberWithInt:direction]}
                           repeats:NO];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:activeModeTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)fireButton:(TTModeDirection)direction {
    [appDelegate.modeMap setActiveModeDirection:direction];
#ifndef TEST
    [appDelegate.modeMap runActiveButton];
#endif
    [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];

    [appDelegate.hudController toastActiveAction:direction];

    [self cancelModeTimer];
//    NSLog(@"Firing button: %@", [appDelegate.modeMap directionName:direction]);
}

- (void)fireDoubleButton:(TTModeDirection)direction {
    if (direction == NO_DIRECTION) return;
    
    [appDelegate.modeMap runDoubleButton:direction];

    [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    
    [appDelegate.hudController toastDoubleAction:direction];

    [self cancelModeTimer];
}

- (void)cancelModeTimer {
    [activeModeTimer invalidate];
    activeModeTimer = nil;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [appDelegate.hudController hideModeTease];
    });
}

- (void)activeModeTimerFire:(NSTimer *)timer {
//    NSLog(@"Firing active mode timer: %d", appDelegate.modeMap.activeModeDirection);
    activeModeTimer = nil;
    TTModeDirection timerDirection = (TTModeDirection)[[timer.userInfo objectForKey:@"activeModeDirection"]
                                      integerValue];
//    NSLog(@" --> Teasing direction: %@ (%@)", [appDelegate.modeMap directionName:timerDirection], [appDelegate.modeMap directionName:appDelegate.modeMap.activeModeDirection]);
    if (appDelegate.modeMap.activeModeDirection == timerDirection) {
        [appDelegate.hudController teaseMode:timerDirection];
    }
}

#pragma mark - Pairing

- (void)resetPairingState {
    pairingButtonState = [[TTButtonState alloc] init];
}

- (void)readBluetoothDataDuringPairing:(NSData *)data {
    uint8_t state = [self stateFromData:data];
    pairingButtonState.north |= !!(state & (1 << 0));
    pairingButtonState.east |= !!(state & (1 << 1));
    pairingButtonState.west |= !!(state & (1 << 2));
    pairingButtonState.south |= !!(state & (1 << 3));
    [self setValue:@([pairingButtonState activatedCount]) forKey:@"pairingActivatedCount"];
    
    if ((state & (1 << 0)) == (1 << 0)) {
        [appDelegate.modeMap setActiveModeDirection:NORTH];
    } else if ((state & (1 << 1)) == (1 << 1)) {
        [appDelegate.modeMap setActiveModeDirection:EAST];
    } else if ((state & (1 << 2)) == (1 << 2)) {
        [appDelegate.modeMap setActiveModeDirection:WEST];
    } else if ((state & (1 << 3)) == (1 << 3)) {
        [appDelegate.modeMap setActiveModeDirection:SOUTH];
    } else {
        [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    }
}

- (BOOL)isDevicePaired {
    return pairingActivatedCount.integerValue == pairingButtonState.count;
}

- (BOOL)isDirectionPaired:(TTModeDirection)direction {
    switch (direction) {
        case NORTH:
            return pairingButtonState.north;
            
        case EAST:
            return pairingButtonState.east;
            
        case WEST:
            return pairingButtonState.west;
            
        case SOUTH:
            return pairingButtonState.south;
            
        default:
            break;
    }
    
    return NO;
}

@end
