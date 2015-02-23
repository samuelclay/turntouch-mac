//
//  TTModeMap.m
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
#import "TTModeHue.h"

@implementation TTModeMap

@synthesize selectedModeDirection;
@synthesize activeModeDirection;
@synthesize inspectingModeDirection;
@synthesize hoverModeDirection;
@synthesize openedModeChangeMenu;
@synthesize openedActionChangeMenu;
@synthesize selectedMode;
@synthesize northMode;
@synthesize eastMode;
@synthesize westMode;
@synthesize southMode;
@synthesize availableModes;
@synthesize availableActions;

- (id)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        availableModes = @[@"TTModeMac",
                           @"TTModeAlarmClock",
                           @"TTModeMusic",
                           @"TTModeVideo",
                           @"TTModeNews",
                           @"TTModeHue"];
        
        activeModeDirection = NO_DIRECTION;
        inspectingModeDirection = NO_DIRECTION;
        hoverModeDirection = NO_DIRECTION;
        openedModeChangeMenu = NO;
        openedActionChangeMenu = NO;
        
        [self setupModes];
        
        if ([[defaults objectForKey:@"TT:selectedModeDirection"] integerValue]) {
            selectedModeDirection = (TTModeDirection)[[defaults
                                                       objectForKey:@"TT:selectedModeDirection"]
                                                      integerValue];
            [self switchMode];
        }

        [self registerAsObserver];
    }
    
    return self;
}

#pragma mark - KVO

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"selectedModeDirection"];
}

- (void)registerAsObserver {
    [self addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInt:selectedModeDirection]
                     forKey:@"TT:selectedModeDirection"];
        [defaults synchronize];
        
        [self switchMode];
    }
}

#pragma mark - Actions

- (void)reset {
    [self setInspectingModeDirection:NO_DIRECTION];
    [self setHoverModeDirection:NO_DIRECTION];
}

- (void)setupModes {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    for (NSString *direction in @[@"north", @"east", @"west", @"south"]) {
        NSString *directionModeName = [prefs stringForKey:[NSString stringWithFormat:@"TT:mode:%@", direction]];
        Class modeClass = NSClassFromString(directionModeName);
        [self setValue:[[modeClass alloc] init] forKey:[NSString stringWithFormat:@"%@Mode", direction]];
    }
    
    northMode.modeDirection = NORTH;
    eastMode.modeDirection = EAST;
    westMode.modeDirection = WEST;
    southMode.modeDirection = SOUTH;
}

- (void)activateTimers {
    for (TTMode *mode in @[northMode, eastMode, westMode, southMode]) {
        if ([mode respondsToSelector:@selector(activateTimers)]) {
            [mode activateTimers];
        }
    }
}

- (void)switchMode {
    if (selectedMode) {
        if ([selectedMode respondsToSelector:@selector(deactivate)]) {
            [selectedMode deactivate];
        }
        selectedMode = nil;
    }
    
    if (selectedModeDirection != NO_DIRECTION) {
        [self setSelectedMode:[self modeInDirection:selectedModeDirection]];
    }
    
    [self setAvailableActions:selectedMode.actions];
    if (selectedMode && [selectedMode respondsToSelector:@selector(activate)]) {
        [selectedMode activate:selectedModeDirection];
        [self reset];
    }
}

- (TTMode *)modeInDirection:(TTModeDirection)direction {
    switch (direction) {
        case NORTH:
            return northMode;
            break;
            
        case EAST:
            return eastMode;
            break;
            
        case WEST:
            return westMode;
            break;
            
        case SOUTH:
            return southMode;
            break;
            
        case NO_DIRECTION:
            break;
    }
    
    return nil;
}

- (void)runActiveButton {
    TTModeDirection direction = activeModeDirection;
    activeModeDirection = NO_DIRECTION;
    
    if (!selectedMode) return;

    [selectedMode runDirection:direction];

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

#pragma mark - Changing modes, actions, and options

- (void)changeDirection:(TTModeDirection)direction toMode:(NSString *)modeClassName {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *directionName = [self directionName:direction];
    NSString *prefKey = [NSString stringWithFormat:@"TT:mode:%@", directionName];
    
    [prefs setObject:modeClassName forKey:prefKey];
    [prefs synchronize];
    
    [self setupModes];
    [self switchMode];
}

- (void)changeDirection:(TTModeDirection)direction toAction:(NSString *)actionClassName {
    [selectedMode changeDirection:direction toAction:actionClassName];
}

- (id)modeOptionValue:(NSString *)optionName {
    return [self mode:selectedMode optionValue:optionName];
}

- (id)mode:(TTMode *)mode optionValue:(NSString *)optionName {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *directionName = [self directionName:mode.modeDirection];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:option:%@",
                           NSStringFromClass([mode class]),
                           directionName,
                           optionName];

    id pref = [prefs objectForKey:optionKey];

//    NSLog(@" -> Getting mode option %@: %@", optionKey, pref);
    if (!pref) {
        pref = [self mode:mode defaultOption:optionName];
    }
    
    return pref;
}

- (id)actionOptionValue:(NSString *)optionName {
    return [self actionOptionValue:optionName inDirection:inspectingModeDirection];
}

