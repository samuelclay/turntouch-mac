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

@interface TTAction : NSObject {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) TTMode *mode;
@property (nonatomic) NSString *actionName;
@property (nonatomic) NSString *batchActionKey;

- (id)initWithBatchActionKey:(NSString *)_key;
- (void)deactivate;
- (id)optionValue:(NSString *)optionName inDirection:(TTModeDirection)direction;
- (void)changeActionOption:(NSString *)optionName to:(id)optionValue;

@end
