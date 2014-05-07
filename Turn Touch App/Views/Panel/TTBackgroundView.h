//
//  TTBackgroundView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTPanelArrowView.h"
#import "TTModeTabsContainer.h"
#import "TTModeTitleView.h"
#import "TTModeMenuContainer.h"
#import "TTDiamondLabels.h"
#import "TTOptionsView.h"
#import "TTTitleBarView.h"

@class TTAppDelegate;
@class TTPanelArrowView;
@class TTDiamondView;
@class TTDiamondLabels;
@class TTModeTabsContainer;
@class TTModeMenuContainer;
@class TTModeTitleView;
@class TTOptionsView;
@class TTTitleBarView;

@interface TTBackgroundView : NSView <NSStackViewDelegate> {
    TTAppDelegate *appDelegate;
    NSLayoutConstraint *modeMenuConstraint;
}

@property (nonatomic) NSStackView *stackView;
@property (nonatomic) IBOutlet TTPanelArrowView *arrowView;
@property (nonatomic) IBOutlet TTTitleBarView *titleBarView;
@property (nonatomic) IBOutlet TTModeTabsContainer *modeTabs;
@property (nonatomic) IBOutlet TTModeMenuContainer *modeMenu;
@property (nonatomic) IBOutlet TTModeTitleView *modeTitle;
@property (nonatomic) IBOutlet TTDiamondLabels *diamondLabels;
@property (nonatomic) IBOutlet TTOptionsView *optionsView;

- (void)resetPosition;

@end
