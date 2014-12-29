//
//  NSObject+CancelableBlocks.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/8/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CancelableBlocks)

- (NSBlockOperation *)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (NSBlockOperation *)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay cancelPreviousRequest:(BOOL)cancel;

@end
