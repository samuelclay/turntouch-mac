//
//  TTModeWebMenuView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/30/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTModeWebMenuView : NSVisualEffectView

@property (nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

- (void)slideIn;
- (void)slideOut;

@end
