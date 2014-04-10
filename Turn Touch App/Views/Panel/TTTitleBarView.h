//
//  TTTitleBarView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 4/9/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTTitleBarView : NSView {
    TTAppDelegate *appDelegate;
    NSImage *title;
}

@end
