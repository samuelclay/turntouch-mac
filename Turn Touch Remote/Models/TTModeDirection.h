//
//  TTModeDirection.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/7/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NO_DIRECTION = 0,
    NORTH = 1,
    EAST = 2,
    WEST = 3,
    SOUTH = 4,
    INFO = 5
} TTModeDirection;


typedef enum {
    BUTTON_ACTION_OFF = 0,
    BUTTON_ACTION_PRESSDOWN = 1,
    BUTTON_ACTION_PRESSUP = 2,
    BUTTON_ACTION_HELD = 3,
    BUTTON_ACTION_DOUBLE = 4,
} TTButtonAction;
