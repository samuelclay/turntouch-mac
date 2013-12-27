//
//  TTDiamondView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeMap.h"

#define SPACING_PCT 0.01f
#define INACTIVE_OPACITY 0.2f

@class TTAppDelegate;

@interface TTDiamondView : NSView {
    TTAppDelegate *appDelegate;
    CGFloat _size;
    BOOL _isHighlighted;
    TTModeDirection overrideDirection;
    TTModeDirection activeModeDirection;
    TTModeDirection selectedModeDirection;
    
    NSBezierPath *northPath;
    NSBezierPath *eastPath;
    NSBezierPath *westPath;
    NSBezierPath *southPath;
    
    BOOL ignoreSelectedMode;
}

@property (nonatomic, assign) CGFloat size;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;

- (id)initWithFrame:(NSRect)frame direction:(TTModeDirection)direction;
- (id)initWithFrame:(NSRect)frame direction:(TTModeDirection)direction
ignoreSelectedDirection:(BOOL)ignoreSelectedDirection;

@end
