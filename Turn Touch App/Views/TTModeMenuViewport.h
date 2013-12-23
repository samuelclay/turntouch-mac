//
//  TTModeMenuViewport.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeMenuContainer.h"

@class TTAppDelegate;
@class TTModeMenuContainer;

@interface TTModeMenuViewport : NSView {
    TTAppDelegate *appDelegate;
    TTModeMenuContainer *container;
    BOOL isExpanded;
    CGFloat originalHeight;
    CGFloat originalY;
}

- (void)resetPosition;

@end
