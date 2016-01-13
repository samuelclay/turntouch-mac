//
//  TTModeMap.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMap.h"
#import "TTModeMusic.h"
#import "TTModeVideo.h"
#import "TTModeAlarmClock.h"
#import "TTModeNews.h"
#import "TTModeWeb.h"
#import "TTModeMac.h"
#import "TTModeHue.h"
#import "TTBatchAction.h"
#import "TTBatchActions.h"

@implementation TTModeMap

@synthesize selectedModeDirection;
@synthesize activeModeDirection;
@synthesize inspectingModeDirection;
@synthesize hoverModeDirection;
@synthesize openedModeChangeMenu;
@synthesize openedActionChangeMenu;
@synthesize openedAddActionChangeMenu;
@synthesize tempModeName;
@synthesize selectedMode;
@synthesize northMode;
@synthesize eastMode;
@synthesize westMode;
@synthesize southMode;
@synthesize tempMode;
@synthesize batchActions;
@synthesize availableModes;
@synthesize availableActions;
@synthesize availableAddModes;
@synthesize availableAddActions;

- (id)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [self setAvailableModes:@[@"TTModeMac",
                                  @"TTModeAlarmClock",
                                  @"TTModeMusic",
                                  @"TTModeVideo",
                                  @"TTModeNews",
                                  @"TTModeWeb",
                                  @"TTModeHue"]];
        
        activeModeDirection = NO_DIRECTION;
        inspectingModeDirection = NO_DIRECTION;
        hoverModeDirection = NO_DIRECTION;
        openedModeChangeMenu = NO;
        openedActionChangeMenu = NO;
        openedAddActionChangeMenu = NO;
        batchActions = [[TTBatchActions alloc] init];

        [self setupModes];
        
        if ([[defaults objectForKey:@"TT:selectedModeDirection"] integerValue]) {
            selectedModeDirection = (TTModeDirection)[[defaults
                                                       objectForKey:@"TT:selectedModeDirection"]
                                                      integerValue];
        }

        [self registerAsObserver];
    }
    
    return self;
}

- (void)setTempModeName:(NSString *)_tempModeName {
    tempModeName = _tempModeName;
    Class modeClass = NSClassFromString(tempModeName);
    tempMode = [[modeClass alloc] init];
    NSMutableArray *_availableAddActions = [NSMutableArray array];
    for (NSString *action in tempMode.actions) {
        [_availableAddActions addObject:@{@"id": action, @"type": [NSNumber numberWithInt:ADD_ACTION_MENU_TYPE]}];
    }
    availableAddActions = _availableAddActions;
}
- (void)setAvailableModes:(NSArray *)_availableModes {
    availableModes = _availableModes;
    NSMutableArray *_availableAddModes = [NSMutableArray array];
    for (NSString *mode in availableModes) {
        [_availableAddModes addObject:@{@"id": mode, @"type": [NSNumber numberWithInt:ADD_MODE_MENU_TYPE]}];
    }
    availableAddModes = _availableAddModes;
}

- (void)setAvailableActions:(NSArray *)_availableActions {
    availableActions = _availableActions;
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
    [batchActions assembleBatchActions];
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
        case INFO:
            break;
    }
    
    return nil;
}

- (void)maybeFireActiveButton {
    BOOL shouldFireImmediateOnPress = [self shouldFireImmediateOnPress:activeModeDirection];
    if (shouldFireImmediateOnPress && activeModeDirection != NO_DIRECTION) {
        selectedMode.action = [[TTAction alloc] init];
        [selectedMode runDirection:activeModeDirection];
    }
}

- (void)runActiveButton {
    TTModeDirection direction = activeModeDirection;
    activeModeDirection = NO_DIRECTION;
    
    if (!selectedMode) return;

    BOOL shouldIgnoreSingleBeforeDouble = [self shouldIgnoreSingleBeforeDouble:direction];
    if (shouldIgnoreSingleBeforeDouble) {
        waitingForDoubleClick = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DOUBLE_CLICK_ACTION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (waitingForDoubleClick) {
                [self runDirection:direction];
            }
        });
    } else {
        [self runDirection:direction];
    }
    
    activeModeDirection = NO_DIRECTION;
}

- (void)runDirection:(TTModeDirection)direction {
    BOOL shouldFireImmediateOnPress = [self shouldFireImmediateOnPress:direction];
    if (!shouldFireImmediateOnPress) {
        selectedMode.action = [[TTAction alloc] init];
        [selectedMode runDirection:direction];
    }

    NSArray *actions = [self selectedModeBatchActions:direction];
    for (TTAction *batchAction in actions) {
        [batchAction.mode runDirection:direction];
    }
}

- (void)runDoubleButton:(TTModeDirection)direction {
    BOOL shouldFireImmediateOnPress = [self shouldFireImmediateOnPress:direction];
    waitingForDoubleClick = NO;
    activeModeDirection = NO_DIRECTION;
   
    if (!selectedMode) return;
    if (shouldFireImmediateOnPress) return;
    
    [selectedMode runDoubleDirection:direction];

    activeModeDirection = NO_DIRECTION;
}

- (BOOL)shouldIgnoreSingleBeforeDouble:(TTModeDirection)direction {
    BOOL ignore = NO;
    NSString *actionName = [selectedMode actionNameInDirection:direction];
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"shouldIgnoreSingleBeforeDouble%@", actionName]);
    if ([selectedMode respondsToSelector:selector]) {
        IMP imp = [selectedMode methodForSelector:selector];
        BOOL (*func)(id, SEL) = (void *)imp;
        ignore = func(self, selector);
    }
    return ignore;
}

