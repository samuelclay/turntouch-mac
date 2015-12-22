//
//  TTBatchAction.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/21/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTMode.h"

@class TTAppDelegate;
@class TTMode;

@interface TTBatchAction : NSObject {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) TTMode *mode;
@property (nonatomic) NSString *action;
@property (nonatomic) NSString *key;

- (id)initWithKey:(NSString *)_key;

@end
