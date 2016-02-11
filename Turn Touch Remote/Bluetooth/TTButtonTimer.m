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
@synthesize previousButtonState;
@synthesize skipButtonActions;
@synthesize menuState;

- (id)init {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        previousButtonState = [[TTButtonState alloc] init];
        pairingActivatedCount = [[NSNumber alloc] init];
        menuHysteresis = NO;
    }
    
    return self;
}

- (uint8_t)buttonDownStateFromData:(NSData *)data {
    return ~(*(int *)[[data subdataWithRange:NSMakeRange(0, 1)] bytes]) & 0x0F;
}

- (uint8_t)doubleStateFromData:(NSData *)data {
    uint8_t state = ~(*(int *)[[data subdataWithRange:NSMakeRange(0, 1)] bytes]);
    return state >> 4;
}

- (int)heldStateFromData:(NSData *)data {
    return *(int *)[[data subdataWithRange:NSMakeRange(1, 1)] bytes];
}

- (void)readBluetoothData:(NSData *)data {
    uint8_t state = [self buttonDownStateFromData:data];
    uint8_t doubleState = [self doubleStateFromData:data];
    BOOL heldState = [self heldStateFromData:data] == 0xFF;
    NSInteger buttonLifted = -1;
    
    TTButtonState *latestButtonState = [[TTButtonState alloc] init];
    latestButtonState.north = !!(state & (1 << 0));
    latestButtonState.east = !!(state & (1 << 1));
    latestButtonState.west = !!(state & (1 << 2));
    latestButtonState.south = !!(state & (1 << 3));

    NSLog(@" ---> Bluetooth data: %@ (%d/%d/%d) %@", data, doubleState, state, heldState, latestButtonState);
    
    // Figure out which buttons are held and lifted
    NSInteger i = latestButtonState.count;
    while (i--) {
        if (![previousButtonState state:i] && [latestButtonState state:i]) {
            // Press button down

        } else if ([previousButtonState state:i] && ![latestButtonState state:i]) {
            // Lift button
            buttonLifted = i;
        } else {
            // Button remains pressed down

        }
    }
    
    BOOL anyButtonHeld = !latestButtonState.inMultitouch && !menuHysteresis && heldState;
    BOOL anyButtonPressed = !menuHysteresis && latestButtonState.anyPressedDown;
    BOOL anyButtonLifted = !previousButtonState.inMultitouch && !menuHysteresis && buttonLifted >= 0;
    
    if (anyButtonHeld) {
        // Hold button
        NSLog(@" ---> Hold button");
        previousButtonState = latestButtonState;
        menuState = TTHUDMenuStateHidden;
        
        if (state == 0x01) {
            // Don't fire action on button release
            previousButtonState.north = NO;
            [self activateMode:NORTH];
        } else if (state == 0x02) {
            previousButtonState.east = NO;
            [self activateMode:EAST];
        } else if (state == 0x04) {
            previousButtonState.west = NO;
            [self activateMode:WEST];
        } else if (state == 0x08) {
            previousButtonState.south = NO;
            [self activateMode:SOUTH];
        }
        [self activateButton:NO_DIRECTION];
    } else if (anyButtonPressed) {
        // Press down button
        NSLog(@" ---> Press down button%@", previousButtonState.inMultitouch ? @" (multi-touch)" : @"");
        previousButtonState = latestButtonState;

        if (latestButtonState.inMultitouch) {
            if (!holdToastStart && !menuHysteresis && menuState == TTHUDMenuStateHidden) {
                holdToastStart = [NSDate date];
                menuHysteresis = YES;
                menuState = TTHUDMenuStateActive;
                [appDelegate.hudController holdToastActiveMode:NO];
            } else if (menuState == TTHUDMenuStateActive && !menuHysteresis) {
                menuHysteresis = YES;
                menuState = TTHUDMenuStateHidden;
                [appDelegate.hudController releaseToastActiveMode];
            }
            [self activateButton:NO_DIRECTION];
        } else if (menuState == TTHUDMenuStateActive) {
            if ((state & 0x01) == 0x01) {
                [self fireMenuButton:NORTH];
            } else if ((state & 0x02) == 0x02) {
                [self fireMenuButton:EAST];
            } else if ((state & 0x04) == 0x04) {
                [self fireMenuButton:WEST];
            } else if ((state & 0x08) == 0x08) {
                [self fireMenuButton:SOUTH];
            } else if (state == 0x00) {
                [self activateButton:NO_DIRECTION];
            }
        } else {
            if ((state & 0x01) == 0x01) {
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
    } else if (anyButtonLifted && menuState == TTHUDMenuStateHidden) {
        // Press up button
        NSLog(@" ---> Button lifted%@: %ld", previousButtonState.inMultitouch ? @" (multi-touch)" : @"", (long)buttonLifted);
        previousButtonState = latestButtonState;

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
        if (doubleState == 0xF &&
            lastButtonPressedDirection != NO_DIRECTION &&
            buttonPressedDirection == lastButtonPressedDirection &&
            [[NSDate date] timeIntervalSinceDate:lastButtonPressStart] < DOUBLE_CLICK_ACTION_DURATION) {
            // Double click detected
            [self fireDoubleButton:buttonPressedDirection];
            lastButtonPressedDirection = NO_DIRECTION;
            lastButtonPressStart = nil;
        } else if (doubleState != 0xF && doubleState != 0x0) {
            // Firmware v3+ has hardware support for double-click
            [self fireDoubleButton:buttonPressedDirection];
        } else {
            lastButtonPressedDirection = buttonPressedDirection;
            lastButtonPressStart = [NSDate date];
            
            [self fireButton:buttonPressedDirection];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DOUBLE_CLICK_ACTION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                lastButtonPressedDirection = NO_DIRECTION;
                lastButtonPressStart = nil;
            });
        }
    } else if (!latestButtonState.anyPressedDown) {
        NSLog(@" ---> Nothing pressed%@: %d (lifted: %ld)", latestButtonState.inMultitouch ? @" (multi-touch)" : @"", state, buttonLifted);
        BOOL inMultitouch = previousButtonState.inMultitouch;
        previousButtonState = latestButtonState;

        if (!inMultitouch && buttonLifted >= 0 && menuHysteresis) {
            [self releaseToastActiveMode];
        } else if (menuState == TTHUDMenuStateHidden) {
            [self releaseToastActiveMode];
        }
        [self activateButton:NO_DIRECTION];
        menuHysteresis = NO;
        holdToastStart = nil;
    }
    
//    NSLog(@"Buttons: %d, %d: %@", state, heldData, previousButtonState);
}

