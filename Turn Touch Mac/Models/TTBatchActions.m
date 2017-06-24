//
//  TTBatchActions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/21/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTBatchActions.h"

@implementation TTBatchActions

- (instancetype)init {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
    }
    return self;
}

- (void)assembleBatchActions {
    northActions = [self _assembleBatchActionsInDirection:NORTH];
    eastActions = [self _assembleBatchActionsInDirection:EAST];
    westActions = [self _assembleBatchActionsInDirection:WEST];
    southActions = [self _assembleBatchActionsInDirection:SOUTH];
}

- (NSString *)batchActionKey:(TTModeDirection)direction {
    return [self modeBatchActionKey:appDelegate.modeMap.selectedModeDirection actionDirection:direction];
}

- (NSString *)modeBatchActionKey:(TTModeDirection)modeDirection actionDirection:(TTModeDirection)actionDirection {
    NSString *modeDirectionName = [appDelegate.modeMap directionName:modeDirection];
    NSString *actionDirectionName = [appDelegate.modeMap directionName:actionDirection];
    NSString *batchKey = [NSString stringWithFormat:@"TT:mode:%@:action:%@:batchactions",
                          modeDirectionName,
                          actionDirectionName];
    return batchKey;
}

- (NSArray *)batchActionsInDirection:(TTModeDirection)direction {
    switch (direction) {
        case NORTH:
            return northActions;
        case EAST:
            return eastActions;
        case WEST:
            return westActions;
        case SOUTH:
            return southActions;
        default:
            break;
    }

    return nil;
}

- (void)deactivate {
    for (NSArray *actions in @[northActions, eastActions, westActions, southActions]) {
        for (TTAction *batchAction in actions) {
            [batchAction deactivate];
        }
    }
}

#pragma mark - Private

- (NSArray *)_assembleBatchActionsInDirection:(TTModeDirection)direction {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *batchActions = [NSMutableArray array];
    NSArray *batchActionKeys = [prefs objectForKey:[self batchActionKey:direction]];
    for (NSString *batchActionKey in batchActionKeys) {
        TTAction *batchAction = [[TTAction alloc] initWithBatchActionKey:batchActionKey direction:direction];
        [batchActions addObject:batchAction];
    }
    
    return batchActions;
}

@end
