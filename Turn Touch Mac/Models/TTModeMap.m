//
//  TTModeMap.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#import "TTModeMap.h"
#import "TTModeMusic.h"
#import "TTModeVideo.h"
#import "TTModeAlarmClock.h"
#import "TTModeNews.h"
#import "TTModeWeb.h"
#import "TTModeMac.h"
#import "TTModeHue.h"
#import "TTModeNest.h"
#import "TTModeWemo.h"
#import "TTModeCustom.h"
#import "TTModeSpotify.h"
#import "TTBatchActions.h"
#import "TTModeIfttt.h"
#import "TTModeSonos.h"
#import "TTModePresentation.h"

@interface TTModeMap ()

@property (nonatomic) BOOL waitingForDoubleClick;

@end

@implementation TTModeMap

- (id)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [self setAvailableModes:@[@"TTModeMac",
                                  @"TTModeMusic",
                                  @"TTModeHue",
                                  @"TTModeNest",
                                  @"TTModeIfttt",
                                  @"TTModeSonos",
                                  @"TTModeWemo",
                                  @"TTModeAlarmClock",
                                  @"TTModeSpotify",
                                  @"TTModeAirfoil",
                                  @"TTModeVideo",
                                  @"TTModeNews",
                                  @"TTModeWeb",
                                  @"TTModePresentation",
                                  @"TTModeCustom"]];
        
        self.activeModeDirection = NO_DIRECTION;
        self.inspectingModeDirection = NO_DIRECTION;
        self.hoverModeDirection = NO_DIRECTION;
        self.lastInspectingModeDirection = NORTH;
        self.openedModeChangeMenu = NO;
        self.openedActionChangeMenu = NO;
        self.openedAddActionChangeMenu = NO;
        self.openedChangeActionMenu = NO;
        self.batchActions = [[TTBatchActions alloc] init];

        [self setupModes];
        
        if ([[defaults objectForKey:@"TT:selectedModeDirection"] integerValue]) {
            self.selectedModeDirection = (TTModeDirection)[[defaults
                                                       objectForKey:@"TT:selectedModeDirection"]
                                                      integerValue];
        }

        [self registerAsObserver];
    }
    
    return self;
}

- (void)setTempModeName:(NSString *)tempModeName {
    _tempModeName = tempModeName;
    Class modeClass = NSClassFromString(self.tempModeName);
    self.tempMode = [[modeClass alloc] init];
    NSMutableArray *_availableAddActions = [NSMutableArray array];
    for (NSString *action in self.tempMode.actions) {
        [_availableAddActions addObject:@{@"id": action, @"type": [NSNumber numberWithInt:ADD_ACTION_MENU_TYPE]}];
    }
    self.availableAddActions = _availableAddActions;
}

- (void)setAvailableModes:(NSArray *)availableModes {
    _availableModes = availableModes;
    NSMutableArray *_availableAddModes = [NSMutableArray array];
    for (NSString *mode in self.availableModes) {
        [_availableAddModes addObject:@{@"id": mode, @"type": [NSNumber numberWithInt:ADD_MODE_MENU_TYPE]}];
    }
    self.availableAddModes = _availableAddModes;
}


- (void)setBatchActionChangeAction:(TTAction *)batchActionChangeAction {
    _batchActionChangeAction = batchActionChangeAction;
    NSMutableArray *_availableAddActions = [NSMutableArray array];
    for (NSString *action in self.batchActionChangeAction.mode.actions) {
        [_availableAddActions addObject:@{@"id": action, @"type": [NSNumber numberWithInt:CHANGE_BATCH_ACTION_MENU_TYPE]}];
    }
    self.availableAddActions = _availableAddActions;
}

#pragma mark - KVO

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"selectedModeDirection"];
    [self removeObserver:self forKeyPath:@"inspectingModeDirection"];
}

