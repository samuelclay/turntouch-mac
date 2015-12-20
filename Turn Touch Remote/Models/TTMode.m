//
//  TTMode.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import <ScriptingBridge/ScriptingBridge.h>

@implementation TTMode

@synthesize modeDirection;

- (id)init {
    self = [super init];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
    }
    return self;
}

- (void)activate:(TTModeDirection)_modeDirection {
    modeDirection = _modeDirection;

    [self activate];
}

#pragma mark - Mode

+ (NSString *)title {
    return @"TT Mode";
}

+ (NSString *)description {
    return @"Stub mode to be filled in";
}

+ (NSString *)imageName {
    return @"equalizer-1";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTAction1",
             @"TTAction2",
             @"TTAction3",
             @"TTAction4"
             ];
}

- (NSArray *)optionlessActions {
    return @[];
}

#pragma mark - Action Titles

- (NSString *)titleTTAction1 {
    return @"Action 1st";
}
- (NSString *)titleTTAction2 {
    return @"Action 2nd";
}
- (NSString *)titleTTAction3 {
    return @"Action 3rd";
}
- (NSString *)titleTTAction4 {
    return @"Action 4th";
}

#pragma mark - Action methods

- (void)runTTAction1 {
    NSLog(@"Running TTAction1");
}
- (void)runTTAction2 {
    NSLog(@"Running TTAction2");
}
- (void)runTTAction3 {
    NSLog(@"Running TTAction3");
}
- (void)runTTAction4 {
    NSLog(@"Running TTAction4");
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTAction1";
}
- (NSString *)defaultEast {
    return @"TTAction2";
}
- (NSString *)defaultWest {
    return @"TTAction3";
}
- (NSString *)defaultSouth {
    return @"TTAction4";
}

- (NSString *)defaultInfo {
    return nil;
}

#pragma mark - Map directions to actions

- (void)runDirection:(TTModeDirection)direction {
    [self runDirection:direction action:@"run"];
}

- (void)runDoubleDirection:(TTModeDirection)direction {
    NSLog(@"Double click: %u", direction);
    BOOL doubleRan = [self runDirection:direction action:@"doubleRun"];
    if (!doubleRan) {
        [self runDirection:direction];
    }
}

- (BOOL)runDirection:(TTModeDirection)direction action:(NSString *)funcAction {
    BOOL success = NO;
    NSString *actionName = [self actionNameInDirection:direction];
    NSLog(@"Running: %d - %@%@", direction, funcAction, actionName);

    // First check for runAction:direction...
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@:",
                                         funcAction, actionName]);
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL, TTModeDirection) = (void *)imp;
    if ([self respondsToSelector:selector]) {
        func(self, selector, direction);
        success = YES;
    } else {
        // Then check for runAction... without direction
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@",
                                             funcAction, actionName]);
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        if ([self respondsToSelector:selector]) {
            func(self, selector);
            success = YES;
        }
    }
    
    return success;
}

- (NSString *)titleInDirection:(TTModeDirection)direction buttonAction:(TTButtonAction)buttonAction {
    NSString *actionName = [self actionNameInDirection:direction];
    
    return [self titleForAction:actionName buttonAction:buttonAction];
}

- (NSString *)titleForAction:(NSString *)actionName buttonAction:(TTButtonAction)buttonAction {
    NSString *runAction = @"title";
    if (buttonAction == BUTTON_ACTION_DOUBLE) runAction = @"doubleTitle";
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@",
                                         runAction, actionName]);
    if (![self respondsToSelector:selector] && buttonAction != BUTTON_ACTION_PRESSUP) {
        NSLog(@" ---> No double click title: %@", actionName);
        return [self titleForAction:actionName buttonAction:BUTTON_ACTION_PRESSUP];
    }
    
    IMP imp = [self methodForSelector:selector];
    NSString *(*func)(id, SEL) = (void *)imp;
    NSString *actionTitle = func(self, selector);
    
    return actionTitle;
}

- (NSString *)actionTitleInDirection:(TTModeDirection)direction buttonAction:(TTButtonAction)buttonAction {
    NSString *actionName = [self actionNameInDirection:direction];
    
    return [self actionTitleForAction:actionName buttonAction:buttonAction];
}

- (NSString *)actionTitleForAction:(NSString *)actionName buttonAction:(TTButtonAction)buttonAction {
    NSString *runAction = @"actionTitle";
    if (buttonAction == BUTTON_ACTION_DOUBLE) runAction = @"doubleActionTitle";
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@",
                                         runAction, actionName]);
    if (![self respondsToSelector:selector]) {
        return [self titleForAction:actionName buttonAction:buttonAction];
    }
    
    IMP imp = [self methodForSelector:selector];
    NSString *(*func)(id, SEL) = (void *)imp;
    NSString *actionTitle = func(self, selector);
    
    return actionTitle;
}

