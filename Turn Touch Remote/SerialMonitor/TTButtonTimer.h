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

@interface TTButtonTimer : NSObject {
    TTAppDelegate *appDelegate;
    NSTimer *activeModeTimer;
    TTButtonState *buttonState;
    TTButtonState *pairingButtonState;
    BOOL inMultitouch;
    NSDate *holdToastStart;
}

- (void)readBluetoothData:(NSData *)data;
- (void)selectActiveMode:(TTModeDirection)direction;
- (void)activateButton:(TTModeDirection)direction;
- (void)fireButton:(TTModeDirection)direction;
- (void)resetPairingState;
- (void)readBluetoothDataDuringPairing:(NSData *)data;

@end
