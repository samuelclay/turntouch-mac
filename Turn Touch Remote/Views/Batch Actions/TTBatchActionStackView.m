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
    NSLog(@"assembleViews: %@", appDelegate.modeMap.tempModeName);
    NSTimeInterval openDuration = OPEN_DURATION;
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;

    NSMutableArray *views = [NSMutableArray array];
    TTBatchActionHeaderView *tempHeaderView;
    NSArray *batchActions = [appDelegate.modeMap selectedModeBatchActions:appDelegate.modeMap.inspectingModeDirection];
    [self removeConstraints:[self constraints]];
    
    for (TTBatchAction *batchAction in batchActions) {
        TTBatchActionHeaderView *batchActionHeaderView = [[TTBatchActionHeaderView alloc] initWithBatchAction:batchAction];
        [views addObject:batchActionHeaderView];
    }
    if (appDelegate.modeMap.tempMode) {
        tempHeaderView = [[TTBatchActionHeaderView alloc] initWithTempMode:appDelegate.modeMap.tempMode];
        [views addObject:tempHeaderView];
    }

    [self setViews:views inGravity:NSStackViewGravityTop];

    for (TTBatchActionHeaderView *view in self.views) {
        NSInteger height = BATCH_ACTION_HEADER_HEIGHT;
        if (animated && view == tempHeaderView) height = 0;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:0 multiplier:1.0 constant:height];
        [self addConstraint:constraint];
        if (animated && view == tempHeaderView) tempHeaderConstraint = constraint;
    }

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:OPEN_DURATION];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:
                                                            kCAMediaTimingFunctionEaseInEaseOut]];
    if (tempHeaderView) {
        [[tempHeaderConstraint animator] setConstant:BATCH_ACTION_HEADER_HEIGHT];
    }
    [NSAnimationContext endGrouping];
}

@end
