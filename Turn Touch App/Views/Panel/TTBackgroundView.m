//
//  TTBackgroundView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTPanelController.h"
#import "TTBackgroundView.h"

#define STROKE_OPACITY .5f
#define OPEN_DURATION 0.42f
#define SEARCH_INSET 10.0f
#define TITLE_BAR_HEIGHT 38.0f
#define MODE_TABS_HEIGHT 92.0f
#define MODE_TITLE_HEIGHT 64.0f
#define MODE_MENU_HEIGHT 142.0f
#define MODE_OPTIONS_HEIGHT 128.0f
#define DIAMOND_LABELS_SIZE 270.0f

#pragma mark -

@implementation TTBackgroundView

@synthesize stackView;
@synthesize arrowView;
@synthesize titleBarView;
@synthesize modeTabs;
@synthesize modeTitle;
@synthesize modeMenu;
@synthesize diamondLabels;
@synthesize optionsView;

#pragma mark -

- (void)awakeFromNib {
    appDelegate = [NSApp delegate];
    
//    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    arrowView = [[TTPanelArrowView alloc] init];
    titleBarView = [[TTTitleBarView alloc] init];
    modeTabs = [[TTModeTabsContainer alloc] init];
    modeTitle = [[TTModeTitleView alloc] init];
    modeMenu = [[TTModeMenuContainer alloc] init];
    diamondLabels = [[TTDiamondLabels alloc] init];
    optionsView = [[TTOptionsView alloc] init];
    
    stackView = [[NSStackView alloc] init];
    [stackView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [stackView setViews:@[arrowView,
                          titleBarView,
                          modeTabs,
                          modeTitle,
                          modeMenu,
                          diamondLabels,
                          optionsView] inGravity:NSStackViewGravityTop];
    
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:arrowView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:stackView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:0
                                                           constant:0]];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:arrowView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0
                                                           constant:ARROW_HEIGHT]];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:titleBarView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0
                                                           constant:TITLE_BAR_HEIGHT]];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:modeTabs
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0
                                                           constant:MODE_TABS_HEIGHT]];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:modeTitle
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0
                                                           constant:MODE_TITLE_HEIGHT]];
    modeMenuConstraint = [NSLayoutConstraint constraintWithItem:modeMenu
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:0
                                                     multiplier:0
                                                       constant:1];
    [stackView addConstraint:modeMenuConstraint];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:diamondLabels
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0
                                                           constant:DIAMOND_LABELS_SIZE]];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:optionsView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0
                                                           constant:MODE_OPTIONS_HEIGHT]];
    // add a minimum width constraint
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0
                                                           constant:360]];
    
    // add a constraint not allowing the stackview to expand beyond the last view
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationLessThanOrEqual
                                                             toItem:[stackView.views lastObject]
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:stackView.edgeInsets.right]];
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    stackView.alignment = NSLayoutAttributeCenterX;
    stackView.spacing = 0;
    
    [self addSubview:stackView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:0.0]];

    [self registerAsObserver];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedModeChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(openedModeChangeMenu))]) {
        [self toggleModeMenuFrame];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self resetPosition];
    }
}

#pragma mark - Drawing

- (void)toggleModeMenuFrame {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 100;

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self.window invalidateShadow];
        [self.window update];
    }];

    if (appDelegate.modeMap.openedModeChangeMenu) {
        [[modeMenuConstraint animator] setConstant:MODE_MENU_HEIGHT];
    } else {
        [[modeMenuConstraint animator] setConstant:1];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)resetPosition {
    [appDelegate.modeMap reset];
    if (appDelegate.modeMap.openedModeChangeMenu) {
        [appDelegate.modeMap setOpenedModeChangeMenu:NO];
    }
}

- (void)viewDidMoveToWindow {
    [[self window] setAcceptsMouseMovedEvents:YES];
}

@end
