//
//  TTBackgroundView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTPanelController.h"
#import "TTBackgroundView.h"

#pragma mark -

@implementation TTBackgroundView

@synthesize arrowView;
@synthesize titleBarView;
@synthesize modeTabs;
@synthesize modeTitle;
@synthesize modeMenu;
@synthesize actionMenu;
@synthesize addActionMenu;
@synthesize diamondLabels;
@synthesize optionsView;
@synthesize optionsConstraint;
@synthesize deviceTitlesView;
@synthesize batchActionStackView;
@synthesize addActionButtonView;
@synthesize footerView;
@synthesize modalPairingScanningView;
@synthesize modalBarButton;
@synthesize modalPairingInfo;
@synthesize modalFTUXView;
@synthesize modalFTUX;
@synthesize modalAbout;
@synthesize modalDevices;
@synthesize modalSettings;
@synthesize modalSupportView;
@synthesize panelModal;

#pragma mark -

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        
        [self setWantsLayer:YES];
        [self setHuggingPriority:NSLayoutPriorityDefaultHigh
                  forOrientation:NSLayoutConstraintOrientationVertical];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setOrientation:NSUserInterfaceLayoutOrientationVertical];
        [self setAlignment:NSLayoutAttributeCenterX];
        [self setSpacing:0];

        arrowView = [[TTPanelArrowView alloc] init];
        titleBarView = [[TTTitleBarView alloc] init];
        deviceTitlesView = [[TTDeviceTitlesView alloc] init];
        modeTabs = [[TTModeTabsContainer alloc] init];
        modeTitle = [[TTModeTitleView alloc] init];
        modeMenu = [[TTModeMenuContainer alloc] initWithType:MODE_MENU_TYPE];
        diamondLabels = [[TTDiamondLabels alloc] initWithInteractive:YES];
        optionsView = [[TTOptionsView alloc] init];
        actionMenu = [[TTModeMenuContainer alloc] initWithType:ACTION_MENU_TYPE];
        batchActionStackView = [[TTBatchActionStackView alloc] init];
        addActionMenu = [[TTModeMenuContainer alloc] initWithType:ADD_MODE_MENU_TYPE];
        addActionButtonView = [[TTAddActionButtonView alloc] init];
        footerView = [[TTFooterView alloc] init];
        
        [self registerAsObserver];
    }
    
    return self;
}

- (void)switchPanelModal:(TTPanelModal)_panelModal {
    panelModal = _panelModal;
    
    if (panelModal == PANEL_MODAL_APP) {
        [self switchPanelModalApp];
    } else if (panelModal == PANEL_MODAL_PAIRING) {
        [self switchPanelModalPairing:MODAL_PAIRING_SEARCH];
    } else if (panelModal == PANEL_MODAL_FTUX) {
        [self switchPanelModalFTUX:MODAL_FTUX_INTRO];
    } else if (panelModal == PANEL_MODAL_ABOUT) {
        [self switchPanelModalAbout];
    } else if (panelModal == PANEL_MODAL_DEVICES) {
        [self switchPanelModalDevices];
    } else if (panelModal == PANEL_MODAL_SETTINGS) {
        [self switchPanelModalSettings];
    } else if (panelModal == PANEL_MODAL_SUPPORT) {
        [self switchPanelModalSupport];
    }
}

- (void)cleanup {
    [self cleanupPanelModalPairing];
    [self cleanupPanelModalFTUX];

    for (NSLayoutConstraint *constraint in [self constraints]) {
        [self removeConstraint:constraint];
    }
}

- (void)addArrowAndTitleConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:arrowView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:arrowView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:ARROW_HEIGHT]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:arrowView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleBarView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:TITLE_BAR_HEIGHT]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:0
                                                      constant:PANEL_WIDTH]];
    
//    [appDelegate.panelController.window setContentSize:NSMakeSize(PANEL_WIDTH,
//                                                                  NSHeight(appDelegate.panelController.window.frame))];
}

