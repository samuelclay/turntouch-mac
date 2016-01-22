//
//  TTAction.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/22/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTAction.h"

@implementation TTAction

@synthesize mode;
@synthesize actionName;
@synthesize batchActionKey;

- (id)initWithBatchActionKey:(NSString *)_key {
    if (self = [super init]) {
        batchActionKey = _key;
        NSArray *chunks = [batchActionKey componentsSeparatedByString:@":"];
        mode = [[NSClassFromString([chunks objectAtIndex:0]) alloc] init];
        [mode setModeDirection:NSAppDelegate.modeMap.selectedModeDirection];
        [mode setAction:self];
        if ([mode respondsToSelector:@selector(activate)]) {
            [mode activate:NSAppDelegate.modeMap.selectedModeDirection];
        }
        actionName = [chunks objectAtIndex:1];
    }
    
    return self;
}

- (id)optionValue:(NSString *)optionName inDirection:(TTModeDirection)direction {
    if (!batchActionKey) {
        return [NSAppDelegate.modeMap actionOptionValue:optionName inDirection:direction];
    } else {
        return [NSAppDelegate.modeMap mode:mode
                               batchAction:self
                         actionOptionValue:optionName
                               inDirection:direction];
    }
}

- (void)changeActionOption:(NSString *)optionName to:(id)optionValue {
    if (!batchActionKey) {
        [NSAppDelegate.modeMap changeActionOption:optionName to:optionValue];
    } else {
        [NSAppDelegate.modeMap changeMode:mode
                           batchActionKey:batchActionKey
                             actionOption:optionName to:optionValue];
    }
}

@end