- (void)releaseToastActiveMode {
    [appDelegate.hudController releaseToastActiveMode];

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
    NSString *actionName = [appDelegate.modeMap.selectedMode actionNameInDirection:direction];
    [appDelegate.modeMap setActiveModeDirection:direction];
    [appDelegate.hudController holdToastActiveAction:actionName inDirection:direction];
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    CGFloat deviceInterval = [[preferences objectForKey:@"TT:firmware:interval_max"] integerValue] / 1000.f;
    CGFloat modeChangeDuration = [[preferences objectForKey:@"TT:firmware:mode_duration"] floatValue] / 1000.f;
    CGFloat buttonHoldTimeInterval = MAX(MIN(.15f, modeChangeDuration*0.3f), deviceInterval * 1.05f);
//    NSLog(@"Mode change duration (%f): %f -- %f", buttonHoldTimeInterval, modeChangeDuration*.3f, deviceInterval*1.05f);
    if (direction != NO_DIRECTION) {
#ifndef SKIP_BUTTON_ACTIONS
        if (!skipButtonActions) {
            [appDelegate.modeMap maybeFireActiveButton];
        }
#endif
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

- (void)fireMenuButton:(TTModeDirection)direction {
    [appDelegate.hudController.modeHUDController runDirection:direction];
}

- (void)fireButton:(TTModeDirection)direction {
    [appDelegate.modeMap setActiveModeDirection:direction];
#ifndef SKIP_BUTTON_ACTIONS
    if (!skipButtonActions) {
        [appDelegate.modeMap runActiveButton];
    }
#endif
    [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    
    NSString *actionName = [appDelegate.modeMap.selectedMode actionNameInDirection:direction];
    [appDelegate.hudController toastActiveAction:actionName inDirection:direction];

    [self cancelModeTimer];
//    NSLog(@"Firing button: %@", [appDelegate.modeMap directionName:direction]);
}

- (void)fireDoubleButton:(TTModeDirection)direction {
    if (direction == NO_DIRECTION) return;

#ifndef SKIP_BUTTON_ACTIONS
    if (!skipButtonActions) {
        [appDelegate.modeMap runDoubleButton:direction];
    }
#endif

    [appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    
    NSString *actionName = [appDelegate.modeMap.selectedMode actionNameInDirection:direction];
    [appDelegate.hudController toastDoubleAction:actionName inDirection:direction];

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

#pragma mark - HUD Menu

- (void)closeMenu {
    menuState = TTHUDMenuStateHidden;
    [previousButtonState clearState];
}

#pragma mark - Pairing

- (void)resetPairingState {
    pairingButtonState = [[TTButtonState alloc] init];
}

- (void)readBluetoothDataDuringPairing:(NSData *)data {
    uint8_t state = [self buttonDownStateFromData:data];
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
