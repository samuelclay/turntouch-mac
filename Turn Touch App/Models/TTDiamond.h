//
//  TTDiamond.h
//  Turn Touch App
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    NORTH = 1,
    EAST = 2,
    SOUTH = 3,
    WEST = 4
} TTMode;

@interface TTDiamond : NSObject

@property (nonatomic, assign) TTMode activeMode;

@end