- (void)switchPanelModalApp {
    panelModal = PANEL_MODAL_APP;
    [self cleanup];
    
    [self setViews:@[arrowView,
                     titleBarView,
                     deviceTitlesView,
                     modeTabs,
                     modeTitle,
                     modeMenu,
                     diamondLabels,
                     actionMenu,
                     optionsView,
                     batchActionStackView,
                     addActionMenu,
                     addActionButtonView,
                     footerView] inGravity:NSStackViewGravityTop];
    
    [self addArrowAndTitleConstraints];
    
    deviceTitlesConstraint = [NSLayoutConstraint constraintWithItem:deviceTitlesView
                                                 attribute:NSLayoutAttributeHeight
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:nil
                                                 attribute:0 multiplier:1.0 constant:appDelegate.bluetoothMonitor.foundDevices.devices.count*40];
    [self addConstraint:deviceTitlesConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:deviceTitlesView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeTabs
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:MODE_TABS_HEIGHT]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeTitle
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:MODE_TITLE_HEIGHT]];
    modeMenuConstraint = [NSLayoutConstraint constraintWithItem:modeMenu
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:0
                                                     multiplier:1.0 constant:1];
    [modeMenuConstraint setPriority:NSLayoutPriorityDefaultHigh];
    [self addConstraint:modeMenuConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:diamondLabels
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:0 constant:DIAMOND_LABELS_SIZE]];
    actionMenuConstraint = [NSLayoutConstraint constraintWithItem:actionMenu
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:0
                                                       multiplier:1.0 constant:1];
    [self addConstraint:actionMenuConstraint];
    optionsConstraint = [NSLayoutConstraint constraintWithItem:optionsView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:optionsView.modeOptionsViewController.view
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0 constant:0];
    [self addConstraint:optionsConstraint];
    addActionMenuConstraint = [NSLayoutConstraint constraintWithItem:addActionMenu
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:0
                                                          multiplier:1.0 constant:1.f];
    [self addConstraint:addActionMenuConstraint];
    addActionButtonConstraint = [NSLayoutConstraint constraintWithItem:addActionButtonView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:0 multiplier:1.0
                                                              constant:0];
    [self addConstraint:addActionButtonConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:footerView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:0 constant:FOOTER_HEIGHT]];
    
    [arrowView setNeedsDisplay:YES];
    //        NSLog(@"Init modeOptionsView View height: %.f", NSHeight(optionsView.modeOptionsViewController.view.bounds));
    //        NSLog(@"Init options View height: %.f", NSHeight(optionsView.bounds));
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedModeChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedActionChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedAddActionChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedChangeActionMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.bluetoothMonitor addObserver:self forKeyPath:@"pairedDevicesCount"
                                      options:0 context:nil];
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"nicknamedConnectedCount"
                                      options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(openedModeChangeMenu))]) {
        [self toggleModeMenuFrame];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedActionChangeMenu))]) {
        [self toggleActionMenuFrame];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedAddActionChangeMenu))]) {
        [self toggleAddActionMenuFrame];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedChangeActionMenu))]) {
        // Called directly to include mode and batch action
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self resetPosition];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self toggleActionMenuFrame];
        [self toggleAddActionMenuFrame];
        [self toggleAddActionButtonView];
        [self adjustBatchActionsHeight:NO];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(pairedDevicesCount))]) {
        [self adjustDeviceTitles];
    }
}

#pragma mark - Drawing