- (void)registerAsObserver {
    [self addObserver:self forKeyPath:@"selectedModeDirection"
              options:0 context:nil];
    [self addObserver:self forKeyPath:@"inspectingModeDirection"
              options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        if (self.selectedModeDirection == NO_DIRECTION) return;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInt:self.selectedModeDirection]
                     forKey:@"TT:selectedModeDirection"];
        [defaults synchronize];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        if (self.inspectingModeDirection == NO_DIRECTION) return;
        
        self.lastInspectingModeDirection = self.inspectingModeDirection;
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
    
    self.northMode.modeDirection = NORTH;
    self.eastMode.modeDirection = EAST;
    self.westMode.modeDirection = WEST;
    self.southMode.modeDirection = SOUTH;
}

- (void)activateTimers {
    for (TTMode *mode in @[self.northMode, self.eastMode, self.westMode, self.southMode]) {
        if ([mode respondsToSelector:@selector(activateTimers)]) {
            [mode activateTimers];
        }
    }
}

- (void)switchMode {
    [self switchMode:self.selectedModeDirection modeName:nil];
}

- (void)switchMode:(TTModeDirection)direction modeName:(NSString *)modeName {
    [self setActiveModeDirection:NO_DIRECTION];
    
    if (self.selectedMode) {
        [self.batchActions deactivate];
        
        if ([self.selectedMode respondsToSelector:@selector(deactivate)]) {
            [self.selectedMode deactivate];
        }
        self.selectedMode = nil;
    }
    
    if (direction != NO_DIRECTION) {
        [self setSelectedMode:[self modeInDirection:direction]];
    } else {
        Class modeClass = NSClassFromString(modeName);
        TTMode *mode = [[modeClass alloc] init];
        [self setSelectedMode:mode];
    }
    
    [self setAvailableActions:self.selectedMode.actions];
    [self.selectedMode activate:direction];
    [self reset];
    
    self.selectedModeDirection = direction;
    
    [self.batchActions assembleBatchActions];
    
    [self recordButtonMoment:direction buttonMoment:BUTTON_MOMENT_HELD];
}

- (void)maybeFireActiveButton {
    BOOL shouldFireImmediateOnPress = [self.selectedMode shouldFireImmediateOnPress:self.activeModeDirection];
    if (shouldFireImmediateOnPress && self.activeModeDirection != NO_DIRECTION) {
        self.selectedMode.action = [[TTAction alloc] initWithActionName:[self.selectedMode actionNameInDirection:self.activeModeDirection]
                                                         direction:self.activeModeDirection];
        [self.selectedMode runDirection:self.activeModeDirection];
    }
}

- (void)runActiveButton {
    TTModeDirection direction = self.activeModeDirection;
    self.activeModeDirection = NO_DIRECTION;
    BOOL shouldFireImmediateOnPress = [self.selectedMode shouldFireImmediateOnPress:direction];
    
    if (!self.selectedMode) return;
    if (shouldFireImmediateOnPress) return; // Already fired by now, on press up
    
    if ([self.selectedMode shouldIgnoreSingleBeforeDouble:direction]) {
        self.waitingForDoubleClick = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DOUBLE_CLICK_ACTION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.waitingForDoubleClick) {
                [self runDirection:direction];
            }
        });
    } else {
        [self runDirection:direction];
    }
}

- (void)runDirection:(TTModeDirection)direction {
    BOOL shouldFireImmediateOnPress = [self.selectedMode shouldFireImmediateOnPress:direction];
    if (!shouldFireImmediateOnPress) {
        self.selectedMode.action = [[TTAction alloc] initWithActionName:[self.selectedMode actionNameInDirection:direction]
                                                         direction:direction];
        [self.selectedMode runDirection:direction];
    }

    NSArray *actions = [self selectedModeBatchActions:direction];
    for (TTAction *batchAction in actions) {
        [batchAction.mode runDirection:direction];
    }
    
    [self recordButtonMoment:direction buttonMoment:BUTTON_MOMENT_PRESSUP];
}

