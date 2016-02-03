//
//  TTButtonState.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/14/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTButtonState.h"

@implementation TTButtonState

@synthesize north;
@synthesize east;
@synthesize west;
@synthesize south;
@synthesize count;

- (id)init {
    if (self = [super init]) {
        count = 4;
    }
    
    return self;
}

- (BOOL)state:(NSInteger)i {
    switch (i) {
        case 0:
            return north;
        case 1:
            return east;
        case 2:
            return west;
        case 3:
            return south;
        default:
            break;
    }
    
    return NO;
}

- (void)replaceState:(NSInteger)i withState:(BOOL)state {
    switch (i) {
        case 0:
            north = state;
            break;
        case 1:
            east = state;
            break;
        case 2:
            west = state;
            break;
        case 3:
            south = state;
            break;
            
        default:
            break;
    }
}

- (BOOL)anyPressedDown {
    return north || east || west || south;
}

- (BOOL)inMultitouch {
    return (north && east) || (north && west) || (north && south) || (east && west) || (east && south) || (west && south);
 }

- (NSInteger)activatedCount {
    return (north ? 1 : 0) + (east ? 1 : 0) + (west ? 1 : 0) + (south ? 1 : 0);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"N:%d E:%d W:%d S:%d", north, east, west, south];
}

@end
