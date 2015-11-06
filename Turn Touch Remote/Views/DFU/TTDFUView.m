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
        [self setOrientation:NSUserInterfaceLayoutOrientationVertical];
        [self setAlignment:NSLayoutAttributeCenterX];
        [self setSpacing:0];
        [self setWantsLayer:YES];
        [self setHuggingPriority:NSLayoutPriorityDefaultHigh
                  forOrientation:NSLayoutConstraintOrientationVertical];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self registerAsObserver];
    }

    return self;
}

- (void)registerAsObserver {
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"nicknamedConnectedCount"
                                      options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(nicknamedConnectedCount))]) {
        [self setNeedsDisplay:YES];
        [self drawStackView];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"nicknamedConnectedCount"];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSLog(@"frame: %@/%@", NSStringFromRect(self.frame), NSStringFromRect(self.bounds));
    [self drawBackground];
}

- (void)drawBackground {
    [NSColorFromRGB(0xEDDF31) set];
    NSRectFill(self.bounds);
}

- (void)drawStackView {
    NSMutableArray *dfuDeviceViews = [NSMutableArray array];
    NSArray *devices = appDelegate.bluetoothMonitor.foundDevices.nicknamedConnected;
    [self removeConstraints:[self constraints]];

    for (TTDevice *device in devices) {
        TTDFUDeviceView *deviceView = [[TTDFUDeviceView alloc] initWithDevice:device];
        [dfuDeviceViews addObject:deviceView];
    }
    
    NSLog(@"dfuDeviceViews: %@", dfuDeviceViews);
    [self setViews:dfuDeviceViews inGravity:NSStackViewGravityTop];
    
    for (TTDFUDeviceView *deviceView in self.views) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:deviceView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:0 multiplier:1.0 constant:40]];
    }
}

@end
