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

@interface TTBackgroundView ()

@property (nonatomic, strong) NSLayoutConstraint *modeMenuConstraint;
@property (nonatomic, strong) NSLayoutConstraint *actionMenuConstraint;
@property (nonatomic, strong) NSLayoutConstraint *addActionMenuConstraint;
@property (nonatomic, strong) NSLayoutConstraint *deviceTitlesConstraint;
@property (nonatomic, strong) NSLayoutConstraint *addActionButtonConstraint;
@property (nonatomic, strong) NSStackView *scrollStackView;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic) TTModalPairing modalPairing;
@property (nonatomic) TTModalSupport modalSupport;

@end

@implementation TTBackgroundView

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        
        [self setWantsLayer:YES];
        [self setHuggingPriority:NSLayoutPriorityDefaultHigh
                  forOrientation:NSLayoutConstraintOrientationVertical];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setOrientation:NSUserInterfaceLayoutOrientationVertical];
        [self setAlignment:NSLayoutAttributeCenterX];
        [self setSpacing:0];

        self.arrowView = [[TTPanelArrowView alloc] init];
        self.titleBarView = [[TTTitleBarView alloc] init];
        self.deviceTitlesView = [[TTDeviceTitlesView alloc] init];
        self.modeTabs = [[TTModeTabsContainer alloc] init];
        self.modeTitle = [[TTModeTitleView alloc] init];
        self.modeMenu = [[TTModeMenuContainer alloc] initWithType:MODE_MENU_TYPE];
        self.diamondLabels = [[TTDiamondLabels alloc] initWithInteractive:YES];
        self.optionsView = [[TTOptionsView alloc] init];
        self.actionMenu = [[TTModeMenuContainer alloc] initWithType:ACTION_MENU_TYPE];
        self.batchActionStackView = [[TTBatchActionStackView alloc] init];
        self.addActionMenu = [[TTModeMenuContainer alloc] initWithType:ADD_MODE_MENU_TYPE];
        self.addActionButtonView = [[TTAddActionButtonView alloc] init];
        self.footerView = [[TTFooterView alloc] init];
        
        self.scrollView = [[NSScrollView alloc] init];
        self.scrollView.borderType = NSNoBorder;
        self.scrollView.hasVerticalScroller = YES;
        self.scrollView.hasHorizontalScroller = NO;
        [self.scrollView setContentHuggingPriority:NSLayoutPriorityDefaultLow
                               forOrientation:NSLayoutConstraintOrientationVertical];
        self.scrollStackView = [[NSStackView alloc] init];
        self.scrollStackView.wantsLayer = YES;
        [self.scrollStackView setHuggingPriority:NSLayoutPriorityDefaultHigh
                             forOrientation:NSLayoutConstraintOrientationVertical];
        self.scrollStackView.translatesAutoresizingMaskIntoConstraints = NO;
        self.scrollStackView.orientation = NSUserInterfaceLayoutOrientationVertical;
        self.scrollStackView.alignment = NSLayoutAttributeCenterX;
        self.scrollStackView.spacing = 0.f;
        [self.scrollView addSubview:self.scrollStackView];
        [self.scrollView setDocumentView:self.scrollStackView];
        
        [self registerAsObserver];
    }
    
    return self;
}

- (void)switchPanelModal:(TTPanelModal)panelModal {
    self.panelModal = panelModal;
    
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
    for (NSLayoutConstraint *constraint in [self.scrollView constraints]) {
        [self.scrollView removeConstraint:constraint];
    }
    for (NSLayoutConstraint *constraint in [self.scrollStackView constraints]) {
        [self.scrollStackView removeConstraint:constraint];
    }
}

- (void)addArrowAndTitleConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:ARROW_HEIGHT]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleBarView
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
    self.panelModal = PANEL_MODAL_APP;
    [self cleanup];
    
    [self setViews:@[self.arrowView,
                     self.titleBarView,
                     self.deviceTitlesView,
                     self.modeTabs,
                     self.modeTitle,
                     self.modeMenu,
                     self.scrollView,
                     self.footerView] inGravity:NSStackViewGravityTop];
    
    [self.scrollStackView setViews:@[self.diamondLabels,
                                self.actionMenu,
                                self.optionsView,
                                self.batchActionStackView,
                                self.addActionMenu,
                                self.addActionButtonView] inGravity:NSStackViewGravityTop];
    
    [self addArrowAndTitleConstraints];
    
    self.deviceTitlesConstraint = [NSLayoutConstraint constraintWithItem:self.deviceTitlesView
                                                 attribute:NSLayoutAttributeHeight
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:nil
                                                 attribute:0 multiplier:1.0 constant:self.appDelegate.bluetoothMonitor.foundDevices.devices.count*40];
