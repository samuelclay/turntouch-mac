//
//  TTHUDWindow.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/5/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTActionHUDWindow.h"

@implementation TTActionHUDWindow

- (instancetype)initWithContentRect:(NSRect)contentRect
                          styleMask:(NSUInteger)aStyle
                            backing:(NSBackingStoreType)bufferingType
                              defer:(BOOL)flag {
    if (self = [super initWithContentRect:NSZeroRect styleMask:aStyle backing:bufferingType defer:flag]) {
        [self makeKeyAndOrderFront:NSApp];
        [self setLevel:CGShieldingWindowLevel()];
        [self setCollectionBehavior:(NSWindowCollectionBehaviorIgnoresCycle |
                                     NSWindowCollectionBehaviorCanJoinAllSpaces)];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:NO];
        [self setAlphaValue:0.0];
    }
    
    return self;
}

@end