- (void)toggleModeMenuFrame {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    if (appDelegate.modeMap.openedModeChangeMenu) {
        [modeMenu toggleScrollbar:appDelegate.modeMap.openedModeChangeMenu];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    if (!appDelegate.modeMap.openedModeChangeMenu) {
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [modeMenu toggleScrollbar:appDelegate.modeMap.openedModeChangeMenu];
        }];
    }
    
    if (appDelegate.modeMap.openedModeChangeMenu) {
        [[modeMenuConstraint animator] setConstant:MODE_MENU_HEIGHT];
    } else {
        [[modeMenuConstraint animator] setConstant:1];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)toggleActionMenuFrame {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    if (appDelegate.modeMap.openedActionChangeMenu) {
        [actionMenu toggleScrollbar:appDelegate.modeMap.openedActionChangeMenu];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    if (!appDelegate.modeMap.openedActionChangeMenu) {
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [actionMenu toggleScrollbar:appDelegate.modeMap.openedActionChangeMenu];
        }];
        [[actionMenuConstraint animator] setConstant:1];
    } else {
        [[actionMenuConstraint animator] setConstant:ACTION_MENU_HEIGHT];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)toggleAddActionMenuFrame {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    if (appDelegate.modeMap.openedAddActionChangeMenu) {
        [addActionMenu toggleScrollbar:appDelegate.modeMap.openedAddActionChangeMenu];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:
                                                            kCAMediaTimingFunctionEaseInEaseOut]];
    
    if (!appDelegate.modeMap.openedAddActionChangeMenu) {
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [addActionMenu toggleScrollbar:appDelegate.modeMap.openedAddActionChangeMenu];
        }];
        [[addActionMenuConstraint animator] setConstant:1.f];
    } else {
        [[addActionMenuConstraint animator] setConstant:ACTION_MENU_HEIGHT];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)toggleAddActionButtonView {
    if (appDelegate.modeMap.inspectingModeDirection != NO_DIRECTION) {
        [addActionButtonConstraint setConstant:ADD_ACTION_BUTTON_HEIGHT];
    } else {
        [addActionButtonConstraint setConstant:0.f];
    }
}

- (void)adjustDeviceTitles {
    NSTimeInterval openDuration = OPEN_DURATION;
    NSArray *devices = appDelegate.bluetoothMonitor.foundDevices.devices;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[deviceTitlesConstraint animator] setConstant:40*[devices count]];
    
    [NSAnimationContext endGrouping];
}

- (void)adjustOptionsHeight:(NSView *)optionsDetailView {
    if (!optionsView) return;
    
    [self removeConstraint:optionsConstraint];
    
    if (!optionsDetailView) {
        optionsConstraint = [NSLayoutConstraint constraintWithItem:optionsView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1.0 constant:CORNER_RADIUS];
        [self addConstraint:optionsConstraint];
    } else {
        optionsConstraint = [NSLayoutConstraint constraintWithItem:optionsView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:optionsDetailView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0 constant:0];
        [optionsView addConstraint:optionsConstraint];
    }
    
    //    NSLog(@"optionsView constraints: %@", optionsView.constraints);
    //    NSLog(@"modeOptionsView constraints: %@", optionsView.modeOptionsView.constraints);
}

- (void)toggleBatchActionsChangeActionMenu:(TTAction *)batchAction visible:(BOOL)visible {    
    [batchActionStackView toggleChangeActionMenu:batchAction visible:visible];
}

- (void)adjustBatchActionsHeight:(BOOL)animated {
//    NSLog(@"adjustBatchActionsHeight: %@", appDelegate.modeMap.tempModeName);

    [batchActionStackView assembleViews:animated];
}

- (void)resetPosition {
    [appDelegate.modeMap reset];
    if (appDelegate.modeMap.openedModeChangeMenu) {
        [appDelegate.modeMap setOpenedModeChangeMenu:NO];
    }
    if (appDelegate.modeMap.openedActionChangeMenu) {
        [appDelegate.modeMap setOpenedActionChangeMenu:NO];
    }
    if (appDelegate.modeMap.openedAddActionChangeMenu) {
        [appDelegate.modeMap setOpenedAddActionChangeMenu:NO];
    }
    if (appDelegate.modeMap.openedChangeActionMenu) {
        [appDelegate.modeMap setOpenedChangeActionMenu:NO];
    }
}

- (void)viewDidMoveToWindow {
    [[self window] setAcceptsMouseMovedEvents:YES];
}

#pragma mark - Pairing Modal

