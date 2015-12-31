//
//  TTModeWebMenuView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/30/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTModeWebMenuView.h"

@implementation TTModeWebMenuView

- (void)awakeFromNib {
    self.material = NSVisualEffectMaterialSidebar;
    self.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    self.state = NSVisualEffectStateActive;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
