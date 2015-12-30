//
//  TTModeWebWindow.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTModeWebWindow.h"

@implementation TTModeWebWindow

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
        [self setIgnoresMouseEvents:YES];
        [self.contentView setWantsLayer:YES];
        
        self.styleMask = self.styleMask | NSFullSizeContentViewWindowMask;
    }
    
    return self;
}

@end
