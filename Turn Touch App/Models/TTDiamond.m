//
//  TTDiamond.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamond.h"
#import "TTModeMusic.h"
#import "TTModeVideo.h"

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
            [self switchMode];
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
    
    [self switchMode];
}

- (void)switchMode {
    if (selectedMode) {
        if ([selectedMode respondsToSelector:@selector(deactivate)]) {
            [selectedMode deactivate];
        }
        selectedMode = nil;
    }
    
    switch (selectedModeDirection) {
        case NORTH:
            selectedMode = [[TTModeMusic alloc] init];
            break;
            
        case EAST:
            selectedMode = nil;
            break;
            
        case SOUTH:
            selectedMode = [[TTModeVideo alloc] init];
            break;
            
        case WEST:
            selectedMode = nil;
            break;
    }
    
    if (selectedMode && [selectedMode respondsToSelector:@selector(activate)]) {
        [selectedMode activate];
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