- (void)runDoubleButton:(TTModeDirection)direction {
            BOOL shouldFireImmediateOnPress = [self.selectedMode shouldFireImmediateOnPress:direction];
    self.waitingForDoubleClick = NO;
    self.activeModeDirection = NO_DIRECTION;
   
    if (!self.selectedMode) return;
    if (shouldFireImmediateOnPress) return;
    
    [self.selectedMode runDoubleDirection:direction];

    NSArray *actions = [self selectedModeBatchActions:direction];
    for (TTAction *batchAction in actions) {
        [batchAction.mode runDoubleDirection:direction];
    }

    [self recordButtonMoment:direction buttonMoment:BUTTON_MOMENT_DOUBLE];

    self.activeModeDirection = NO_DIRECTION;
}

- (BOOL)shouldHideHud:(TTModeDirection)direction {
    BOOL hideHud = NO;
    NSString *actionName = [self.selectedMode actionNameInDirection:direction];
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"shouldHideHud%@", actionName]);
    if ([self.selectedMode respondsToSelector:selector]) {
        IMP imp = [self.selectedMode methodForSelector:selector];
        BOOL (*func)(id, SEL) = (void *)imp;
        hideHud = func(self.selectedMode, selector);
    }
    return hideHud;
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
    [self.selectedMode changeDirection:direction toAction:actionClassName];
}

#pragma mark - Batch actions

- (NSArray *)selectedModeBatchActions:(TTModeDirection)direction {
    return [self.batchActions batchActionsInDirection:direction];
}

- (void)addBatchAction:(NSString *)actionName {
    NSLog(@"Adding %@ from %@", actionName, NSStringFromClass([self.tempMode class]));
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Start by reading current array of batch actions in mode's direction's action's direction
    NSString *modeDirectionName = [self directionName:self.selectedModeDirection];
    NSString *actionDirectionName = [self directionName:self.inspectingModeDirection];
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
                              NSStringFromClass([self.tempMode class]),
                              actionName,
                              [[[NSUUID UUID] UUIDString] substringToIndex:8]];
    [batchActionKeys addObject:newActionKey];
    [prefs setObject:batchActionKeys forKey:batchKey];
    [prefs synchronize];
    
    [self.batchActions assembleBatchActions];
    
    self.tempMode = nil;
    self.tempModeName = nil;

    [self setInspectingModeDirection:self.inspectingModeDirection];
}

- (void)changeBatchAction:(NSString *)batchActionKey toAction:(NSString *)actionName {
    NSLog(@"Changing %@ from %@", actionName, NSStringFromClass([self.batchActionChangeAction class]));
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Start by reading current array of batch actions in mode's direction's action's direction
    NSString *modeDirectionName = [self directionName:self.selectedModeDirection];
    NSString *actionDirectionName = [self directionName:self.inspectingModeDirection];
    NSString *batchKey = [NSString stringWithFormat:@"TT:mode:%@:action:%@:batchactions",
                          modeDirectionName,
                          actionDirectionName];
    NSArray *batchActionKeys = [prefs objectForKey:batchKey];
    NSMutableArray *newBatchActionKeys = [NSMutableArray array];
    
    // Replace batch action in existing batch actions
    for (NSString *key in batchActionKeys) {
        if (![key isEqualToString:batchActionKey]) {
            [newBatchActionKeys addObject:key];
        } else {
            NSArray *keyParts = [key componentsSeparatedByString:@":"];
            NSString *newActionKey = [NSString stringWithFormat:@"%@:%@:%@",
                                      NSStringFromClass([self.batchActionChangeAction.mode class]),
                                      actionName,
                                      keyParts[2]];
            [newBatchActionKeys addObject:newActionKey];
        }
    }
    [prefs setObject:newBatchActionKeys forKey:batchKey];
    [prefs synchronize];
    
    [self.batchActions assembleBatchActions];
}

- (void)removeBatchAction:(NSString *)batchActionKey {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *modeDirectionName = [self directionName:self.selectedModeDirection];
    NSString *actionDirectionName = [self directionName:self.inspectingModeDirection];
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
    
    [self.batchActions assembleBatchActions];
    [self setInspectingModeDirection:self.inspectingModeDirection];
}

#pragma mark - Mode options

- (id)modeOptionValue:(NSString *)optionName {
    return [self mode:self.selectedMode optionValue:optionName];
}

