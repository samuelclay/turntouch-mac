//
//  TTModeNewsBackgroundView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNewsBackgroundView.h"
#import "TTAppDelegate.h"
#import "TTModeNews.h"

@implementation TTModeNewsBackgroundView

- (void)awakeFromNib {
    self.material = NSVisualEffectMaterialDark;
    self.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    self.state = NSVisualEffectStateActive;
    [self setWantsLayer:YES];
    
    NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                     NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options:options
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseMoved:(NSEvent *)theEvent {
    if (![NSAppDelegate.modeMap.selectedMode isKindOfClass:[TTModeNews class]]) {
        [self removeTrackingArea:trackingArea];
        return;
    }
    [(TTModeNews *)NSAppDelegate.modeMap.selectedMode startHideMouseTimer];
}

@end
