//
//  TTButtonTimer.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTButtonTimer.h"
#import "TTModeMap.h"

#define DEBUG_BUTTON_STATE 1

@interface TTButtonTimer ()

@property (nonatomic, strong) NSTimer *activeModeTimer;
@property (nonatomic, strong) TTButtonState *pairingButtonState;
@property (nonatomic) TTModeDirection lastButtonPressedDirection;
@property (nonatomic, strong) NSDate *lastButtonPressStart;
@property (nonatomic, strong) NSDate *holdToastStart;
@property (nonatomic) BOOL menuHysteresis;

@end

@implementation TTButtonTimer

- (id)init {
    if (self = [super init]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.previousButtonState = [[TTButtonState alloc] init];
        self.pairingActivatedCount = [[NSNumber alloc] init];
        self.menuHysteresis = NO;
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

#if DEBUG_BUTTON_STATE
    NSLog(@" ---> Bluetooth data: %@ (%d/%d/%d) was:%@ is:%@", data, doubleState, state, heldState, self.previousButtonState, latestButtonState);
#endif
    
    // Figure out which buttons are held and lifted
    NSInteger i = latestButtonState.count;
    while (i--) {
        if (![self.previousButtonState state:i] && [latestButtonState state:i]) {
            // Press button down

        } else if ([self.previousButtonState state:i] && ![latestButtonState state:i]) {
            // Lift button
            buttonLifted = i;
        } else {
            // Button remains pressed down

        }
    }
    
    BOOL anyButtonHeld = !latestButtonState.inMultitouch && !self.menuHysteresis && heldState;
    BOOL anyButtonPressed = !self.menuHysteresis && latestButtonState.anyPressedDown;
    BOOL anyButtonLifted = !self.previousButtonState.inMultitouch && !self.menuHysteresis && buttonLifted >= 0;
    
    if (anyButtonHeld) {
        // Hold button
#if DEBUG_BUTTON_STATE
        NSLog(@" ---> Hold button");
#endif
        self.previousButtonState = latestButtonState;
        self.menuState = TTHUDMenuStateHidden;
        
        if (state == 0x01) {
            // Don't fire action on button release
            self.previousButtonState.north = NO;
            [self activateMode:NORTH];
        } else if (state == 0x02) {
            self.previousButtonState.east = NO;
            [self activateMode:EAST];
        } else if (state == 0x04) {
            self.previousButtonState.west = NO;
            [self activateMode:WEST];
        } else if (state == 0x08) {
            self.previousButtonState.south = NO;
            [self activateMode:SOUTH];
        }
        [self activateButton:NO_DIRECTION];
    } else if (anyButtonPressed) {
        // Press down button
#if DEBUG_BUTTON_STATE
        NSLog(@" ---> Button down%@", self.previousButtonState.inMultitouch ? @" (multi-touch)" : @"");
#endif
        self.previousButtonState = latestButtonState;

        if (latestButtonState.inMultitouch) {
            if (!self.holdToastStart && !self.menuHysteresis && self.menuState == TTHUDMenuStateHidden) {
                self.holdToastStart = [NSDate date];
                self.menuHysteresis = YES;
                self.menuState = TTHUDMenuStateActive;
                [self.appDelegate.hudController activateHudMenu];
            } else if (self.menuState == TTHUDMenuStateActive && !self.menuHysteresis) {
                self.menuHysteresis = YES;
                self.menuState = TTHUDMenuStateHidden;
                [self releaseToastActiveMode];
            }
            [self activateButton:NO_DIRECTION];
        } else if (self.menuState == TTHUDMenuStateActive) {
            if ((state & 0x01) == 0x01) {
                [self fireMenuButton:NORTH];
            } else if ((state & 0x02) == 0x02) {
                // Not on button down, wait for button up
//                [self fireMenuButton:EAST];
            } else if ((state & 0x04) == 0x04) {
//                [self fireMenuButton:WEST];
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
    } else if (anyButtonLifted) {
        // Press up button
#if DEBUG_BUTTON_STATE
        NSLog(@" ---> Button up%@: %ld", self.previousButtonState.inMultitouch ? @" (multi-touch)" : @"", (long)buttonLifted);
#endif
        self.previousButtonState = latestButtonState;

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
        
        if (self.menuState == TTHUDMenuStateActive) {
            if (buttonPressedDirection == NORTH) {
//                [self fireMenuButton:NORTH];
            } else if (buttonPressedDirection == EAST) {
                [self fireMenuButton:EAST];
            } else if (buttonPressedDirection == WEST) {
                [self fireMenuButton:WEST];
            } else if (buttonPressedDirection == SOUTH) {
//                [self fireMenuButton:SOUTH];
            } else if (state == 0x00) {
                [self activateButton:NO_DIRECTION];
            }
        } else if (doubleState == 0xF &&
            self.lastButtonPressedDirection != NO_DIRECTION &&
            buttonPressedDirection == self.lastButtonPressedDirection &&
            [[NSDate date] timeIntervalSinceDate:self.lastButtonPressStart] < DOUBLE_CLICK_ACTION_DURATION) {
            // Check for double click and setup double click timer
            // Double click detected
            [self fireDoubleButton:buttonPressedDirection];
            self.lastButtonPressedDirection = NO_DIRECTION;
            self.lastButtonPressStart = nil;
        } else if (doubleState != 0xF && doubleState != 0x0) {
            // Firmware v3+ has hardware support for double-click
            [self fireDoubleButton:buttonPressedDirection];
        } else {
            self.lastButtonPressedDirection = buttonPressedDirection;
            self.lastButtonPressStart = [NSDate date];
            
            [self fireButton:buttonPressedDirection];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DOUBLE_CLICK_ACTION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.lastButtonPressedDirection = NO_DIRECTION;
                self.lastButtonPressStart = nil;
            });
        }
    } else if (!latestButtonState.anyPressedDown) {
#if DEBUG_BUTTON_STATE
        NSLog(@" ---> Nothing pressed%@: %d (lifted: %ld)", latestButtonState.inMultitouch ? @" (multi-touch)" : @"", state, buttonLifted);
#endif
        BOOL inMultitouch = self.previousButtonState.inMultitouch;
        self.previousButtonState = latestButtonState;

        if (!inMultitouch && buttonLifted >= 0 && self.menuHysteresis) {
            [self releaseToastActiveMode];
        } else if (self.menuState == TTHUDMenuStateHidden) {
            [self releaseToastActiveMode];
        }
        [self activateButton:NO_DIRECTION];
        self.menuHysteresis = NO;
        self.holdToastStart = nil;
    }
    
#if DEBUG_BUTTON_STATE
    NSLog(@"Buttons: %d: %@", state, self.previousButtonState);
#endif
}

- (void)releaseToastActiveMode {
    [self.appDelegate.hudController releaseToastActiveMode];

    self.holdToastStart = nil;
}

- (void)activateMode:(TTModeDirection)direction {
//    NSLog(@"Selecting mode: %d", activeModeDirection);
    [self.appDelegate.modeMap switchMode:direction modeName:nil];
    
    [self.appDelegate.hudController holdToastActiveMode:YES];

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
    NSString *actionName = [self.appDelegate.modeMap.selectedMode actionNameInDirection:direction];
    [self.appDelegate.modeMap setActiveModeDirection:direction];
    [self.appDelegate.hudController holdToastActiveAction:actionName inDirection:direction];
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    CGFloat deviceInterval = [[preferences objectForKey:@"TT:firmware:interval_max"] integerValue] / 1000.f;
    CGFloat modeChangeDuration = [[preferences objectForKey:@"TT:firmware:mode_duration"] floatValue] / 1000.f;
    CGFloat buttonHoldTimeInterval = MAX(MIN(.15f, modeChangeDuration*0.3f), deviceInterval * 1.05f);
//    NSLog(@"Mode change duration (%f): %f -- %f", buttonHoldTimeInterval, modeChangeDuration*.3f, deviceInterval*1.05f);
    if (direction != NO_DIRECTION) {
#ifndef SKIP_BUTTON_ACTIONS
        if (!self.skipButtonActions) {
            [self.appDelegate.modeMap maybeFireActiveButton];
        }
#endif
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:buttonHoldTimeInterval];
        self.activeModeTimer = [[NSTimer alloc]
                           initWithFireDate:fireDate
                           interval:0
                           target:self
                           selector:@selector(activeModeTimerFire:)
                           userInfo:@{@"activeModeDirection": [NSNumber numberWithInt:direction]}
                           repeats:NO];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self.activeModeTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)fireMenuButton:(TTModeDirection)direction {
    [self.appDelegate.hudController.modeHUDController runDirection:direction];
}

- (void)fireButton:(TTModeDirection)direction {
#ifndef SKIP_BUTTON_ACTIONS
    if (!self.skipButtonActions) {
        [self.appDelegate.modeMap runActiveButton];
    }
#endif
    [self.appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];

    NSString *actionName = [self.appDelegate.modeMap.selectedMode actionNameInDirection:direction];
    [self.appDelegate.hudController toastActiveAction:actionName inDirection:direction];

    [self cancelModeTimer];
//    NSLog(@"Firing button: %@", [appDelegate.modeMap directionName:direction]);
}

- (void)fireDoubleButton:(TTModeDirection)direction {
    if (direction == NO_DIRECTION) return;

#ifndef SKIP_BUTTON_ACTIONS
    if (!self.skipButtonActions) {
        [self.appDelegate.modeMap runDoubleButton:direction];
    }
#endif

    [self.appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    
    NSString *actionName = [self.appDelegate.modeMap.selectedMode actionNameInDirection:direction];
    [self.appDelegate.hudController toastDoubleAction:actionName inDirection:direction];

    [self cancelModeTimer];
}

- (void)cancelModeTimer {
    [self.activeModeTimer invalidate];
    self.activeModeTimer = nil;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.appDelegate.hudController hideModeTease];
    });
}

