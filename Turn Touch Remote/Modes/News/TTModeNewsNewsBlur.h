//
//  TTModeNewsNewsBlur.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NEWSBLUR_HOST [NSString stringWithFormat:@"http://nb.local.com"]

@interface TTModeNewsNewsBlur : NSObject

- (void)fetchRiverStories:(void (^)(NSArray *stories, NSArray *feeds))callback;

@end
