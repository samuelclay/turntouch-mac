//
//  TTDFUView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/4/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTDFUView.h"
#import "TTDFUDeviceView.h"

@implementation TTDFUView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        stackView = [[NSStackView alloc] init];
        [stackView setOrientation:NSUserInterfaceLayoutOrientationVertical];
        [stackView setAlignment:NSLayoutAttributeCenterX];
        [stackView setSpacing:0];
//        [stackView setFrame:self.frame];
        [self addSubview:stackView];
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [stackView setFrame:self.bounds];

    [self drawBackground];
    [self drawStackView];
}

- (void)drawBackground {
    [NSColorFromRGB(0xF5F6E8) set];
    NSRectFill(self.bounds);
}

- (void)drawStackView {
    NSMutableArray *dfuDeviceViews = [NSMutableArray array];
    
    for (TTDevice *device in appDelegate.bluetoothMonitor.foundDevices) {
        TTDFUDeviceView *deviceView = [[TTDFUDeviceView alloc] initWithDevice:device];
        [deviceView setFrame:NSMakeRect(0, 0, NSWidth(self.frame), 36)];
        [dfuDeviceViews addObject:deviceView];
    }
    
    [stackView setViews:dfuDeviceViews inGravity:NSStackViewGravityTop];
}

@end
