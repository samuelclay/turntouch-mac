//
//  TTTitleBarView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/9/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTTitleBarView : NSView <NSStackViewDelegate> {
    TTAppDelegate *appDelegate;
    NSImage *title;
    NSImage *settings;
    NSDictionary *batteryAttributes;
}

@end
