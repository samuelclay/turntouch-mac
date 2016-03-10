//
//  TTBackgroundView.h
//  Turn Touch Remote
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
#import "TTOptionsDetailViewController.h"
#import "TTDFUView.h"
#import "TTAddActionButtonView.h"
#import "TTFooterView.h"
#import "TTBatchActionStackView.h"
#import "TTModalPairingScanningView.h"

@class TTAppDelegate;
@class TTPanelArrowView;
@class TTDiamondView;
@class TTDiamondLabels;
@class TTModeTabsContainer;
@class TTModeMenuContainer;
@class TTModeTitleView;
@class TTOptionsView;
@class TTTitleBarView;
@class TTOptionsDetailViewController;
@class TTDFUView;
@class TTAddActionButtonView;
@class TTBatchActionStackView;
@class TTModalPairingScanningView;

typedef enum TTPanelModal : NSUInteger {
    PANEL_MODAL_APP,
    PANEL_MODAL_FTUX,
    PANEL_MODAL_PAIRING,
    PANEL_MODAL_DEVICES,
    PANEL_MODAL_ABOUT,
} TTPanelModal;

@interface TTBackgroundView : NSStackView <NSStackViewDelegate> {
    TTAppDelegate *appDelegate;
    NSLayoutConstraint *modeMenuConstraint;
    NSLayoutConstraint *actionMenuConstraint;
    NSLayoutConstraint *addActionMenuConstraint;
    NSLayoutConstraint *optionsConstraint;
    NSLayoutConstraint *dfuConstraint;
    NSLayoutConstraint *addActionButtonConstraint;
    NSLayoutConstraint *batchActionsConstraint;
    TTPanelModal panelModal;
//    NSArray<NSLayoutConstraint *> *constraints;
}

@property (nonatomic) IBOutlet TTPanelArrowView *arrowView;
@property (nonatomic) IBOutlet TTTitleBarView *titleBarView;
@property (nonatomic) IBOutlet TTModeTabsContainer *modeTabs;
@property (nonatomic) IBOutlet TTModeMenuContainer *modeMenu;
@property (nonatomic) IBOutlet TTModeMenuContainer *actionMenu;
@property (nonatomic) IBOutlet TTModeMenuContainer *addActionMenu;
@property (nonatomic) IBOutlet TTModeTitleView *modeTitle;
@property (nonatomic) IBOutlet TTDiamondLabels *diamondLabels;
@property (nonatomic) IBOutlet TTOptionsView *optionsView;
@property (nonatomic) IBOutlet TTDFUView *dfuView;
@property (nonatomic) IBOutlet TTAddActionButtonView *addActionButtonView;
@property (nonatomic) IBOutlet TTFooterView *footerView;
@property (nonatomic) IBOutlet TTBatchActionStackView *batchActionStackView;
@property (nonatomic) IBOutlet TTModalPairingScanningView *modalPairingScanningView;
@property (nonatomic) NSLayoutConstraint *optionsConstraint;

- (void)resetPosition;
- (void)adjustOptionsHeight:(NSView *)optionsDetailView;
- (void)switchPanelModel:(TTPanelModal)_panelModal;

@end
