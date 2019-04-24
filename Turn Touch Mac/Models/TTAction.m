//
//  TTAction.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/22/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTAction.h"

@implementation TTAction

- (id)initWithActionName:(NSString *)_actionName direction:(TTModeDirection)_direction {
    if (self = [super init]) {
        self.mode = NSAppDelegate.modeMap.selectedMode;
        self.actionName = _actionName;
        self.direction = _direction;
    }
    
    return self;
}

- (id)initWithBatchActionKey:(NSString *)_key direction:(TTModeDirection)_direction {
    if (self = [super init]) {
        self.batchActionKey = _key;
        NSArray *chunks = [self.batchActionKey componentsSeparatedByString:@":"];
        self.mode = [[NSClassFromString([chunks objectAtIndex:0]) alloc] init];
        [self.mode setModeDirection:NSAppDelegate.modeMap.selectedModeDirection];
        [self.mode setAction:self];
        self.actionName = [chunks objectAtIndex:1];
        self.direction = _direction;
        
        if ([self.mode respondsToSelector:@selector(activate)]) {
            [self.mode activate:NSAppDelegate.modeMap.selectedModeDirection];
        }
    }
    
    return self;
}

- (void)deactivate {
    if ([self.mode respondsToSelector:@selector(deactivate)]) {
        [self.mode deactivate];
    }
}

- (id)optionValue:(NSString *)optionName {
    return [self optionValue:optionName inDirection:self.direction];
}

- (id)optionValue:(NSString *)optionName inDirection:(TTModeDirection)_direction {
    if (!self.batchActionKey) {
        return [NSAppDelegate.modeMap mode:self.mode actionOptionValue:optionName actionName:self.actionName inDirection:_direction];
    } else {
        return [NSAppDelegate.modeMap mode:self.mode
                               batchAction:self
                         actionOptionValue:optionName
                               inDirection:_direction];
    }
}

- (void)changeActionOption:(NSString *)optionName to:(id)optionValue {
    if (!self.batchActionKey) {
        [NSAppDelegate.modeMap changeActionOption:optionName to:optionValue direction:self.direction];
    } else {
        [NSAppDelegate.modeMap changeMode:self.mode
                           batchActionKey:self.batchActionKey
                             actionOption:optionName to:optionValue direction:self.direction];
    }
}

@end
