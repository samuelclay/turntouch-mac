//
//  TTOptionsViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTOptionsDetailViewController.h"
#import "TTOptionsDetailView.h"

@interface TTOptionsDetailViewController ()

@end

@implementation TTOptionsDetailViewController

@synthesize tabView;
@synthesize menuType;
@synthesize action;
@synthesize mode;

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate = (TTAppDelegate *)[NSApp delegate];
}

#pragma mark - Animation

- (void)animateBlock:(void (^)(void))block {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    block();
    
    [appDelegate.panelController.backgroundView.optionsView layoutSubtreeIfNeeded];
    [appDelegate.panelController.backgroundView layoutSubtreeIfNeeded];
    
    [NSAnimationContext endGrouping];
    
}

@end
