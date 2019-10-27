//
//  TTModeHUDLabelsView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/27/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeHUDView.h"

@class TTModeHUDView;

@interface TTModeHUDLabelsView : NSView

@property (nonatomic, strong) TTAppDelegate *appDelegate;

- (id)initWithHUDView:(TTModeHUDView *)HUDView;

@end
