//
//  TTDiamond.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMap.h"
#import "TTModeMusic.h"
#import "TTModeVideo.h"
#import "TTModeAlarmClock.h"
#import "TTModeNews.h"
#import "TTModeMac.h"

@implementation TTModeMap

@synthesize selectedModeDirection;
@synthesize activeModeDirection;
@synthesize inspectingModeDirection;
@synthesize selectedMode;
@synthesize northMode;
@synthesize eastMode;
@synthesize westMode;
@synthesize southMode;
@synthesize availableModes;

- (id)init {
    if (self = [super init]) {
        [self addObserver:self
               forKeyPath:@"selectedModeDirection"
                  options:0 context:nil];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        availableModes = @[@"TTModeMac",
                           @"TTModeAlarmClock",
                           @"TTModeMusic",
                           @"TTModeVideo",
                           @"TTModeNews"];
        
        activeModeDirection = NO_DIRECTION;
        inspectingModeDirection = NO_DIRECTION;
        
        [self setupModes];
        
        if ([[defaults objectForKey:@"TT:selectedModeDirection"] integerValue]) {
            selectedModeDirection = (TTModeDirection)[[defaults
                                                       objectForKey:@"TT:selectedModeDirection"]
                                                      integerValue];
            [self switchMode];
        }
    }
    
    return self;
}

- (void)reset {
    [self setInspectingModeDirection:NO_DIRECTION];
}

- (void)setupModes {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    for (NSString *direction in @[@"north", @"east", @"west", @"south"]) {
        NSString *directionModeName = [prefs stringForKey:[NSString stringWithFormat:@"TT:mode:%@", direction]];
        Class modeClass = NSClassFromString(directionModeName);
        [self setValue:[[modeClass alloc] init] forKey:[NSString stringWithFormat:@"%@Mode", direction]];
    }
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
            [self setSelectedMode:northMode];
            break;
            
        case EAST:
            [self setSelectedMode:eastMode];
            break;
            
        case WEST:
            [self setSelectedMode:westMode];
            break;

        case SOUTH:
            [self setSelectedMode:southMode];
            break;
            
        case NO_DIRECTION:
            break;
    }
    
    if (selectedMode && [selectedMode respondsToSelector:@selector(activate)]) {
        [selectedMode activate];
        [self reset];
    }
}

- (void)runActiveButton {
    TTModeDirection direction = activeModeDirection;
    activeModeDirection = NO_DIRECTION;
    
    if (!selectedMode) return;
    
    if (direction == NORTH) {
        [selectedMode runNorth];
    } else if (direction == EAST) {
        [selectedMode runEast];
    } else if (direction == WEST) {
        [selectedMode runWest];
    } else if (direction == SOUTH) {
        [selectedMode runSouth];
    }
    activeModeDirection = NO_DIRECTION;
}

- (NSString *)directionName:(TTModeDirection)direction {
    switch (direction) {
        case NORTH:
            return @"north";
            break;
        
        case EAST:
            return @"east";
            break;
            
        case WEST:
            return @"west";
            break;
            
        case SOUTH:
            return @"south";
            break;

        case NO_DIRECTION:
            break;
    }
    
    return nil;
}

- (NSArray *)availableModeClassNames {
    NSMutableArray *classes = [NSMutableArray new];
    
    for (NSString *modeClass in availableModes) {
        [classes addObject:modeClass];
    }
    
    return classes;
}

- (NSArray *)availableModeTitles {
    NSMutableArray *titles = [NSMutableArray new];
    
    for (NSString *modeName in availableModes) {
        Class modeClass = NSClassFromString(modeName);
        NSString *title = [modeClass title];
        [titles addObject:[NSString stringWithFormat:@"%@ mode", title]];
    }
    
    return titles;
}

- (void)changeDirection:(TTModeDirection)direction toMode:(NSString *)modeClassName {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *directionName = [self directionName:direction];
    NSString *prefKey = [NSString stringWithFormat:@"TT:mode:%@", directionName];
    
    [prefs setObject:modeClassName forKey:prefKey];
    [prefs synchronize];
    
    [self setupModes];
    [self switchMode];
}

- (void)toggleInspectingModeDirection:(TTModeDirection)direction {
    if (inspectingModeDirection == direction) {
        [self setInspectingModeDirection:NO_DIRECTION];
    } else {
        [self setInspectingModeDirection:direction];
    }
}

@end
