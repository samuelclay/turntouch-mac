//
//  TTBatchActionStackView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/20/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTBatchActionStackView.h"
#import "TTBatchActionHeaderView.h"

const NSInteger BATCH_ACTION_HEADER_HEIGHT = 36;

@implementation TTBatchActionStackView

@synthesize tempMode;
@synthesize actionOptionsViewControllers;
@synthesize changeActionMenuViewControllers;
@synthesize changeActionMenuViewConstraints;

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        [self setWantsLayer:YES];
        [self setHuggingPriority:NSLayoutPriorityDefaultHigh
                  forOrientation:NSLayoutConstraintOrientationVertical];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setOrientation:NSUserInterfaceLayoutOrientationVertical];
        [self setAlignment:NSLayoutAttributeCenterX];
        [self setSpacing:0];

//        [self assembleViews];
        
        [self registerAsObserver];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xFFFFFF) set];
    NSRectFill(self.bounds);
}


#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        if (changeActionBatchActionKey) {
            [self toggleChangeActionMenu:nil visible:NO];
        }
    }
}

- (void)dealloc {
    [appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
}

#pragma mark - Change Action Menu

- (void)toggleChangeActionMenu:(TTAction *)batchAction visible:(BOOL)visible {
    NSLayoutConstraint *changeActionMenuConstraint;
    
    if (!visible) {
        changeActionBatchActionKey = nil;
        appDelegate.modeMap.batchActionChangeAction = nil;
        [appDelegate.modeMap setOpenedChangeActionMenu:NO];
        
        changeActionMenuConstraint = changeActionMenuViewConstraints[batchAction.batchActionKey];
    } else {
        changeActionBatchActionKey = batchAction.batchActionKey;
        appDelegate.modeMap.batchActionChangeAction = batchAction;
        [appDelegate.modeMap setOpenedChangeActionMenu:YES];

        NSView *changeActionMenuPlaceholder = changeActionMenuViewControllers[batchAction.batchActionKey];
        TTModeMenuContainer *changeActionMenu = [[TTModeMenuContainer alloc] initWithType:CHANGE_BATCH_ACTION_MENU_TYPE];
        [self replaceSubview:changeActionMenuPlaceholder with:changeActionMenu];
        [changeActionMenuViewControllers setObject:changeActionMenu forKey:batchAction.batchActionKey];
        
        changeActionMenuConstraint = changeActionMenuViewConstraints[batchAction.batchActionKey];
        [self removeConstraint:changeActionMenuConstraint];
        changeActionMenuConstraint = [NSLayoutConstraint constraintWithItem:changeActionMenuViewControllers[batchAction.batchActionKey]
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:0
                                                                 multiplier:1.0 constant:0.f];
        [self addConstraint:changeActionMenuConstraint];
        [changeActionMenuViewConstraints setObject:changeActionMenuConstraint forKey:batchAction.batchActionKey];
        
        
        [changeActionMenu setNeedsDisplay:YES];
        batchAction.changeActionMenu = changeActionMenu;
    }
    

    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    if (changeActionBatchActionKey) {
        [batchAction.changeActionMenu toggleScrollbar:YES];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:
                                                            kCAMediaTimingFunctionEaseInEaseOut]];
    
    if (!changeActionBatchActionKey) {
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [batchAction.changeActionMenu toggleScrollbar:NO];
        }];
        [[changeActionMenuConstraint animator] setConstant:0.f];
    } else {
        [[changeActionMenuConstraint animator] setConstant:ACTION_MENU_HEIGHT];
    }
    
    [NSAnimationContext endGrouping];
}

#pragma mark - Drawing

- (void)assembleViews:(BOOL)animated {
    NSTimeInterval openDuration = OPEN_DURATION;
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;

    // Cleanup old batch actions
    NSMutableArray *views = [NSMutableArray array];
    TTBatchActionHeaderView *tempHeaderView;
    NSArray *batchActions = [appDelegate.modeMap selectedModeBatchActions:appDelegate.modeMap.inspectingModeDirection];
    [self removeConstraints:[self constraints]];
    [actionOptionsViewControllers removeAllObjects];
    actionOptionsViewControllers = [NSMutableArray array];
    changeActionMenuViewControllers = [NSMutableDictionary dictionary];
    changeActionMenuViewConstraints = [NSMutableDictionary dictionary];
    
    if (!animated) {
        // If not animated then most likely loading initial, so toss change action menu
        changeActionBatchActionKey = nil;
    }
    
    // Add each action's header and options
    for (TTAction *batchAction in batchActions) {
        // Header
        TTBatchActionHeaderView *batchActionHeaderView = [[TTBatchActionHeaderView alloc] initWithBatchAction:batchAction];
        [views addObject:batchActionHeaderView];
        
        // Changing action, show action menu
        NSView *view = [[NSView alloc] initWithFrame:NSZeroRect];
        [views addObject:view];
        [changeActionMenuViewControllers setObject:view forKey:batchAction.batchActionKey];
        
        // Options
        NSString *actionOptionsViewControllerName = [NSString stringWithFormat:@"%@Options", batchAction.actionName];
        TTOptionsDetailViewController *actionOptionsViewController = [[NSClassFromString(actionOptionsViewControllerName) alloc]
                                                                      initWithNibName:actionOptionsViewControllerName bundle:nil];
        // TODO: Set action option's active mode
        if (!actionOptionsViewController) {
            NSLog(@" --- Missing (batch) action options view for %@", batchAction.actionName);
        } else {
            actionOptionsViewController.menuType = ADD_ACTION_MENU_TYPE; // I apologize for re-using this enum
            actionOptionsViewController.action = batchAction;
            actionOptionsViewController.mode = batchAction.mode;
            [views addObject:actionOptionsViewController.view];
            [actionOptionsViewControllers addObject:actionOptionsViewController]; // Cache so it doesn't lose reference in xib
        }

    }
    
    // At bottom is `tempMode`
    if (appDelegate.modeMap.tempMode) {
        tempHeaderView = [[TTBatchActionHeaderView alloc] initWithTempMode:appDelegate.modeMap.tempMode];
        [views addObject:tempHeaderView];
    }

    [self setViews:views inGravity:NSStackViewGravityTop];

    // Now that views are in NSStackView, add constraints
    for (NSView *view in self.views) {
        NSInteger height = BATCH_ACTION_HEADER_HEIGHT;
        if ([view isKindOfClass:[TTBatchActionHeaderView class]]) {
            if (animated && view == tempHeaderView) height = 0;
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:0 multiplier:1.0 constant:height];
            [self addConstraint:constraint];
            if (animated && view == tempHeaderView) tempHeaderConstraint = constraint;
        } else if ([view isKindOfClass:[TTOptionsDetailViewController class]]) {

        }
    }
    for (NSString *batchActionKey in [changeActionMenuViewControllers allKeys]) {
        NSLayoutConstraint *changeActionMenuConstraint = [NSLayoutConstraint constraintWithItem:changeActionMenuViewControllers[batchActionKey]
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:nil
                                                                                      attribute:0
                                                                                     multiplier:1.0 constant:0.f];
        [self addConstraint:changeActionMenuConstraint];
        [changeActionMenuViewConstraints setObject:changeActionMenuConstraint forKey:batchActionKey];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:OPEN_DURATION];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:
                                                            kCAMediaTimingFunctionEaseInEaseOut]];
    // Only the tempMode gets animated in. Everything else is instant like any mode/action transition.
    if (tempHeaderView) {
        [[tempHeaderConstraint animator] setConstant:BATCH_ACTION_HEADER_HEIGHT];
    }
    [NSAnimationContext endGrouping];
}

@end
