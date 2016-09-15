//
//  TTHUDWindow.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/5/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTActionHUDWindow.h"

@implementation TTActionHUDWindow

- (instancetype)initWithContentRect:(NSRect)contentRect
                          styleMask:(NSWindowStyleMask)aStyle
                            backing:(NSBackingStoreType)bufferingType
                              defer:(BOOL)flag {
    if (self = [super initWithContentRect:NSZeroRect styleMask:aStyle backing:bufferingType defer:flag]) {
        [self makeKeyAndOrderFront:NSApp];
        [self setLevel:CGShieldingWindowLevel()];
        [self setCollectionBehavior:(NSWindowCollectionBehaviorMoveToActiveSpace)];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:NO];
        [self setAlphaValue:0.0];
        [self setIgnoresMouseEvents:YES];
        [self.contentView setWantsLayer:YES];
    }
    
    return self;
}

- (BOOL)isMovable {
    return NO;
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)flag {
    if (frameRect.origin.y > 0) {
        // NSLog(@"HUD Window: %@/%d", NSStringFromRect(frameRect), flag);
    } else {
        [super setFrame:frameRect display:flag];
    }
}

@end
