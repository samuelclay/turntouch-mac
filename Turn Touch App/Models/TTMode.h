//
//  TTMode.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTModeProtocol.h"

@class TTAppDelegate;

@interface TTMode : NSObject <TTModeProtocol> {
    TTAppDelegate *appDelegate;
}

- (void)runDirection:(TTModeDirection)direction;
- (NSString *)titleInDirection:(TTModeDirection)direction;
- (NSString *)titleForAction:(NSString *)actionName;
- (NSString *)imageNameInDirection:(TTModeDirection)direction;
- (NSString *)imageNameForAction:(NSString *)actionName;
- (NSString *)actionNameInDirection:(TTModeDirection)direction;

@end
