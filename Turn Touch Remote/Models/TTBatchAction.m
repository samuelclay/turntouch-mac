//
//  TTBatchAction.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/21/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTBatchAction.h"

@implementation TTBatchAction

@synthesize mode;
@synthesize action;
@synthesize key;

- (id)initWithKey:(NSString *)_key {
    if (self = [super init]) {
        key = _key;
        NSArray *chunks = [key componentsSeparatedByString:@":"];
        mode = [[NSClassFromString([chunks objectAtIndex:0]) alloc] init];
        action = [chunks objectAtIndex:1];
    }
    
    return self;
}

@end
