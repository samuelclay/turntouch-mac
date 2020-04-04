//
//  TTOptionsView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/26/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTOptionsDetailViewController.h"
#import "TTOptionsActionTitle.h"

#define MARGIN 0.0f
#define CORNER_RADIUS 8.0f

@interface TTOptionsView ()

@property (nonatomic, strong) TTOptionsActionTitle *actionTitleView;

@end

@implementation TTOptionsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self clearOptionDetailViews];
//        [self drawModeOptions];
        [self registerAsObserver];
    }
    
    return self;
}

#pragma mark - KVO

- (void)registerAsObserver {
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self redrawOptions];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self drawModeOptions];
    }
}

- (void)dealloc {
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"activeModeDirection"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"selectedModeDirection"];
}

#pragma mark - Drawing

- (void)redrawOptions {
    if (self.appDelegate.modeMap.inspectingModeDirection != NO_DIRECTION) {
        [self drawActionOptions];
    } else {
        [self drawModeOptions];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self drawBackground];
}

- (void)drawBackground {
    [NSColorFromRGB(0xFFFFFF) set];
    NSRectFill(self.bounds);
}

#pragma mark - Options views

- (void)clearOptionDetailViews {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([[constraint.firstItem class] isSubclassOfClass:[TTOptionsDetailView class]]) {
            [self removeConstraint:constraint];
        }
    }

    if (self.modeOptionsViewController) {
        [self.modeOptionsViewController.view removeFromSuperview];
        self.modeOptionsViewController = nil;
    }
    if (self.actionOptionsViewController) {
        [self.actionOptionsViewController.view removeFromSuperview];
        self.actionOptionsViewController = nil;
    }
    if (self.actionTitleView) {
        [self.actionTitleView removeFromSuperview];
        self.actionTitleView = nil;
    }
}

- (void)drawModeOptions {
    if (self.appDelegate.modeMap.inspectingModeDirection != NO_DIRECTION) return;
    [self clearOptionDetailViews];

    NSString *modeName = NSStringFromClass([self.appDelegate.modeMap.selectedMode class]);
    NSString *modeOptionsViewControllerName = [NSString stringWithFormat:@"%@Options", modeName];
    self.modeOptionsViewController = [[NSClassFromString(modeOptionsViewControllerName) alloc]
                                 initWithNibName:modeOptionsViewControllerName bundle:nil];
//    NSLog(@"Options frame %@ pre: %@", self.modeOptionsViewControllerName, NSStringFromRect(self.frame));
    
    if (!self.modeOptionsViewController) {
//        NSLog(@" --- Missing mode options view for %@", modeName);
        self.modeOptionsViewController = (TTOptionsDetailViewController *)[[NSViewController alloc] init];
        [self.modeOptionsViewController setView:[[TTOptionsDetailView alloc] init]];
        // A temporary solution to fix drawing issues in dark mode; should properly implement dark mode later.
        self.modeOptionsViewController.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        [self addSubview:self.modeOptionsViewController.view];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.modeOptionsViewController.view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1.0 constant:CORNER_RADIUS]];
    } else {
        self.modeOptionsViewController.mode = self.appDelegate.modeMap.selectedMode;
        self.modeOptionsViewController.menuType = MODE_MENU_TYPE;
        [self addSubview:self.modeOptionsViewController.view];
    }

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.modeOptionsViewController.view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.modeOptionsViewController.view
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.modeOptionsViewController.view
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0 constant:0]];

    [self.appDelegate.panelController.backgroundView adjustOptionsHeight:self.modeOptionsViewController.view];
//    NSLog(@"Options frame %@ post: %@ (%@)", self.modeOptionsViewControllerName, NSStringFromRect(self.frame), NSStringFromRect(self.modeOptionsViewController.view.frame));
}

- (void)drawActionOptions {
    if (self.appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) return;

    [self clearOptionDetailViews];
    
    BOOL useModeOptions = NO;
    if ([self.appDelegate.modeMap.selectedMode shouldUseModeOptionsFor:self.appDelegate.modeMap.inspectingModeDirection]) {
        useModeOptions = YES;
    }

    // Draw action title
    self.actionTitleView = [[TTOptionsActionTitle alloc] initWithFrame:CGRectZero];
    self.actionTitleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.actionTitleView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.actionTitleView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.actionTitleView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.actionTitleView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:60]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.actionTitleView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:0]];

    // Draw action options    
    NSString *actionName = [self.appDelegate.modeMap.selectedMode
                            actionNameInDirection:self.appDelegate.modeMap.inspectingModeDirection];
    NSString *actionOptionsViewControllerName = [NSString stringWithFormat:@"%@Options", actionName];
    self.actionOptionsViewController = [[NSClassFromString(actionOptionsViewControllerName) alloc]
                                   initWithNibName:actionOptionsViewControllerName bundle:nil];
    if (useModeOptions) {
        NSString *modeName = NSStringFromClass([self.appDelegate.modeMap.selectedMode class]);
        NSString *modeOptionsViewControllerName = [NSString stringWithFormat:@"%@Options", modeName];
        self.actionOptionsViewController = [[NSClassFromString(modeOptionsViewControllerName) alloc]
                                       initWithNibName:modeOptionsViewControllerName bundle:nil];
    }

    if (!self.actionOptionsViewController) {
        NSLog(@" --- Missing action options view for %@", actionName);
        self.actionOptionsViewController = (TTOptionsDetailViewController *)[[NSViewController alloc] init];
        [self.actionOptionsViewController setView:[[TTOptionsDetailView alloc] init]];
        [self addSubview:self.actionOptionsViewController.view];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.actionOptionsViewController.view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1.0 constant:CORNER_RADIUS]];
    } else {
        self.actionOptionsViewController.menuType = ACTION_MENU_TYPE;
        self.actionOptionsViewController.action = [[TTAction alloc] initWithActionName:actionName
                                                                        direction:self.appDelegate.modeMap.inspectingModeDirection];
        self.actionOptionsViewController.mode = self.appDelegate.modeMap.selectedMode;
        [self.actionOptionsViewController.mode setAction:self.actionOptionsViewController.action];
        self.actionOptionsViewController.action.mode = self.appDelegate.modeMap.selectedMode; // To parallel batch actions
        [self addSubview:self.actionOptionsViewController.view];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.actionOptionsViewController.view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.actionTitleView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.actionOptionsViewController.view
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.actionTitleView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.actionOptionsViewController.view
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.actionTitleView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0 constant:0]];
    [self.appDelegate.panelController.backgroundView adjustOptionsHeight:self.actionOptionsViewController.view];
}

@end
