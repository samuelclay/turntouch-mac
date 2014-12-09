//
//  NSObject+CancelableBlocks.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/8/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

/*
 * This file is part of the http://ioscodesnippet.com
 * (c) Jamz Tang <jamz@jamztang.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSObject+CancelableBlocks.h"

@implementation NSObject (CancelableBlocks)

- (void)delayedAddOperation:(NSOperation *)operation {
    [[NSOperationQueue currentQueue] addOperation:operation];
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(delayedAddOperation:)
               withObject:[NSBlockOperation blockOperationWithBlock:block]
               afterDelay:delay];
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay cancelPreviousRequest:(BOOL)cancel {
    if (cancel) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    [self performBlock:block afterDelay:delay];
}

@end
