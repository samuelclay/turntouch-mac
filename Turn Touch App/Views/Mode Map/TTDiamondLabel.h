//
//  TTDiamondLabel.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTDiamondLabel : NSView {
    TTAppDelegate *appDelegate;
    TTModeDirection labelDirection;
    NSDictionary *labelAttributes;
    TTMode *diamondMode;
    
    BOOL isHover;
    BOOL interactive;
}

@property (nonatomic, readwrite) BOOL interactive;

- (id)initWithFrame:(NSRect)frame inDirection:(TTModeDirection)direction;
- (void)setMode:(TTMode *)mode;

@end