- (BOOL)shouldFireImmediateOnPress:(TTModeDirection)direction {
    BOOL immediate = NO;
    NSString *actionName = [selectedMode actionNameInDirection:direction];
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"shouldFireImmediate%@", actionName]);
    if ([selectedMode respondsToSelector:selector]) {
        IMP imp = [selectedMode methodForSelector:selector];
        BOOL (*func)(id, SEL) = (void *)imp;
        immediate = func(self, selector);
    }
    return immediate;
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
            
        case INFO:
            return @"info";
            break;

        case NO_DIRECTION:
            break;
    }
    
    return nil;
}

#pragma mark - Changing modes, actions, batch actions

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

#pragma mark - Batch actions

- (NSArray *)selectedModeBatchActions:(TTModeDirection)direction {
    return [batchActions batchActionsInDirection:direction];
}

- (void)addBatchAction:(NSString *)actionName {
    NSLog(@"Adding %@ from %@", actionName, NSStringFromClass([tempMode class]));
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Start by reading current array of batch actions in mode's direction's action's direction
    NSString *modeDirectionName = [self directionName:selectedModeDirection];
    NSString *actionDirectionName = [self directionName:inspectingModeDirection];
    NSString *batchKey = [NSString stringWithFormat:@"TT:mode:%@:action:%@:batchactions",
                          modeDirectionName,
                          actionDirectionName];
    NSMutableArray *batchActionKeys;
    NSArray *batchActionsPrefArray = [prefs objectForKey:batchKey];
    if (!batchActionsPrefArray) {
        batchActionKeys = [NSMutableArray array];
    } else {
        batchActionKeys = [batchActionsPrefArray mutableCopy];
    }
    
    // Add new batch action to existing batch actions
    NSString *newActionKey = [NSString stringWithFormat:@"%@:%@:%@",
                              NSStringFromClass([tempMode class]),
                              actionName,
                              [[[NSUUID UUID] UUIDString] substringToIndex:8]];
    [batchActionKeys addObject:newActionKey];
    [prefs setObject:batchActionKeys forKey:batchKey];
    [prefs synchronize];
    
    [batchActions assembleBatchActions];
    
    tempMode = nil;
    tempModeName = nil;

    [self setInspectingModeDirection:inspectingModeDirection];
}

- (void)removeBatchAction:(NSString *)batchActionKey {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *modeDirectionName = [self directionName:selectedModeDirection];
    NSString *actionDirectionName = [self directionName:inspectingModeDirection];
    NSString *batchKey = [NSString stringWithFormat:@"TT:mode:%@:action:%@:batchactions",
                          modeDirectionName,
                          actionDirectionName];
    NSArray *batchActionKeys = [prefs objectForKey:batchKey];
    NSMutableArray *newBatchActionKeys = [NSMutableArray array];
    
    // Take batch action out of existing batch actions
    for (NSString *key in batchActionKeys) {
        if (![key isEqualToString:batchActionKey]) {
            [newBatchActionKeys addObject:key];
        }
    }
    [prefs setObject:newBatchActionKeys forKey:batchKey];
    [prefs synchronize];
    
    [batchActions assembleBatchActions];
    [self setInspectingModeDirection:inspectingModeDirection];
}

#pragma mark - Mode options

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

#pragma mark - Action options

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

- (id)mode:(TTMode *)mode batchAction:(TTAction *)action
actionOptionValue:(NSString *)optionName inDirection:(TTModeDirection)direction {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *modeDirectionName = [self directionName:mode.modeDirection];
    NSString *actionDirectionName = [self directionName:direction];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@:action:%@:batchactions:%@:actionoption:%@",
                           modeDirectionName,
                           actionDirectionName,
                           action.batchActionKey,
                           optionName];
    NSString *pref = [prefs objectForKey:optionKey];
    NSLog(@" -> Getting batch action options %@: %@", optionKey, pref);
    
    if (!pref) {
        pref = [self mode:mode action:action.actionName defaultOption:optionName];
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
    
//    NSLog(@" -> Setting mode option %@ to: %@", optionKey, optionValue);
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

- (void)changeMode:(TTMode *)mode batchActionKey:(NSString *)batchActionKey
      actionOption:(NSString *)optionName to:(id)optionValue {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *modeDirectionName = [self directionName:mode.modeDirection];
    NSString *actionDirectionName = [self directionName:inspectingModeDirection];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@:action:%@:batchactions:%@:actionoption:%@",
                           modeDirectionName,
                           actionDirectionName,
                           batchActionKey,
                           optionName];
    
    NSLog(@" -> Setting batch action option %@ to: %@", optionKey, optionValue);
    [prefs setObject:optionValue forKey:optionKey];
    [prefs synchronize];
}

#pragma mark - Direction helpers

- (void)toggleInspectingModeDirection:(TTModeDirection)direction {
    if (inspectingModeDirection == direction) {
        [self setOpenedActionChangeMenu:NO];
        [self setOpenedAddActionChangeMenu:NO];
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

- (void)setOpenedAddActionChangeMenu:(BOOL)_openedAddActionChangeMenu {
    if (openedAddActionChangeMenu != _openedAddActionChangeMenu) {
        openedAddActionChangeMenu = _openedAddActionChangeMenu;
    }
}

- (NSInteger)progressInDirection:(TTModeDirection)direction {
    return [selectedMode progressInDirection:direction];
}


@end
