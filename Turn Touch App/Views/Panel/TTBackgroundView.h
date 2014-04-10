//
//  TTBackgroundView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeMenuViewport.h"
#import "TTDiamondView.h"
#import "TTDiamondLabels.h"
#import "TTOptionsView.h"
#import "TTTitleBarView.h"

#define ARROW_WIDTH 18
#define ARROW_HEIGHT 8

@class TTAppDelegate;
@class TTDiamondView;
@class TTDiamondLabels;
@class TTModeMenuViewport;
@class TTOptionsView;
@class TTTitleBarView;

@interface TTBackgroundView : NSView {
    TTAppDelegate *appDelegate;
    NSInteger _arrowX;
}

@property (nonatomic, assign) NSInteger arrowX;
@property (nonatomic) IBOutlet TTTitleBarView *titleBarView;
@property (nonatomic) IBOutlet TTModeMenuViewport *modeMenu;
@property (nonatomic) IBOutlet TTDiamondView *diamondView;
@property (nonatomic) IBOutlet TTDiamondLabels *diamondLabels;
@property (nonatomic) IBOutlet TTOptionsView *optionsView;

- (void)resetPosition;

@end