- (void)activeModeTimerFire:(NSTimer *)timer {
//    NSLog(@"Firing active mode timer: %d", appDelegate.modeMap.activeModeDirection);
    self.activeModeTimer = nil;
    TTModeDirection timerDirection = (TTModeDirection)[[timer.userInfo objectForKey:@"activeModeDirection"]
                                      integerValue];
//    NSLog(@" --> Teasing direction: %@ (%@)", [appDelegate.modeMap directionName:timerDirection], [appDelegate.modeMap directionName:appDelegate.modeMap.activeModeDirection]);
    if (self.appDelegate.modeMap.activeModeDirection == timerDirection) {
//        [appDelegate.hudController teaseMode:timerDirection];
    }
}

#pragma mark - HUD Menu

- (void)closeMenu {
    if (self.menuState != TTHUDMenuStateHidden) {
        self.menuState = TTHUDMenuStateHidden;
        [self.previousButtonState clearState];
    }
}

#pragma mark - Pairing

- (void)resetPairingState {
    self.pairingButtonState = [[TTButtonState alloc] init];
}

- (void)readBluetoothDataDuringPairing:(NSData *)data {
    uint8_t state = [self buttonDownStateFromData:data];
    self.pairingButtonState.north |= !!(state & (1 << 0));
    self.pairingButtonState.east |= !!(state & (1 << 1));
    self.pairingButtonState.west |= !!(state & (1 << 2));
    self.pairingButtonState.south |= !!(state & (1 << 3));
    [self setValue:@([self.pairingButtonState activatedCount]) forKey:@"pairingActivatedCount"];
    
    if ((state & (1 << 0)) == (1 << 0)) {
        [self.appDelegate.modeMap setActiveModeDirection:NORTH];
    } else if ((state & (1 << 1)) == (1 << 1)) {
        [self.appDelegate.modeMap setActiveModeDirection:EAST];
    } else if ((state & (1 << 2)) == (1 << 2)) {
        [self.appDelegate.modeMap setActiveModeDirection:WEST];
    } else if ((state & (1 << 3)) == (1 << 3)) {
        [self.appDelegate.modeMap setActiveModeDirection:SOUTH];
    } else {
        [self.appDelegate.modeMap setActiveModeDirection:NO_DIRECTION];
    }
}

- (BOOL)isDevicePaired {
    return self.pairingActivatedCount.integerValue == self.pairingButtonState.count;
}

- (BOOL)isDirectionPaired:(TTModeDirection)direction {
    switch (direction) {
        case NORTH:
            return self.pairingButtonState.north;
            
        case EAST:
            return self.pairingButtonState.east;
            
        case WEST:
            return self.pairingButtonState.west;
            
        case SOUTH:
            return self.pairingButtonState.south;
            
        default:
            break;
    }
    
    return NO;
}

@end
