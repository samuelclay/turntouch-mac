//
//  TTModeMenuItem.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTDiamond.h"
#import "TTDiamondView.h"

@class TTAppDelegate;
@class TTDiamondView;

@interface TTModeMenuItem : NSView {
    TTAppDelegate *appDelegate;
    TTModeDirection modeDirection;
    TTDiamondView *diamondView;
    TTMode *itemMode;
    
    NSImage *modeImage;
    NSString *modeTitle;
    NSDictionary *modeAttributes;
    CGSize textSize;
    NSButton *changeButton;
    BOOL hoverActive;
}

@property (nonatomic) IBOutlet NSButton *changeButton;

- (id)initWithFrame:(NSRect)frame direction:(TTModeDirection)direction;


@end
