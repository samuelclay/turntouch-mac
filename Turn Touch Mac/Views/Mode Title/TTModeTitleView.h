//
//  TTModeTitleView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTChangeButtonView.h"

@class TTAppDelegate;

@interface TTModeTitleView : NSView {
    TTAppDelegate *appDelegate;
    NSImage *modeImage;
    NSString *modeTitle;
    NSDictionary *modeAttributes;
    CGSize textSize;
    TTChangeButtonView *changeButton;
}

@property (nonatomic) IBOutlet TTChangeButtonView *changeButton;

@end
