//
//  TTButtonState.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/14/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTButtonState.h"

@implementation TTButtonState

- (id)init {
    if (self = [super init]) {
        self.count = 4;
    }
    
    return self;
}

- (BOOL)state:(NSInteger)i {
    switch (i) {
        case 0:
            return self.north;
        case 1:
            return self.east;
        case 2:
            return self.west;
        case 3:
            return self.south;
        default:
            break;
    }
    
    return NO;
}

- (void)replaceState:(NSInteger)i withState:(BOOL)state {
    switch (i) {
        case 0:
            self.north = state;
            break;
        case 1:
            self.east = state;
            break;
        case 2:
            self.west = state;
            break;
        case 3:
            self.south = state;
            break;
            
        default:
            break;
    }
}

- (void)clearState {
    self.north = NO;
    self.east = NO;
    self.west = NO;
    self.south = NO;
}

- (BOOL)anyPressedDown {
    return self.north || self.east || self.west || self.south;
}

- (BOOL)inMultitouch {
    return (self.north && self.east) || (self.north && self.west) || (self.north && self.south) || (self.east && self.west) || (self.east && self.south) || (self.west && self.south);
 }

- (NSInteger)activatedCount {
    return (self.north ? 1 : 0) + (self.east ? 1 : 0) + (self.west ? 1 : 0) + (self.south ? 1 : 0);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"N:%d E:%d W:%d S:%d", self.north, self.east, self.west, self.south];
}

@end