- (id)mode:(TTMode *)mode optionValue:(NSString *)optionName {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *directionName = [self directionName:mode.modeDirection];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:option:%@",
                           NSStringFromClass([mode class]),
                           directionName,
                           optionName];
    
    if (mode.action && mode.action.batchActionKey) {
        NSString *modeDirectionName = [self directionName:mode.modeDirection];
        NSString *actionDirectionName = [self directionName:mode.action.direction];
        optionKey = [NSString stringWithFormat:@"TT:mode:%@:action:%@:batchactions:%@:modeoption:%@",
                               modeDirectionName,
                               actionDirectionName,
                               mode.action.batchActionKey,
                               optionName];
    }

    id pref = [prefs objectForKey:optionKey];

    NSLog(@" -> Getting mode option %@: %@", optionKey, pref);
    if (!pref) {
        pref = [self mode:mode defaultOption:optionName];
    }
    
    return pref;
}

#pragma mark - Button action mode

- (TTButtonActionMode)buttonActionMode {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    return [prefs integerForKey:@"TT:pref:action_mode"];
}

- (BOOL)isButtonActionPerform {
    return self.buttonActionMode == TTButtonActionModePerform && !self.openedModeChangeMenu && !self.openedActionChangeMenu && !self.openedAddActionChangeMenu && self.inspectingModeDirection == NO_DIRECTION;
}

- (void)switchPerformActionMode:(TTButtonActionMode)buttonActionMode {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setInteger:buttonActionMode forKey:@"TT:pref:action_mode"];
    
    [self reset];
}

#pragma mark - Action options

- (id)actionOptionValue:(NSString *)optionName {
    return [self actionOptionValue:optionName inDirection:self.inspectingModeDirection];
}

- (id)actionOptionValue:(NSString *)optionName inDirection:(TTModeDirection)direction {
    return [self mode:self.selectedMode actionOptionValue:optionName inDirection:direction];
}

- (id)mode:(TTMode *)mode actionOptionValue:(NSString *)optionName inDirection:(TTModeDirection)direction {
    return [self mode:mode actionOptionValue:optionName actionName:[mode actionNameInDirection:direction] inDirection:direction];
}

- (id)mode:(TTMode *)mode actionOptionValue:(NSString *)optionName actionName:(NSString *)actionName inDirection:(TTModeDirection)direction {
    if (!mode) mode = self.selectedMode;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *modeDirectionName = [self directionName:mode.modeDirection];
    NSString *actionDirectionName = [self directionName:direction];

    if (direction == NO_DIRECTION) {
        // Rotate through directions looking for prefs
        for (TTModeDirection direction=1; direction <= 4; direction++) {
            actionDirectionName = [self directionName:direction];
            NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:action:%@-%@:option:%@",
                                   NSStringFromClass([mode class]),
                                   modeDirectionName,
                                   actionName,
                                   actionDirectionName,
                                   optionName];
            id pref = [prefs objectForKey:optionKey];
            NSLog(@" -> Getting action options %@: %@", optionKey, pref);
            if (!pref) continue;
            if ([pref isKindOfClass:[NSString class]] && !((NSString *)pref).length) continue;
            return pref;
        }
    }
    
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:action:%@-%@:option:%@",
                           NSStringFromClass([mode class]),
                           modeDirectionName,
                           actionName,
                           actionDirectionName,
                           optionName];
    id pref = [prefs objectForKey:optionKey];
    NSLog(@" -> Getting action options %@: %@", optionKey, pref);
    
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
    NSLog(@" -> Getting mode option default %@: %@", optionName, [modeDefaults objectForKey:optionName]);

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
    NSLog(@" -> Getting mode action option default %@: %@ (%@)", optionKey, [modeDefaults objectForKey:optionKey], modeDefaults);

    return [modeDefaults objectForKey:optionKey];
}

#pragma mark - Setting mode/action options

- (void)changeModeOption:(NSString *)optionName to:(id)optionValue {
    [self changeMode:self.selectedMode option:optionName to:optionValue];
}

