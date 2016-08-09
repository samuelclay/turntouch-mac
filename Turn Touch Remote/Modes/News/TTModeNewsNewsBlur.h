//
//  TTModeNewsNewsBlur.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTModeNewsNewsBlur : NSObject

- (void)fetchRiverStories:(void (^)(NSArray *stories))callback;

@end
