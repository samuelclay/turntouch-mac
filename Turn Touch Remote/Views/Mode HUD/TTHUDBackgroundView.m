//
//  TTHUDMenuBackgroundView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/2/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTHUDBackgroundView.h"

@implementation TTHUDBackgroundView

- (void)awakeFromNib {
    [self setWantsLayer:YES];
    self.material = NSVisualEffectMaterialDark;
    self.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    self.state = NSVisualEffectStateActive;
    
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
//    if (![NSAppDelegate.modeMap.selectedMode isKindOfClass:[TTModeWeb class]]) {
//        [self removeTrackingArea:trackingArea];
//        return;
//    }
//    [(TTModeWeb *)NSAppDelegate.modeMap.selectedMode startHideMouseTimer];
}


@end