- (void)changeMode:(TTMode *)mode option:(NSString *)optionName to:(id)optionValue {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *directionName = [self directionName:self.selectedModeDirection];
    NSString *optionKey = [NSString stringWithFormat:@"TT:mode:%@-%@:option:%@",
                           NSStringFromClass([self.selectedMode class]),
                           directionName,
                           optionName];
    
    if (mode.action && mode.action.batchActionKey) {
        NSString *modeDirectionName = [self directionName:mode.modeDirection];
        NSString *actionDirectionName = [self directionName:mode.action.direction];
        optionKey = [NSString stringWithFormat:@"TT:mode:%@:action:%@:batchactions:%@:modeoption:%@",
                     modeDirectionName,
                     actionDirectionName,
                     mode.action.batchActionKey,
                     optionName];
    }

    NSLog(@" -> Setting mode option %@ to: %@", optionKey, optionValue);
    [prefs setObject:optionValue forKey:optionKey];
    [prefs synchronize];
}

- (void)changeActionOption:(NSString *)optionName to:(id)optionValue {
    [self changeMode:self.selectedMode actionOption:optionName to:optionValue direction:self.inspectingModeDirection];
}

- (void)changeActionOption:(NSString *)optionName to:(id)optionValue direction:(TTModeDirection)direction {
    [self changeMode:self.selectedMode actionOption:optionName to:optionValue direction:direction];
}

- (void)changeMode:(TTMode *)mode actionOption:(NSString *)optionName to:(id)optionValue direction:(TTModeDirection)direction {
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
    
    NSLog(@" -> Setting action option %@ to: %@", optionKey, optionValue);
    [prefs setObject:optionValue forKey:optionKey];
    [prefs synchronize];
}

- (void)changeMode:(TTMode *)mode batchActionKey:(NSString *)batchActionKey
      actionOption:(NSString *)optionName to:(id)optionValue direction:(TTModeDirection)direction {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *modeDirectionName = [self directionName:mode.modeDirection];
    NSString *actionDirectionName = [self directionName:direction];
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

- (TTMode *)modeInDirection:(TTModeDirection)direction {
    switch (direction) {
        case NORTH:
            return self.northMode;
            break;
            
        case EAST:
            return self.eastMode;
            break;
            
        case WEST:
            return self.westMode;
            break;
            
        case SOUTH:
            return self.southMode;
            break;
            
        case NO_DIRECTION:
        case INFO:
            break;
    }
    
    return nil;
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
            return @"no_direction";
            break;
    }
    
    return nil;
}

- (NSString *)momentName:(TTButtonMoment)moment {
    switch (moment) {
        case BUTTON_MOMENT_PRESSUP:
            return @"single";
        case BUTTON_MOMENT_PRESSDOWN:
            return @"down";
        case BUTTON_MOMENT_DOUBLE:
            return @"double";
        case BUTTON_MOMENT_HELD:
            return @"hold";
        default:
            return @"";
    }
}

- (void)toggleInspectingModeDirection:(TTModeDirection)direction {
    if (self.inspectingModeDirection == direction) {
        [self setOpenedActionChangeMenu:NO];
        [self setOpenedAddActionChangeMenu:NO];
        [self setOpenedChangeActionMenu:NO];
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

#pragma mark - Device Info


- (void)recordButtonMoment:(TTModeDirection)direction buttonMoment:(TTButtonMoment)buttonMoment {
    NSString *buttonPress = [self momentName:buttonMoment];
    NSMutableArray *presses = [NSMutableArray array];
    
    NSString *actionName = [self.selectedMode actionNameInDirection:direction];
    [presses addObject:@{
                         @"app_name": NSStringFromClass([self.selectedMode class]),
                         @"app_direction": [self directionName:[self.selectedMode modeDirection]],
                         @"button_name": actionName ? actionName : @"none",
                         @"button_direction": [self directionName:direction],
                         @"button_moment": buttonPress,
                         @"batch_action": [NSNumber numberWithBool:NO],
                         }];
    
    NSArray *actions = [self selectedModeBatchActions:direction];
    for (TTAction *batchAction in actions) {
        [presses addObject:@{
                             @"app_name": NSStringFromClass([batchAction.mode class]),
                             @"app_direction": [self directionName:[self.selectedMode modeDirection]],
                             @"button_name": batchAction.actionName,
                             @"button_direction": [self directionName:direction],
                             @"button_moment": buttonPress,
                             @"batch_action": [NSNumber numberWithBool:YES],
                             }];
    }
    
    [self recordUsage:@{@"button_actions": presses}];
}

- (void)recordUsageMoment:(NSString *)moment {
    [self recordUsage:@{@"moment": moment}];
}

- (void)recordUsage:(NSDictionary *)additionalParams {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs boolForKey:@"TT:pref:share_usage_stats"]) {
        return;
    }
    
    NSMutableDictionary *params = [[self deviceAttrs] mutableCopy];
    for (NSString *key in additionalParams) {
        [params setObject:additionalParams[key] forKey:key];
    }
    
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
//    NSString *body = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
//    NSLog(@" ---> Recording: %@", body);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/usage/record", TURN_TOUCH_HOST];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:json];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
    }];
}