//    [self addConstraint:deviceTitlesConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.deviceTitlesView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.modeTabs
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:MODE_TABS_HEIGHT]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.modeTitle
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:MODE_TITLE_HEIGHT]];
    self.modeMenuConstraint = [NSLayoutConstraint constraintWithItem:self.modeMenu
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:0
                                                     multiplier:1.0 constant:1];
    [self.modeMenuConstraint setPriority:NSLayoutPriorityDefaultHigh];
    [self addConstraint:self.modeMenuConstraint];
    
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollStackView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollStackView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeft multiplier:1.f constant:0.f]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollStackView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeRight multiplier:1.f constant:-15.f]];
    
    NSLayoutConstraint *scrollViewHeight = [NSLayoutConstraint constraintWithItem:self.scrollView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.scrollStackView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.f constant:0.f];
    scrollViewHeight.priority = 999;
    [self addConstraint:scrollViewHeight];
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    CGFloat scrollHeight = NSHeight(screenRect) - 400;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.f constant:scrollHeight]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:0]];
    
    [self.scrollStackView addConstraint:[NSLayoutConstraint constraintWithItem:self.diamondLabels
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:0 constant:DIAMOND_LABELS_SIZE]];
    self.actionMenuConstraint = [NSLayoutConstraint constraintWithItem:self.actionMenu
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:0
                                                       multiplier:1.0 constant:1];
    [self.scrollStackView addConstraint:self.actionMenuConstraint];
    self.optionsConstraint = [NSLayoutConstraint constraintWithItem:self.optionsView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.optionsView.modeOptionsViewController.view
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0 constant:0];
    [self.scrollStackView addConstraint:self.optionsConstraint];
    self.addActionMenuConstraint = [NSLayoutConstraint constraintWithItem:self.addActionMenu
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:0
                                                          multiplier:1.0 constant:1.f];
    [self.scrollStackView addConstraint:self.addActionMenuConstraint];
    self.addActionButtonConstraint = [NSLayoutConstraint constraintWithItem:self.addActionButtonView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:0 multiplier:1.0
                                                              constant:0];
    [self.scrollStackView addConstraint:self.addActionButtonConstraint];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.footerView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:0 constant:FOOTER_HEIGHT]];
    
    [self.arrowView setNeedsDisplay:YES];
    //        NSLog(@"Init modeOptionsView View height: %.f", NSHeight(optionsView.modeOptionsViewController.view.bounds));
    //        NSLog(@"Init options View height: %.f", NSHeight(optionsView.bounds));
}

#pragma mark - KVO

- (void)registerAsObserver {
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"openedModeChangeMenu"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"openedActionChangeMenu"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"openedAddActionChangeMenu"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"openedChangeActionMenu"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self forKeyPath:@"pairedDevicesCount"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
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
    
    if (self.appDelegate.modeMap.openedModeChangeMenu) {
        [self.modeMenu toggleScrollbar:self.appDelegate.modeMap.openedModeChangeMenu];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    if (!self.appDelegate.modeMap.openedModeChangeMenu) {
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [self.modeMenu toggleScrollbar:self.appDelegate.modeMap.openedModeChangeMenu];
        }];
    }
    
    if (self.appDelegate.modeMap.openedModeChangeMenu) {
        [[self.modeMenuConstraint animator] setConstant:MODE_MENU_HEIGHT];
    } else {
        [[self.modeMenuConstraint animator] setConstant:1];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)toggleActionMenuFrame {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    if (self.appDelegate.modeMap.openedActionChangeMenu) {
        [self.actionMenu toggleScrollbar:self.appDelegate.modeMap.openedActionChangeMenu];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    if (!self.appDelegate.modeMap.openedActionChangeMenu) {
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [self.actionMenu toggleScrollbar:self.appDelegate.modeMap.openedActionChangeMenu];
        }];
        [[self.actionMenuConstraint animator] setConstant:1];
    } else {
        [[self.actionMenuConstraint animator] setConstant:ACTION_MENU_HEIGHT];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)toggleAddActionMenuFrame {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:
                                                            kCAMediaTimingFunctionEaseInEaseOut]];
    
    if (!self.appDelegate.modeMap.openedAddActionChangeMenu) {
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [self.addActionMenu toggleScrollbar:self.appDelegate.modeMap.openedAddActionChangeMenu];
        }];
        [[self.addActionMenuConstraint animator] setConstant:1.f];
    } else {
        [[self.addActionMenuConstraint animator] setConstant:ACTION_MENU_HEIGHT];
        
        CGFloat scroll = -1 * (self.scrollView.contentSize.height + NSMaxY([self.addActionButtonView convertRect:self.addActionButtonView.frame toView:self.scrollView]));
        NSClipView* clipView = [self.scrollView contentView];
        NSPoint newOrigin = [clipView bounds].origin;
        newOrigin.y = scroll;
        [[clipView animator] setBoundsOrigin:newOrigin];
        [self.scrollView reflectScrolledClipView:[self.scrollView contentView]];
    }
    
    [NSAnimationContext endGrouping];
    
    if (self.appDelegate.modeMap.openedAddActionChangeMenu) {
        [self.addActionMenu toggleScrollbar:self.appDelegate.modeMap.openedAddActionChangeMenu];
    }

}

