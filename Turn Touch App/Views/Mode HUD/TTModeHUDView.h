//
//  TTHUDView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTModeHUDView : NSView {
    TTAppDelegate *appDelegate;
    NSImage *modeImage;
    NSString *modeTitle;
    NSDictionary *modeAttributes;
    CGSize textSize;
}

- (void)setupTitleAttributes;

@end
