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
    PRESS_ACTIVE = 1,
    PRESS_TOGGLE = 2,
    PRESS_MODE = 3
} TTPressState;

@interface TTButtonTimer : NSObject {
    TTAppDelegate *appDelegate;
    TTModeDirection activeModeDirection;
    NSTimer *activeModeTimer;
}

- (void)readButtons:(NSArray *)buttons;
- (void)selectActiveMode:(TTModeDirection)direction;
- (void)activateButton:(TTModeDirection)direction;
- (void)deactivateButton;
- (void)fireButton:(TTModeDirection)direction;

@end