- (void)switchPanelModalPairing:(TTModalPairing)_modalPairing {
    if (_modalPairing == MODAL_PAIRING_INTRO && modalPairing == MODAL_PAIRING_SEARCH) {
        // Don't switch away from pairing search...
        return;
    }
    if (_modalPairing == MODAL_PAIRING_FAILURE &&
        (modalPairing != MODAL_PAIRING_SEARCH || panelModal != PANEL_MODAL_PAIRING)) {
        // Don't switch into failure if not searching...
        return;
    }
    
    [self cleanup];

    panelModal = PANEL_MODAL_PAIRING;
    modalPairing = _modalPairing;
    modalBarButton = [[TTModalBarButton alloc] init];
    [modalBarButton setPagePairing:modalPairing];

    if (modalPairing == MODAL_PAIRING_INTRO ||
        modalPairing == MODAL_PAIRING_SUCCESS ||
        modalPairing == MODAL_PAIRING_FAILURE) {
        modalPairingInfo = [[TTModalPairingInfo alloc] initWithPairing:modalPairing];
        [self setViews:@[arrowView,
                         titleBarView,
                         deviceTitlesView,
                         modalPairingInfo,
                         modalBarButton]
             inGravity:NSStackViewGravityTop];
    } else if (modalPairing == MODAL_PAIRING_SEARCH) {
        modalPairingScanningView = [[TTModalPairingScanningView alloc] init];
        [self setViews:@[arrowView,
                         titleBarView,
                         deviceTitlesView,
                         modalPairingScanningView.view,
                         modalBarButton]
             inGravity:NSStackViewGravityTop];
    }
    
    [self addArrowAndTitleConstraints];
}

- (void)cleanupPanelModalPairing {
    modalPairingScanningView = nil;
    modalBarButton = nil;
}

#pragma mark - FTUX Modal

- (void)switchPanelModalFTUX:(TTModalFTUX)_modalFTUX {
    if (panelModal != PANEL_MODAL_FTUX || !modalFTUXView) {
        panelModal = PANEL_MODAL_FTUX;
        modalBarButton = [[TTModalBarButton alloc] init];
        modalFTUXView = [[TTModalFTUXView alloc] initWithNibName:@"TTModalFTUXView" bundle:nil];
        
        [self setViews:@[arrowView,
                         titleBarView,
                         deviceTitlesView,
                         modalFTUXView.view,
                         modalBarButton]
             inGravity:NSStackViewGravityTop];

        [self addArrowAndTitleConstraints];
    }
    
    modalFTUX = _modalFTUX;
    [modalBarButton setPageFTUX:modalFTUX];
    [modalFTUXView setPage:modalFTUX];
}

- (void)cleanupPanelModalFTUX {
    modalFTUXView = nil;
    modalBarButton = nil;
}

#pragma mark - About Modal

- (void)switchPanelModalAbout {
    panelModal = PANEL_MODAL_ABOUT;
    modalAbout = [[TTModalAbout alloc] init];
    [self setViews:@[arrowView,
                     titleBarView,
                     deviceTitlesView,
                     modalAbout.view,
                     footerView]
         inGravity:NSStackViewGravityTop];
    [self addArrowAndTitleConstraints];
}

#pragma mark - Devices Modal

- (void)switchPanelModalDevices {
    panelModal = PANEL_MODAL_DEVICES;
    modalDevices = [[TTModalDevices alloc] init];
    [self setViews:@[arrowView,
                     titleBarView,
                     deviceTitlesView,
                     modalDevices.view,
                     footerView]
         inGravity:NSStackViewGravityTop];
    [self addArrowAndTitleConstraints];
}

#pragma mark - Settings Modal

- (void)switchPanelModalSettings {
    panelModal = PANEL_MODAL_SETTINGS;
    modalSettings = [[TTModalSettings alloc] init];
    [self setViews:@[arrowView,
                     titleBarView,
                     deviceTitlesView,
                     modalSettings.view,
                     footerView]
         inGravity:NSStackViewGravityTop];
    [self addArrowAndTitleConstraints];
}

#pragma mark - Support Modal

- (void)switchPanelModalSupport {
    panelModal = PANEL_MODAL_SUPPORT;
    modalSupportView = [[TTModalSupportView alloc] init];
    modalBarButton = [[TTModalBarButton alloc] init];

    [self setViews:@[arrowView,
                     titleBarView,
                     deviceTitlesView,
                     modalSupportView.view,
                     modalBarButton,
                     ]
         inGravity:NSStackViewGravityTop];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modalSupportView.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addArrowAndTitleConstraints];
    [modalBarButton setPageSupport:MODAL_SUPPORT_QUESTION];
}

@end
