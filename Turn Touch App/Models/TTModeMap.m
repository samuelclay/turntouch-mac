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
    
    [self setAvailableActions:selectedMode.actions];
    if (selectedMode && [selectedMode respondsToSelector:@selector(activate)]) {
        [selectedMode activate];
        [self reset];
    }
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

- (NSString *)modeOptionValue:(NSString *)optionName {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *directionName = [self directionName:selectedModeDirection];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:option:%@",
                           NSStringFromClass([selectedMode class]),
                           directionName,
                           optionName];

    NSString *pref = [prefs objectForKey:optionKey];
    
    if (!pref) {
        pref = [self selectedModeDefaultPreference:optionName];

    }
    
    return pref;
}

- (NSString *)actionOptionValue:(NSString *)optionName {
    return [self actionOptionValue:optionName inDirection:inspectingModeDirection];
}

- (NSString *)actionOptionValue:(NSString *)optionName inDirection:(TTModeDirection)direction {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *modeDirectionName = [self directionName:selectedModeDirection];
    NSString *actionDirectionName = [self directionName:direction];
    NSString *actionName = [selectedMode actionNameInDirection:direction];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:action:%@-%@:option:%@",
                           NSStringFromClass([selectedMode class]),
                           modeDirectionName,
                           actionName,
                           actionDirectionName,
                           optionName];
    
    NSString *pref = [prefs objectForKey:optionKey];
    
    if (!pref) {
        pref = [self selectedActionDefaultPreference:actionName withOption:optionName];
    }
    if (!pref) {
        pref = [self selectedModeDefaultPreference:optionName];
    }
    
    return pref;
}

- (NSString *)selectedModeDefaultPreference:(NSString *)optionName {
    NSString *modeOptionsDefaults = NSStringFromClass([selectedMode class]);
    NSString *defaultPrefsFile = [[NSBundle mainBundle]
                                  pathForResource:modeOptionsDefaults
                                  ofType:@"plist"];
    NSDictionary *modeDefaults = [NSDictionary
                                  dictionaryWithContentsOfFile:defaultPrefsFile];
    
    return [modeDefaults objectForKey:optionName];
}

- (NSString *)selectedActionDefaultPreference:(NSString *)actionName withOption:(NSString *)optionName {
    NSString *modeOptionsDefaults = NSStringFromClass([selectedMode class]);
    NSString *defaultPrefsFile = [[NSBundle mainBundle]
                                  pathForResource:modeOptionsDefaults
                                  ofType:@"plist"];
    NSDictionary *modeDefaults = [NSDictionary
                                  dictionaryWithContentsOfFile:defaultPrefsFile];
    NSString *optionKey = [NSString stringWithFormat:@"%@:%@", actionName, optionName];
    
    return [modeDefaults objectForKey:optionKey];
}

- (void)changeModeOption:(NSString *)optionName to:(id)optionValue {
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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *modeDirectionName = [self directionName:selectedModeDirection];
    NSString *actionDirectionName = [self directionName:inspectingModeDirection];
    NSString *actionName = [selectedMode actionNameInDirection:inspectingModeDirection];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:action:%@-%@:option:%@",
                           NSStringFromClass([selectedMode class]),
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

@end
