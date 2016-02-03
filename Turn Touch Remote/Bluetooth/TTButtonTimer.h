//
//  TTButtonTimer.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTModeMap.h"
#import "TTButtonState.h"

@class TTAppDelegate;

typedef enum {
    PRESS_ACTIVE = 0x01,
    PRESS_TOGGLE = 0x02,
    PRESS_MODE   = 0x03
} TTPressState;

typedef enum {
    TTHUDMenuStateHidden = 0,
    TTHUDMenuStateActive = 1,
} TTHUDMenuState;


@interface TTButtonTimer : NSObject {
    TTAppDelegate *appDelegate;
    NSTimer *activeModeTimer;
    TTButtonState *previousButtonState;
    TTButtonState *pairingButtonState;
    TTModeDirection lastButtonPressedDirection;
    NSDate *lastButtonPressStart;
    NSDate *holdToastStart;
    BOOL menuHysteresis;
}

@property (nonatomic) TTButtonState *previousButtonState;
@property (nonatomic) NSNumber *pairingActivatedCount;
@property (nonatomic) BOOL skipButtonActions;
@property (nonatomic) TTHUDMenuState menuState;

- (void)readBluetoothData:(NSData *)data;
- (void)activateMode:(TTModeDirection)direction;
- (void)activateButton:(TTModeDirection)direction;
- (void)fireButton:(TTModeDirection)direction;
- (void)resetPairingState;
- (void)readBluetoothDataDuringPairing:(NSData *)data;
- (BOOL)isDevicePaired;
- (BOOL)isDirectionPaired:(TTModeDirection)direction;

@end
