//
//  TTDiamondView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeMap.h"

#define SPACING_PCT 0.015f
#define INACTIVE_OPACITY 0.7f

@class TTAppDelegate;

typedef enum TTDiamondType : NSUInteger {
    DIAMOND_TYPE_INTERACTIVE,
    DIAMOND_TYPE_MODE,
    DIAMOND_TYPE_STATUSBAR,
    DIAMOND_TYPE_HUD,
    DIAMOND_TYPE_PAIRING
} TTDiamondType;

@interface TTDiamondView : NSView {
    TTAppDelegate *appDelegate;
    CGFloat _size;
    BOOL _isHighlighted;
    
    NSBezierPath *northPathTop;
    NSBezierPath *eastPathTop;
    NSBezierPath *westPathTop;
    NSBezierPath *southPathTop;
    NSBezierPath *northPathBottom;
    NSBezierPath *eastPathBottom;
    NSBezierPath *westPathBottom;
    NSBezierPath *southPathBottom;
}

@property (nonatomic) TTDiamondType diamondType;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) TTModeDirection overrideSelectedDirection;
@property (nonatomic, assign) TTModeDirection overrideActiveDirection;
@property (nonatomic, assign) BOOL ignoreSelectedMode;
@property (nonatomic, assign) BOOL ignoreActiveMode;
@property (nonatomic, assign) BOOL showOutline;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;

- (id)initWithFrame:(NSRect)frame diamondType:(TTDiamondType)_diamondType;

@end
