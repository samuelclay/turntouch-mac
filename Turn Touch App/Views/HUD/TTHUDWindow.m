//
//  TTHUDWindow.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/5/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTHUDWindow.h"

@implementation TTHUDWindow

- (instancetype)initWithContentRect:(NSRect)contentRect
                          styleMask:(NSUInteger)aStyle
                            backing:(NSBackingStoreType)bufferingType
                              defer:(BOOL)flag {
    if (self = [super initWithContentRect:NSZeroRect styleMask:aStyle backing:bufferingType defer:flag]) {
        NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
        [self makeKeyAndOrderFront:NSApp];
        [self setLevel:CGShieldingWindowLevel()];
        [self setCollectionBehavior:(NSWindowCollectionBehaviorIgnoresCycle |
                                     NSWindowCollectionBehaviorCanJoinAllSpaces)];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:NO];
        [self setFrame:NSMakeRect(0, 0, CGRectGetWidth(mainScreen.frame), 200)
                    display:YES];
        [self setAlphaValue:0.0];
    }
    
    return self;
}

@end
