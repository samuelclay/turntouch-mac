//
//  TTBatchActionHeaderView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/20/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTBatchActionHeaderView.h"

@implementation TTBatchActionHeaderView

@synthesize modeName;

- (instancetype)initWithMode:(NSString *)_modeName {
    if (self = [super init]) {
        modeName = _modeName;
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xFFFFFF) set];
    NSRectFill(self.bounds);
}

@end
