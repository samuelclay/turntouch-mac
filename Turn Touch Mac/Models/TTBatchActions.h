//
//  TTBatchActions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/21/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTAction.h"

@class TTAppDelegate;

@interface TTBatchActions : NSObject {
    TTAppDelegate *appDelegate;
    
    NSArray *northActions;
    NSArray *eastActions;
    NSArray *westActions;
    NSArray *southActions;
}

- (void)assembleBatchActions;
- (void)deactivate;
- (NSString *)batchActionKey:(TTModeDirection)direction;
- (NSString *)modeBatchActionKey:(TTModeDirection)modeDirection actionDirection:(TTModeDirection)actionDirection;
- (NSArray *)batchActionsInDirection:(TTModeDirection)direction;

@end
