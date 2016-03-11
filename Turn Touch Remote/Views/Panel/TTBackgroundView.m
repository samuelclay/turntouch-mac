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

#define PANEL_WIDTH 360.0f
#define STROKE_OPACITY .5f
#define SEARCH_INSET 10.0f
#define TITLE_BAR_HEIGHT 38.0f
#define MODE_TABS_HEIGHT 92.0f
#define MODE_TITLE_HEIGHT 64.0f
#define MODE_MENU_HEIGHT 146.0f
#define ACTION_MENU_HEIGHT 96.0f
#define MODE_OPTIONS_HEIGHT 148.0f
#define DIAMOND_LABELS_SIZE 270.0f
#define ADD_ACTION_BUTTON_HEIGHT 48.0f
#define FOOTER_HEIGHT 8.0f

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
@synthesize dfuView;
@synthesize batchActionStackView;
@synthesize addActionButtonView;
@synthesize footerView;
@synthesize modalPairingScanningView;
@synthesize modalBarButton;

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
        dfuView = [[TTDFUView alloc] init];
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
        
        [self switchPanelModel:PANEL_MODAL_APP];
        [self registerAsObserver];
    }
    
    return self;
}

- (void)switchPanelModel:(TTPanelModal)_panelModal {
    panelModal = _panelModal;
    [self removeConstraints:[self constraints]];
    if (panelModal == PANEL_MODAL_APP) {
        [self switchPanelModalApp];
    } else if (panelModal == PANEL_MODAL_PAIRING) {
        [self switchPanelModalPairing];
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
}

- (void)switchPanelModalApp {
    [self setViews:@[arrowView,
                     titleBarView,
                     dfuView,
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
    
    dfuConstraint = [NSLayoutConstraint constraintWithItem:dfuView
                                                 attribute:NSLayoutAttributeHeight
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:nil
                                                 attribute:0 multiplier:1.0 constant:0];
    [self addConstraint:dfuConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:dfuView
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
                                                              constant:ADD_ACTION_BUTTON_HEIGHT];
    [self addConstraint:addActionButtonConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:footerView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:0 constant:FOOTER_HEIGHT]];
    //        NSLog(@"Init modeOptionsView View height: %.f", NSHeight(optionsView.modeOptionsViewController.view.bounds));
    //        NSLog(@"Init options View height: %.f", NSHeight(optionsView.bounds));
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:0
                                                      constant:PANEL_WIDTH]];
}

- (void)switchPanelModalPairing {
    modalPairingScanningView = [[TTModalPairingScanningView alloc] init];
    modalBarButton = [[TTModalBarButton alloc] init];
    
    [self setViews:@[arrowView,
                     titleBarView,
                     modalPairingScanningView.view,
                     modalBarButton]
         inGravity:NSStackViewGravityTop];
    
    [self addArrowAndTitleConstraints];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:modalPairingScanningView.view
//                                                     attribute:NSLayoutAttributeHeight
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:nil
//                                                     attribute:0
//                                                    multiplier:1.0 constant:524]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modalBarButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:0 constant:84]];
}

- (void)updateConstraints {
//    NSLog(@"updateConstraints");
    [super updateConstraints];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedModeChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedActionChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedAddActionChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"tempModeName"
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
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self resetPosition];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self toggleActionMenuFrame];
        [self toggleAddActionMenuFrame];
        [self toggleAddActionButtonView];
        [self adjustBatchActionsHeight:NO];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(nicknamedConnectedCount))]) {
        [self toggleDfuList];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(tempModeName))]) {
        [self adjustBatchActionsHeight:YES];
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

- (void)toggleDfuList {
    NSTimeInterval openDuration = OPEN_DURATION;
    NSArray *devices = [appDelegate.bluetoothMonitor.foundDevices nicknamedConnected];
    BOOL anyExpired = NO;
    for (TTDevice *device in devices) {
        if (device.isFirmwareOld) {
            anyExpired = YES;
        }
    }
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    if (anyExpired) {
        [[dfuConstraint animator] setConstant:40*[devices count] + 1];
    } else {
        [[dfuConstraint animator] setConstant:0];
    }
    
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
}

- (void)viewDidMoveToWindow {
    [[self window] setAcceptsMouseMovedEvents:YES];
}

@end
