//
//  TTDiamondView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTDiamondView : NSView {
    TTAppDelegate *appDelegate;
    CGFloat _size;
    BOOL _isHighlighted;
}

@property (nonatomic, assign) CGFloat size;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;

@end
