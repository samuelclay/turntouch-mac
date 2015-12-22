//
//  TTBatchActions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/21/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTBatchAction.h"

@class TTAppDelegate;

@interface TTBatchActions : NSObject {
    TTAppDelegate *appDelegate;
    
    NSArray *northActions;
    NSArray *eastActions;
    NSArray *westActions;
    NSArray *southActions;
}

- (void)assembleBatchActions;
- (NSString *)batchActionKey:(TTModeDirection)direction;
- (NSArray *)batchActionsInDirection:(TTModeDirection)direction;

@end
