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
        
//        [self registerAsObserver];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xFFFFFF) set];
    NSRectFill(self.bounds);
}

//#pragma mark - KVO
//
//- (void)registerAsObserver {
//    [appDelegate.modeMap addObserver:self forKeyPath:@"tempModeName"
//                             options:0 context:nil];
//}
//
//- (void) observeValueForKeyPath:(NSString*)keyPath
//                       ofObject:(id)object
//                         change:(NSDictionary*)change
//                        context:(void*)context {
//    if ([keyPath isEqual:NSStringFromSelector(@selector(tempModeName))]) {
////        [self assembleViews];
//    }
//}
//
//- (void)dealloc {
//    [appDelegate.modeMap removeObserver:self forKeyPath:@"tempModeName"];
//}
//
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
    
    // Add each action's header and options
    for (TTAction *batchAction in batchActions) {
        // Header
        TTBatchActionHeaderView *batchActionHeaderView = [[TTBatchActionHeaderView alloc] initWithBatchAction:batchAction];
        [views addObject:batchActionHeaderView];
        
        // Options
        NSString *actionOptionsViewControllerName = [NSString stringWithFormat:@"%@Options", batchAction.actionName];
        TTOptionsDetailViewController *actionOptionsViewController = [[NSClassFromString(actionOptionsViewControllerName) alloc]
                                                                      initWithNibName:actionOptionsViewControllerName bundle:nil];
        if (!actionOptionsViewController) {
            NSLog(@" --- Missing (batch) action options view for %@", batchAction.actionName);
        } else {
            actionOptionsViewController.menuType = ADD_ACTION_MENU_TYPE; // I apologize for re-using this enum
            actionOptionsViewController.action = batchAction;
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
