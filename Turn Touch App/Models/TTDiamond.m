//
//  TTDiamond.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamond.h"

@implementation TTDiamond

@synthesize selectedMode;
@synthesize activeMode;

- (id)init {
    if (self = [super init]) {
        [self addObserver:self
               forKeyPath:@"selectedMode"
                  options:0 context:nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[defaults objectForKey:@"TT:selectedMode"] integerValue]) {
            selectedMode = (TTMode)[[defaults objectForKey:@"TT:selectedMode"] integerValue];
        }
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:selectedMode]
                 forKey:@"TT:selectedMode"];
    [defaults synchronize];
}

@end
