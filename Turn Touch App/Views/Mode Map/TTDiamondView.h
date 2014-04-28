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

#define SPACING_PCT 0.02f
#define INACTIVE_OPACITY 0.2f

@class TTAppDelegate;

@interface TTDiamondView : NSView {
    TTAppDelegate *appDelegate;
    CGFloat _size;
    BOOL _isHighlighted;
    
    NSBezierPath *northPath;
    NSBezierPath *eastPath;
    NSBezierPath *westPath;
    NSBezierPath *southPath;
}

@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) TTModeDirection overrideSelectedDirection;
@property (nonatomic, assign) TTModeDirection overrideActiveDirection;
@property (nonatomic, assign) BOOL ignoreSelectedMode;
@property (nonatomic, assign) BOOL ignoreActiveMode;
@property (nonatomic, assign) BOOL showOutline;
@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;

- (id)initWithFrame:(NSRect)frame interactive:(BOOL)interactive;

@end
