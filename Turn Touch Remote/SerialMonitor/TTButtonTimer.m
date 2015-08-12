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
@synthesize buttonState;
@synthesize inMultitouch;

- (id)init {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        buttonState = [[TTButtonState alloc] init];
        pairingActivatedCount = [[NSNumber alloc] init];
        inMultitouch = NO;
    }
    
    return self;
}

- (uint8_t)stateFromData:(NSData *)data {
    return ~(*(int *)[[data subdataWithRange:NSMakeRange(0, 1)] bytes]) & 0x0F;
}

- (void)readBluetoothData:(NSData *)data {
    uint8_t state = [self stateFromData:data];
    int pos = *(int *)[[data subdataWithRange:NSMakeRange(1, 1)] bytes];

    BOOL anyButtonPressed = NO;
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
//        NSLog(@"Checking button #%ld: %d / %d", (long)i, buttonDown, anyButtonPressed);
        if (buttonDown && anyButtonPressed) {
            inMultitouch = YES;
        }
        // Press button down
        if (![buttonState state:i] && buttonDown) {
            anyButtonPressed = YES;
            [newButtonState replaceState:i withState:buttonDown];
        }
        // Lift button
        else if ([buttonState state:i] && !buttonDown) {
            [newButtonState replaceState:i withState:NO];
            if (!inMultitouch) {
                buttonLifted = i;
            }
        }
        // Button remains pressed down
        else {
            if (buttonDown) anyButtonPressed = YES;
            [newButtonState replaceState:i withState:buttonDown];
        }
    }
    buttonState = newButtonState;
    anyButtonHeld = !inMultitouch && pos == 0xFF;
    
    // Hold button
    if (anyButtonHeld) {
//        NSLog(@" ---> Button held: %d", state);
        if (state == 0x01) {
            // Don't fire action on button release
            buttonState.north = NO;
            [self selectActiveMode:NORTH];
        } else if (state == 0x02) {
            buttonState.east = NO;
            [self selectActiveMode:EAST];
        } else if (state == 0x04) {
            buttonState.west = NO;
            [self selectActiveMode:WEST];
        } else if (state == 0x08) {
            buttonState.south = NO;
            [self selectActiveMode:SOUTH];
        }
        [self activateButton:NO_DIRECTION];
    } else
    // Press button
    if (anyButtonPressed) {
//        NSLog(@" ---> Button down%@: %d", inMultitouch ? @" (multi-touch)" : @"", state);
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
    }
    // Lift button
    else if (buttonLifted >= 0) {
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
            [[NSDate date] timeIntervalSinceDate:lastButtonPressStart] < 0.500) {
            // Double click detected
            [self fireDoubleClickButton:buttonPressedDirection];
            lastButtonPressedDirection = NO_DIRECTION;
            lastButtonPressStart = nil;
        } else {
            lastButtonPressedDirection = buttonPressedDirection;
            lastButtonPressStart = [NSDate date];
            
            [self fireButton:buttonPressedDirection];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.500 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                lastButtonPressedDirection = NO_DIRECTION;
                lastButtonPressStart = nil;
            });
        }
        
    } else if (!anyButtonPressed) {
//        NSLog(@" ---> Nothing pressed%@: %d", inMultitouch ? @" (multi-touch)" : @"", state);
        if (state == 0x00) {
            [self activateButton:NO_DIRECTION];
            [self maybeReleaseToastActiveMode];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.150 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                inMultitouch = NO;
            });
        }
    }
    
//    NSLog(@"Buttons: %d, %d: %@", state, pos, buttonState);
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

- (void)fireDoubleClickButton:(TTModeDirection)direction {
    if (direction == NO_DIRECTION) return;
    
    [appDelegate.modeMap runDoubleClickButton:direction];
    
    [appDelegate.hudController toastDoubleClickAction:direction];

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
