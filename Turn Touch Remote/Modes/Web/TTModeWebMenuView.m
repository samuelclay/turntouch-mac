//
//  TTModeWebMenuView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/30/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTModeWebMenuView.h"

@implementation TTModeWebMenuView

@synthesize widthConstraint;

- (void)awakeFromNib {
    self.material = NSVisualEffectMaterialSidebar;
    self.blendingMode = NSVisualEffectBlendingModeWithinWindow;
    self.state = NSVisualEffectStateActive;
    [self setWantsLayer:YES];
    [widthConstraint setConstant:0];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}



#pragma mark - Interaction

- (void)slideIn {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.24f];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[widthConstraint animator] setConstant:400];
    [NSAnimationContext endGrouping];
}

- (void)slideOut {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.3f];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[widthConstraint animator] setConstant:0];
    [NSAnimationContext endGrouping];
}

@end
