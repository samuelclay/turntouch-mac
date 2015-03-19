//
//  TTModeOptionsTitle.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTOptionsModeTitle : NSView {
    TTAppDelegate *appDelegate;
    NSDictionary *titleAttributes;
    NSDictionary *descriptionAttributes;
}

@end
