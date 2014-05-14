//
//  TTModeOptionsView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 5/12/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTTabView.h"

@class TTAppDelegate;

@interface TTModeOptionsView : NSView
<NSTabViewDelegate> {
    TTAppDelegate *appDelegate;
    
    TTTabView *tabView;
}

@property (nonatomic) IBOutlet TTTabView *tabView;

- (void)animateBlock:(void (^)())block;

@end
