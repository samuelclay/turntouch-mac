//
//  TTDiamond.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamond.h"
#import "TTModeMusic.h"

@implementation TTDiamond

@synthesize selectedModeDirection;
@synthesize activeModeDirection;
@synthesize selectedMode;

- (id)init {
    if (self = [super init]) {
        [self addObserver:self
               forKeyPath:@"selectedModeDirection"
                  options:0 context:nil];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[defaults objectForKey:@"TT:selectedModeDirection"] integerValue]) {
            selectedModeDirection = (TTModeDirection)[[defaults
                                                       objectForKey:@"TT:selectedModeDirection"]
                                                      integerValue];
        }
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:selectedModeDirection]
                 forKey:@"TT:selectedModeDirection"];
    [defaults synchronize];
    
    if (selectedMode) {
        if ([selectedMode respondsToSelector:@selector(deactivate)]) {
            [selectedMode deactivate];
        }
    }
    
    if (selectedModeDirection == NORTH) {
        selectedMode = [[TTModeMusic alloc] init];
        if ([selectedMode respondsToSelector:@selector(activate)]) {
            [selectedMode activate];
        }
    } else if (selectedModeDirection == EAST) {
        selectedMode = nil;
    } else if (selectedModeDirection == SOUTH) {
        selectedMode = nil;
    } else if (selectedModeDirection == WEST) {
        selectedMode = nil;
    }
}

- (void)runActiveButton {
    TTModeDirection direction = activeModeDirection;
    activeModeDirection = 0;
    
    if (!selectedMode) return;
    
    if (direction == NORTH) {
        [selectedMode runNorth];
    } else if (direction == EAST) {
        [selectedMode runEast];
    } else if (direction == SOUTH) {
        [selectedMode runSouth];
    } else if (direction == WEST) {
        [selectedMode runWest];
    }
    activeModeDirection = 0;
}

@end
