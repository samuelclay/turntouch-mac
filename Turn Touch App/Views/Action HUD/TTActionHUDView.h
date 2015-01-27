//
//  TTHUDView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTActionHUDView : NSView {
    TTAppDelegate *appDelegate;
    TTModeDirection direction;
    NSProgressIndicator *progressBar;
}

@property (nonatomic) TTModeDirection direction;

- (void)drawProgressBar:(NSProgressIndicator *)progressBar;

@end
