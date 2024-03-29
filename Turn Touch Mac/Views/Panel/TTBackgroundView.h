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
#import "TTDeviceTitlesView.h"
#import "TTAddActionButtonView.h"
#import "TTFooterView.h"
#import "TTBatchActionStackView.h"
#import "TTModalPairingScanningView.h"
#import "TTModalFTUXView.h"
#import "TTModalBarButton.h"
#import "TTModalPairingInfo.h"
#import "TTModalAbout.h"
#import "TTModalDevices.h"
#import "TTModalSettings.h"
#import "TTModalSupportView.h"
#import "TTPanelStates.h"

#define PANEL_WIDTH 380.0f
#define STROKE_OPACITY .5f
#define TITLE_BAR_HEIGHT 38.0f
#define MODE_TABS_HEIGHT 92.0f
#define MODE_TITLE_HEIGHT 64.0f
#define MODE_MENU_HEIGHT 146.0f
#define ACTION_MENU_HEIGHT 96.0f
#define MODE_OPTIONS_HEIGHT 148.0f
#define DIAMOND_LABELS_SIZE 270.0f
#define ADD_ACTION_BUTTON_HEIGHT 48.0f
#define FOOTER_HEIGHT 8.0f

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
@class TTDeviceTitlesView;
@class TTAddActionButtonView;
@class TTBatchActionStackView;
@class TTModalPairingInfo;
@class TTModalPairingScanningView;
@class TTModalBarButton;
@class TTModalFTUXView;
@class TTModalAbout;
@class TTModalDevices;
@class TTModalSettings;
@class TTModalSupportView;

@interface TTBackgroundView : NSStackView <NSStackViewDelegate>

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) IBOutlet TTPanelArrowView *arrowView;
@property (nonatomic) IBOutlet TTTitleBarView *titleBarView;
@property (nonatomic) IBOutlet TTModeTabsContainer *modeTabs;
@property (nonatomic) IBOutlet TTModeMenuContainer *modeMenu;
@property (nonatomic) IBOutlet TTModeMenuContainer *actionMenu;
@property (nonatomic) IBOutlet TTModeMenuContainer *addActionMenu;
@property (nonatomic) IBOutlet TTModeTitleView *modeTitle;
@property (nonatomic) IBOutlet TTDiamondLabels *diamondLabels;
@property (nonatomic) IBOutlet TTOptionsView *optionsView;
@property (nonatomic) IBOutlet TTDeviceTitlesView *deviceTitlesView;
@property (nonatomic) IBOutlet TTAddActionButtonView *addActionButtonView;
@property (nonatomic) IBOutlet TTFooterView *footerView;
@property (nonatomic) IBOutlet TTBatchActionStackView *batchActionStackView;
@property (nonatomic) IBOutlet TTModalPairingInfo *modalPairingInfo;
@property (nonatomic) IBOutlet TTModalPairingScanningView *modalPairingScanningView;
@property (nonatomic) IBOutlet TTModalFTUXView *modalFTUXView;
@property (nonatomic) IBOutlet TTModalBarButton *modalBarButton;
@property (nonatomic) IBOutlet TTModalAbout *modalAbout;
@property (nonatomic) IBOutlet TTModalDevices *modalDevices;
@property (nonatomic) IBOutlet TTModalSettings *modalSettings;
@property (nonatomic) IBOutlet TTModalSupportView *modalSupportView;
@property (nonatomic) TTModalFTUX modalFTUX;
@property (nonatomic) TTPanelModal panelModal;
@property (nonatomic) NSLayoutConstraint *optionsConstraint;

- (void)resetPosition;
- (void)adjustBatchActionsHeight:(BOOL)animated;
- (void)adjustOptionsHeight:(NSView *)optionsDetailView;
- (void)switchPanelModal:(TTPanelModal)_panelModal;
- (void)switchPanelModalPairing:(TTModalPairing)_modalPairing;
- (void)switchPanelModalFTUX:(TTModalFTUX)_modalFTUX;
- (void)toggleBatchActionsChangeActionMenu:(TTAction *)batchAction visible:(BOOL)visible;

@end
