//
//  TTModeMenuItemView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTModeMenuItemView : NSView {
    TTAppDelegate *appDelegate;
    Class modeClass;
    NSString *modeTitle;
    NSImage *modeImage;
    NSDictionary *modeAttributes;
    CGSize textSize;
    BOOL hoverActive;
    BOOL mouseDownActive;
}

@property (nonatomic) NSString *modeName;

@end
