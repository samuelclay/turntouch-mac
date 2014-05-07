//
//  TTMode.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTModeProtocol.h"

typedef enum {
    NO_DIRECTION = 0,
    NORTH = 1,
    EAST = 2,
    WEST = 3,
    SOUTH = 4
} TTModeDirection;

@interface TTMode : NSObject
<TTModeProtocol>

- (void)runDirection:(TTModeDirection)direction;
- (NSString *)titleInDirection:(TTModeDirection)direction;
- (NSImage *)imageInDirection:(TTModeDirection)direction;

@end
