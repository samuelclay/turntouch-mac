//
//  TTDiamond.h
//  Turn Touch App
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    NORTH,
    EAST,
    SOUTH,
    WEST
} TTMode;

@interface TTDiamond : NSObject

@property (nonatomic, assign) TTMode activeMode;

@end