- (void)toggleAddActionButtonView {
    if (self.appDelegate.modeMap.inspectingModeDirection != NO_DIRECTION) {
        [self.addActionButtonConstraint setConstant:ADD_ACTION_BUTTON_HEIGHT];
    } else {
        [self.addActionButtonConstraint setConstant:0.f];
    }
}

- (void)adjustDeviceTitles {
    NSTimeInterval openDuration = OPEN_DURATION;
    NSArray *devices = self.appDelegate.bluetoothMonitor.foundDevices.devices;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[self.deviceTitlesConstraint animator] setConstant:40*[devices count]];
    
    [NSAnimationContext endGrouping];
}

- (void)adjustOptionsHeight:(NSView *)optionsDetailView {
    if (!self.optionsView) return;
    
    [self removeConstraint:self.optionsConstraint];
    
    if (!optionsDetailView) {
        self.optionsConstraint = [NSLayoutConstraint constraintWithItem:self.optionsView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1.0 constant:CORNER_RADIUS];
        [self addConstraint:self.optionsConstraint];
    } else {
        self.optionsConstraint = [NSLayoutConstraint constraintWithItem:self.optionsView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:optionsDetailView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0 constant:0];
        [self.optionsView addConstraint:self.optionsConstraint];
    }
    
    //    NSLog(@"optionsView constraints: %@", optionsView.constraints);
    //    NSLog(@"modeOptionsView constraints: %@", optionsView.modeOptionsView.constraints);
}

- (void)toggleBatchActionsChangeActionMenu:(TTAction *)batchAction visible:(BOOL)visible {    
    [self.batchActionStackView toggleChangeActionMenu:batchAction visible:visible];
}

- (void)adjustBatchActionsHeight:(BOOL)animated {
//    NSLog(@"adjustBatchActionsHeight: %@", appDelegate.modeMap.tempModeName);

    [self.batchActionStackView assembleViews:animated];
}

- (void)resetPosition {
    [self.appDelegate.modeMap reset];
    if (self.appDelegate.modeMap.openedModeChangeMenu) {
        [self.appDelegate.modeMap setOpenedModeChangeMenu:NO];
    }
    if (self.appDelegate.modeMap.openedActionChangeMenu) {
        [self.appDelegate.modeMap setOpenedActionChangeMenu:NO];
    }
    if (self.appDelegate.modeMap.openedAddActionChangeMenu) {
        [self.appDelegate.modeMap setOpenedAddActionChangeMenu:NO];
    }
    if (self.appDelegate.modeMap.openedChangeActionMenu) {
        [self.appDelegate.modeMap setOpenedChangeActionMenu:NO];
    }
}