- (NSDictionary *)deviceAttrs {
    NSString *userId = [self userId];
    NSString *deviceId = [self deviceId];
    NSString *deviceName = [[NSHost currentHost] localizedName];
    NSString *deviceModel = [TTModeMap machineModel];
    NSString *devicePlatform = @"macOS";
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    NSString *deviceVersion = [NSString stringWithFormat:@"%ld.%ld.%ld", version.majorVersion,
                               version.minorVersion, version.patchVersion];
    NSString *remoteName = @"";
    NSArray *devices = [[[NSAppDelegate bluetoothMonitor] foundDevices] devices];
    if ([devices count] >= 1) {
        remoteName = [[devices objectAtIndex:0] nickname];
    }
    
    if (remoteName == nil) remoteName = @"[None]";
    
    NSDictionary *params = @{@"user_id": userId,
                             @"device_id": deviceId,
                             @"device_name": deviceName,
                             @"device_model": deviceModel,
                             @"device_platform": devicePlatform,
                             @"device_version": deviceVersion,
                             @"remote_name": remoteName,
                             };
    
    return params;
}

+ (NSString *) machineModel {
    size_t len = 0;
    sysctlbyname("hw.model", NULL, &len, NULL, 0);
    
    if (len)
    {
        char *model = malloc(len*sizeof(char));
        sysctlbyname("hw.model", model, &len, NULL, 0);
        NSString *model_ns = [NSString stringWithUTF8String:model];
        free(model);
        return model_ns;
    }
    
    return @"Mac";
}

- (NSString *)userId {
    NSUUID *uuid;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    // Check iCloud first
    NSString *uuidString = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:kIftttUserIdKey];
    if (uuidString) {
        uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        
        [prefs setObject:[uuid UUIDString] forKey:kIftttUserIdKey];
        [prefs synchronize];
        
        return [uuid UUIDString];
    }
    
    // Check local prefs second
    uuidString = [prefs stringForKey:kIftttUserIdKey];
    if (uuidString) {
        uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        
        [[NSUbiquitousKeyValueStore defaultStore] setObject:[uuid UUIDString] forKey:kIftttUserIdKey];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        
        return [uuid UUIDString];
    }
    
    // Create new user ID
    uuid = [[NSUUID alloc] init];
    [prefs setObject:[uuid UUIDString] forKey:kIftttUserIdKey];
    [prefs synchronize];
    [[NSUbiquitousKeyValueStore defaultStore] setObject:[uuid UUIDString] forKey:kIftttUserIdKey];
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    return [uuid UUIDString];
}

- (NSString *)deviceId {
    NSUUID *uuid;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *uuidString = [prefs stringForKey:kIftttDeviceIdKey];
    if (uuidString) {
        uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        
        [[NSUbiquitousKeyValueStore defaultStore] setObject:[uuid UUIDString] forKey:kIftttDeviceIdKey];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        
        return [uuid UUIDString];
    }
    
    // Create new user ID
    uuid = [[NSUUID alloc] init];
    [prefs setObject:[uuid UUIDString] forKey:kIftttDeviceIdKey];
    [prefs synchronize];
    
    return [uuid UUIDString];
}

@end
