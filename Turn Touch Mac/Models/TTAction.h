//
//  TTAction.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/22/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTMode.h"

@class TTAppDelegate;
@class TTMode;
@class TTModeMenuContainer;

@interface TTAction : NSObject

@property (nonatomic) TTMode *mode;
@property (nonatomic) TTModeDirection direction;
@property (nonatomic) NSString *actionName;
@property (nonatomic) NSString *batchActionKey;
@property (nonatomic) TTModeMenuContainer *changeActionMenu;

- (id)initWithActionName:(NSString *)_actionName direction:(TTModeDirection)_direction;
- (id)initWithBatchActionKey:(NSString *)_key direction:(TTModeDirection)_direction;
- (void)deactivate;
- (id)optionValue:(NSString *)optionName;
- (id)optionValue:(NSString *)optionName inDirection:(TTModeDirection)direction;
- (void)changeActionOption:(NSString *)optionName to:(id)optionValue;

@end
