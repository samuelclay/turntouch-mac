//
//  TTSettingsButton.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTSettingsButton.h"

@implementation TTSettingsButton

- (id)initWithFrame:(NSRect)buttonFrame pullsDown:(BOOL)flag {
    if (self = [super initWithFrame:buttonFrame pullsDown:flag]) {
        NSImage *image = [NSImage imageNamed:@"settings"];
        [self setImage:image];
        [self.image setSize:NSMakeSize(16, 16)];
        [self setImagePosition:NSImageOnly];
        [self setButtonType:NSMomentaryChangeButton];
        [self setImageScaling:NSImageScaleProportionallyDown];
        [self.cell setArrowPosition:NSPopUpNoArrow];
        [self.cell setBordered:NO];
    }

    return self;
}

- (BOOL)pullsDown {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end
