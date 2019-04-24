//
//  TTHUDView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTProgressBar.h"

@class TTAppDelegate;

extern const CGFloat kActionHUDMarginPct;

@interface TTActionHUDView : NSView

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) TTModeDirection direction;
@property (nonatomic) NSString *actionName;
@property (nonatomic) TTMode *mode;
@property (nonatomic) TTButtonMoment buttonMoment;

- (void)drawProgressBar:(TTProgressBar *)progressBar;
- (void)drawImageLayoutView;
+ (NSRect)actionFrame;


@end