- (id)actionOptionValue:(NSString *)optionName inDirection:(TTModeDirection)direction {
    return [self mode:selectedMode actionOptionValue:optionName inDirection:direction];
}

- (id)mode:(TTMode *)mode actionOptionValue:(NSString *)optionName inDirection:(TTModeDirection)direction {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *modeDirectionName = [self directionName:mode.modeDirection];
    NSString *actionDirectionName = [self directionName:direction];
    NSString *actionName = [mode actionNameInDirection:direction];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:action:%@-%@:option:%@",
                           NSStringFromClass([mode class]),
                           modeDirectionName,
                           actionName,
                           actionDirectionName,
                           optionName];
    NSString *pref = [prefs objectForKey:optionKey];
//    NSLog(@" -> Getting action options %@: %@", optionKey, pref);
    
    if (!pref) {
        pref = [self mode:mode action:actionName defaultOption:optionName];
    }
    if (!pref) {
        pref = [self mode:mode defaultOption:optionName];
    }
    
    return pref;
}

- (id)mode:(TTMode *)mode defaultOption:(NSString *)optionName {
    NSString *modeOptionsDefaults = NSStringFromClass([mode class]);
    NSString *defaultPrefsFile = [[NSBundle mainBundle]
                                  pathForResource:modeOptionsDefaults
                                  ofType:@"plist"];
    NSDictionary *modeDefaults = [NSDictionary
                                  dictionaryWithContentsOfFile:defaultPrefsFile];
//    NSLog(@" -> Getting mode option default %@: %@", optionName, [modeDefaults objectForKey:optionName]);

    return [modeDefaults objectForKey:optionName];
}

- (id)mode:(TTMode *)mode action:(NSString *)actionName defaultOption:(NSString *)optionName {
    NSString *modeOptionsDefaults = NSStringFromClass([mode class]);
    NSString *defaultPrefsFile = [[NSBundle mainBundle]
                                  pathForResource:modeOptionsDefaults
                                  ofType:@"plist"];
    NSDictionary *modeDefaults = [NSDictionary
                                  dictionaryWithContentsOfFile:defaultPrefsFile];
    NSString *optionKey = [NSString stringWithFormat:@"%@:%@", actionName, optionName];
    
    return [modeDefaults objectForKey:optionKey];
}

- (void)changeModeOption:(NSString *)optionName to:(id)optionValue {
    [self changeMode:selectedMode option:optionName to:optionValue];
}

- (void)changeMode:(TTMode *)mode option:(NSString *)optionName to:(id)optionValue {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *directionName = [self directionName:selectedModeDirection];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:option:%@",
                           NSStringFromClass([selectedMode class]),
                           directionName,
                           optionName];
    
    NSLog(@" -> Setting mode option %@ to: %@", optionKey, optionValue);
    [prefs setObject:optionValue forKey:optionKey];
    [prefs synchronize];
}

- (void)changeActionOption:(NSString *)optionName to:(id)optionValue {
    [self changeMode:selectedMode actionOption:optionName to:optionValue];
}

- (void)changeMode:(TTMode *)mode actionOption:(NSString *)optionName to:(id)optionValue {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *modeDirectionName = [self directionName:mode.modeDirection];
    NSString *actionDirectionName = [self directionName:inspectingModeDirection];
    NSString *actionName = [mode actionNameInDirection:inspectingModeDirection];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:action:%@-%@:option:%@",
                           NSStringFromClass([mode class]),
                           modeDirectionName,
                           actionName,
                           actionDirectionName,
                           optionName];

    NSLog(@" -> Setting action option %@ to: %@", optionKey, optionValue);
    [prefs setObject:optionValue forKey:optionKey];
    [prefs synchronize];
}

#pragma mark - Direction helpers

- (void)toggleInspectingModeDirection:(TTModeDirection)direction {
    if (inspectingModeDirection == direction) {
        [self setOpenedActionChangeMenu:NO];
        [self setInspectingModeDirection:NO_DIRECTION];
    } else {
        [self setInspectingModeDirection:direction];
    }
}

- (void)toggleHoverModeDirection:(TTModeDirection)direction hovering:(BOOL)hovering {
    if (!hovering) {
        [self setHoverModeDirection:NO_DIRECTION];
    } else {
        [self setHoverModeDirection:direction];
    }
}

- (void)setInspectingModeDirection:(TTModeDirection)_inspectingModeDirection {
    if (inspectingModeDirection != _inspectingModeDirection) {
        inspectingModeDirection = _inspectingModeDirection;
    }
}

- (void)setHoverModeDirection:(TTModeDirection)_hoverModeDirection {
    if (hoverModeDirection != _hoverModeDirection) {
        hoverModeDirection = _hoverModeDirection;
    }
}

- (void)setOpenedModeChangeMenu:(BOOL)_openedModeChangeMenu {
    if (openedModeChangeMenu != _openedModeChangeMenu) {
        openedModeChangeMenu = _openedModeChangeMenu;
    }
}

- (void)setOpenedActionChangeMenu:(BOOL)_openedActionChangeMenu {
    if (openedActionChangeMenu != _openedActionChangeMenu) {
        openedActionChangeMenu = _openedActionChangeMenu;
    }
}

- (NSInteger)progressInDirection:(TTModeDirection)direction {
    return [selectedMode progressInDirection:direction];
}


@end
