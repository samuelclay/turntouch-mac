//
//  TTModeWebBackgroundView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/30/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTModeWebBackgroundView.h"

@implementation TTModeWebBackgroundView

- (void)awakeFromNib {
//    self.material = NSVisualEffectMaterialDark;
//    self.blendingMode = NSVisualEffectBlendingModeBehindWindow;
//    self.state = NSVisualEffectStateActive;
    [self setWantsLayer:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
