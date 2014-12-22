//
//  TTButtonTimer.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTModeMap.h"

@class TTAppDelegate;

typedef enum {
    PRESS_ACTIVE = 0x01,
    PRESS_TOGGLE = 0x02,
    PRESS_MODE   = 0x03
} TTPressState;

@interface TTButtonTimer : NSObject {
    TTAppDelegate *appDelegate;
    TTModeDirection activeModeDirection;
    NSTimer *activeModeTimer;
    NSArray *buttonState;
    BOOL inMultitouch;
}

- (void)readButtons:(NSArray *)buttons;
- (void)readBTData:(NSData *)data;
- (void)selectActiveMode:(TTModeDirection)direction;
- (void)activateButton:(TTModeDirection)direction;
- (void)deactivateButton;
- (void)fireButton:(TTModeDirection)direction;

@end
