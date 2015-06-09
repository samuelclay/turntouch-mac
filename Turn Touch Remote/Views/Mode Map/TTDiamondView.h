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

@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) TTModeDirection overrideSelectedDirection;
@property (nonatomic, assign) TTModeDirection overrideActiveDirection;
@property (nonatomic, assign) BOOL ignoreSelectedMode;
@property (nonatomic, assign) BOOL ignoreActiveMode;
@property (nonatomic, assign) BOOL showOutline;
@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, assign) BOOL statusBar;
@property (nonatomic, assign) BOOL isHud;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) BOOL pairing;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;

- (id)initWithFrame:(NSRect)frame pairing:(BOOL)_pairing;
- (id)initWithFrame:(NSRect)frame interactive:(BOOL)interactive;
- (id)initWithFrame:(NSRect)frame statusBar:(BOOL)_statusBar;
- (id)initWithFrame:(NSRect)frame interactive:(BOOL)_interactive statusBar:(BOOL)_statusBar isHud:(BOOL)_isHud;

@end