- (NSString *)imageNameInDirection:(TTModeDirection)direction {
    NSString *actionName = [self actionNameInDirection:direction];
    
    return [self imageNameForAction:actionName];
}

- (NSString *)imageNameForAction:(NSString *)actionName {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"image%@",
                                         actionName]);
    IMP imp = [self methodForSelector:selector];
    NSString *(*func)(id, SEL) = (void *)imp;
    NSString *actionImageName = func(self, selector);
    
    return actionImageName;
}


- (NSString *)imageNameForActionHudInDirection:(TTModeDirection)direction {
    NSString *actionName = [self actionNameInDirection:direction];
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"imageActionHud%@",
                                         actionName]);
    IMP imp = [self methodForSelector:selector];
    NSString *(*func)(id, SEL) = (void *)imp;
    if ([self respondsToSelector:selector]) {
        return func(self, selector);
    }
    
    return [self imageNameForAction:actionName];
}

- (ActionLayout)layoutInDirection:(TTModeDirection)direction {
    NSString *actionName = [self actionNameInDirection:direction];
    
    return [self layoutForAction:actionName];
}

- (ActionLayout)layoutForAction:(NSString *)actionName {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"layout%@",
                                         actionName]);
    IMP imp = [self methodForSelector:selector];
    ActionLayout (*func)(id, SEL) = (void *)imp;
    if ([self respondsToSelector:selector]) {
        return func(self, selector);
    }
    
    return ACTION_LAYOUT_TITLE;
}

- (BOOL)hideActionMenu {
    return NO;
}

- (NSView *)viewForLayout:(TTModeDirection)direction withRect:(NSRect)rect {
    NSString *actionName = [self actionNameInDirection:direction];
    
    return [self viewForLayoutOfAction:actionName withRect:rect];
}

- (NSView *)viewForLayoutOfAction:(NSString *)actionName withRect:(NSRect)rect {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"viewForLayout%@:",
                                         actionName]);
    IMP imp = [self methodForSelector:selector];
    NSView *(*func)(id, SEL, NSRect) = (void *)imp;
    return func(self, selector, rect);
}

- (NSString *)actionNameInDirection:(TTModeDirection)direction {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *modeDirectionName = [appDelegate.modeMap directionName:modeDirection];
    NSString *actionDirectionName = [appDelegate.modeMap directionName:direction];
    NSString *directionAction;
    if (direction != NO_DIRECTION) {
        // Use default action in direction
        directionAction = [defaults stringForKey:[NSString stringWithFormat:@"TT:%@-%@:action:%@",
                                                        NSStringFromClass([self class]), modeDirectionName, actionDirectionName]];
    }
    if (directionAction && ![self.actions containsObject:directionAction]) {
        directionAction = nil;
    }
    if (!directionAction) {
        if (direction == NORTH) {
            directionAction = [self defaultNorth];
        } else if (direction == EAST) {
            directionAction = [self defaultEast];
        } else if (direction == WEST) {
            directionAction = [self defaultWest];
        } else if (direction == SOUTH) {
            directionAction = [self defaultSouth];
        } else if (direction == INFO) {
            directionAction = [self defaultInfo];
        }
    }
    
    return directionAction;
}

- (NSInteger)progressInDirection:(TTModeDirection)direction {
    NSString *actionName = [self actionNameInDirection:direction];
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"progress%@",
                                         actionName]);
    IMP imp = [self methodForSelector:selector];
    NSInteger (*func)(id, SEL) = (void *)imp;
    if ([self respondsToSelector:selector]) {
        return func(self, selector);
    }
    
    return -1;
}

- (void)changeDirection:(TTModeDirection)direction toAction:(NSString *)actionClassName {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *modeDirectionName = [appDelegate.modeMap directionName:appDelegate.modeMap.selectedModeDirection];
    NSString *actionDirectionName = [appDelegate.modeMap directionName:direction];
    NSString *prefKey = [NSString stringWithFormat:@"TT:%@-%@:action:%@",
                         NSStringFromClass([self class]), modeDirectionName, actionDirectionName];
    
    [prefs setObject:actionClassName forKey:prefKey];
    [prefs synchronize];
}

#pragma mark - Timers

- (void)switchSelectedModeTo:(TTMode *)mode {
    [appDelegate.modeMap setSelectedModeDirection:mode.modeDirection];
}
                                 
@end