- (void)viewDidMoveToWindow {
    [[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)scrollToPosition:(float)yCoord {
    NSClipView* clipView = [self.scrollView contentView];
    
//    if (yCoord < clipView.bounds.origin.y + (clipView.bounds.size.height - 2) &&
//        yCoord > clipView.bounds.origin.y) return;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.35];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    NSPoint newOrigin = [clipView bounds].origin;
    newOrigin.y = yCoord - 2;
    [[clipView animator] setBoundsOrigin:newOrigin];
    [self.scrollView reflectScrolledClipView:[self.scrollView contentView]];
    [NSAnimationContext endGrouping];
}

#pragma mark - Pairing Modal

- (void)switchPanelModalPairing:(TTModalPairing)modalPairing {
    if (modalPairing == MODAL_PAIRING_INTRO && self.modalPairing == MODAL_PAIRING_SEARCH) {
        // Don't switch away from pairing search...
        return;
    }
    if (modalPairing == MODAL_PAIRING_FAILURE &&
        (self.modalPairing != MODAL_PAIRING_SEARCH || self.panelModal != PANEL_MODAL_PAIRING)) {
        // Don't switch into failure if not searching...
        return;
    }
    
    [self cleanup];

    self.panelModal = PANEL_MODAL_PAIRING;
    self.modalPairing = modalPairing;
    self.modalBarButton = [[TTModalBarButton alloc] init];
    [self.modalBarButton setPagePairing:modalPairing];

    if (self.modalPairing == MODAL_PAIRING_INTRO ||
        self.modalPairing == MODAL_PAIRING_SUCCESS ||
        self.modalPairing == MODAL_PAIRING_FAILURE) {
        self.modalPairingInfo = [[TTModalPairingInfo alloc] initWithPairing:self.modalPairing];
        [self setViews:@[self.arrowView,
                         self.titleBarView,
                         self.deviceTitlesView,
                         self.modalPairingInfo,
                         self.modalBarButton]
             inGravity:NSStackViewGravityTop];
    } else if (self.modalPairing == MODAL_PAIRING_SEARCH) {
        self.modalPairingScanningView = [[TTModalPairingScanningView alloc] init];
        [self setViews:@[self.arrowView,
                         self.titleBarView,
                         self.deviceTitlesView,
                         self.modalPairingScanningView.view,
                         self.modalBarButton]
             inGravity:NSStackViewGravityTop];
    }
    
    [self addArrowAndTitleConstraints];
}

- (void)cleanupPanelModalPairing {
    self.modalPairingScanningView = nil;
    self.modalBarButton = nil;
}

#pragma mark - FTUX Modal

- (void)switchPanelModalFTUX:(TTModalFTUX)modalFTUX {
    if (self.panelModal != PANEL_MODAL_FTUX || !self.modalFTUXView) {
        self.panelModal = PANEL_MODAL_FTUX;
        self.modalBarButton = [[TTModalBarButton alloc] init];
        self.modalFTUXView = [[TTModalFTUXView alloc] initWithNibName:@"TTModalFTUXView" bundle:nil];
        
        [self setViews:@[self.arrowView,
                         self.titleBarView,
                         self.deviceTitlesView,
                         self.modalFTUXView.view,
                         self.modalBarButton]
             inGravity:NSStackViewGravityTop];

        [self addArrowAndTitleConstraints];
    }
    
    self.modalFTUX = _modalFTUX;
    [self.modalBarButton setPageFTUX:modalFTUX];
    [self.modalFTUXView setPage:modalFTUX];
}

- (void)cleanupPanelModalFTUX {
    self.modalFTUXView = nil;
    self.modalBarButton = nil;
}

#pragma mark - About Modal

- (void)switchPanelModalAbout {
    self.panelModal = PANEL_MODAL_ABOUT;
    self.modalAbout = [[TTModalAbout alloc] init];
    [self setViews:@[self.arrowView,
                     self.titleBarView,
                     self.deviceTitlesView,
                     self.modalAbout.view,
                     self.footerView]
         inGravity:NSStackViewGravityTop];
    [self addArrowAndTitleConstraints];
}

#pragma mark - Devices Modal

- (void)switchPanelModalDevices {
    self.panelModal = PANEL_MODAL_DEVICES;
    self.modalDevices = [[TTModalDevices alloc] init];
    [self setViews:@[self.arrowView,
                     self.titleBarView,
                     self.deviceTitlesView,
                     self.modalDevices.view,
                     self.footerView]
         inGravity:NSStackViewGravityTop];
    [self addArrowAndTitleConstraints];
}

#pragma mark - Settings Modal

- (void)switchPanelModalSettings {
    self.panelModal = PANEL_MODAL_SETTINGS;
    self.modalSettings = [[TTModalSettings alloc] init];
    [self setViews:@[self.arrowView,
                     self.titleBarView,
                     self.deviceTitlesView,
                     self.modalSettings.view,
                     self.footerView]
         inGravity:NSStackViewGravityTop];
    [self addArrowAndTitleConstraints];
}

#pragma mark - Support Modal

- (void)switchPanelModalSupport {
    self.panelModal = PANEL_MODAL_SUPPORT;
    self.modalSupportView = [[TTModalSupportView alloc] init];
    self.modalBarButton = [[TTModalBarButton alloc] init];

    [self setViews:@[self.arrowView,
                     self.titleBarView,
                     self.deviceTitlesView,
                     self.modalSupportView.view,
                     self.modalBarButton,
                     ]
         inGravity:NSStackViewGravityTop];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.modalSupportView.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addArrowAndTitleConstraints];
    [self.modalBarButton setPageSupport:MODAL_SUPPORT_QUESTION];
}

@end
