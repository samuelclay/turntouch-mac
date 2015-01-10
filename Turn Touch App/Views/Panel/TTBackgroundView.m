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
#define SEARCH_INSET 10.0f
#define TITLE_BAR_HEIGHT 38.0f
#define MODE_TABS_HEIGHT 92.0f
#define MODE_TITLE_HEIGHT 64.0f
#define MODE_MENU_HEIGHT 146.0f
#define ACTION_MENU_HEIGHT 98.0f
#define MODE_OPTIONS_HEIGHT 148.0f
#define DIAMOND_LABELS_SIZE 270.0f

#pragma mark -

@implementation TTBackgroundView

@synthesize stackView;
@synthesize arrowView;
@synthesize titleBarView;
@synthesize modeTabs;
@synthesize modeTitle;
@synthesize modeMenu;
@synthesize actionMenu;
@synthesize diamondLabels;
@synthesize optionsView;
@synthesize optionsConstraint;

#pragma mark -

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        
        arrowView = [[TTPanelArrowView alloc] init];
        titleBarView = [[TTTitleBarView alloc] init];
        modeTabs = [[TTModeTabsContainer alloc] init];
        modeTitle = [[TTModeTitleView alloc] init];
        modeMenu = [[TTModeMenuContainer alloc] initWithType:MODE_MENU_TYPE];
        diamondLabels = [[TTDiamondLabels alloc] initWithInteractive:YES];
        optionsView = [[TTOptionsView alloc] init];
        actionMenu = [[TTModeMenuContainer alloc] initWithType:ACTION_MENU_TYPE];
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self setViews:@[arrowView,
                              titleBarView,
                              modeTabs,
                              modeTitle,
                              modeMenu,
                              diamondLabels,
                              actionMenu,
                              optionsView] inGravity:NSStackViewGravityTop];
        
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
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleBarView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:0
                                                             multiplier:1.0 constant:TITLE_BAR_HEIGHT]];
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
                                                           multiplier:1.0 constant:0];
        [self addConstraint:actionMenuConstraint];
        optionsConstraint = [NSLayoutConstraint constraintWithItem:optionsView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:optionsView.modeOptionsViewController.view
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0 constant:0];
        [self addConstraint:optionsConstraint];
        
        NSLog(@"Init modeOptionsView View height: %.f", NSHeight(optionsView.modeOptionsViewController.view.bounds));
        NSLog(@"Init options View height: %.f", NSHeight(optionsView.bounds));

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:0
                                                             multiplier:0
                                                               constant:360]];
        
        self.orientation = NSUserInterfaceLayoutOrientationVertical;
        self.alignment = NSLayoutAttributeCenterX;
        self.spacing = 0;

        [self registerAsObserver];
    }
    
    return self;
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
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
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
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self resetPosition];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self redrawShadow];
    }
}

#pragma mark - Drawing

- (void)redrawShadow {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.window invalidateShadow];
        [self.window update];
    });
}

- (void)toggleModeMenuFrame {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 50;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self redrawShadow];
    }];
    
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
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self.window invalidateShadow];
        [self.window update];
    }];
    
    if (appDelegate.modeMap.openedActionChangeMenu) {
        [[actionMenuConstraint animator] setConstant:ACTION_MENU_HEIGHT];
    } else {
        [[actionMenuConstraint animator] setConstant:0];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)adjustOptionsHeight:(NSView *)optionsDetailView {
//    if (!stackView) return;
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
        [self addConstraint:optionsConstraint];
    }
    
//    NSLog(@"stackView constraints: %@", stackView.constraints);
//    NSLog(@"optionsView constraints: %@", optionsView.constraints);
//    NSLog(@"modeOptionsView constraints: %@", optionsView.modeOptionsView.constraints);
}

- (void)resetPosition {
    [appDelegate.modeMap reset];
    if (appDelegate.modeMap.openedModeChangeMenu) {
        [appDelegate.modeMap setOpenedModeChangeMenu:NO];
    }
    if (appDelegate.modeMap.openedActionChangeMenu) {
        [appDelegate.modeMap setOpenedActionChangeMenu:NO];
    }
}

- (void)viewDidMoveToWindow {
    [[self window] setAcceptsMouseMovedEvents:YES];
}

@end
