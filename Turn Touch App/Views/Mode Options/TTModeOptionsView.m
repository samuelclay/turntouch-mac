//
//  TTModeOptionsView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 5/12/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTModeOptionsView.h"

@implementation TTModeOptionsView

@synthesize tabView;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)isFlipped {
    return YES;
}

#pragma mark - Animation

- (void)animateBlock:(void (^)())block {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[NSAnimationContext currentContext] setCompletionHandler:^{
//        [appDelegate.panelController.backgroundView.optionsView resize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [appDelegate.panelController.window invalidateShadow];
        });
    }];
    
    block();
    
    [appDelegate.panelController.backgroundView.optionsView layoutSubtreeIfNeeded];
    [appDelegate.panelController.backgroundView layoutSubtreeIfNeeded];
    
    [NSAnimationContext endGrouping];
    
}

#pragma mark - Tab View

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    NSLog(@"Tab view: %@", NSStringFromRect(self.bounds));
    dispatch_async(dispatch_get_main_queue(), ^{
        [appDelegate.panelController.window invalidateShadow];
    });
}

@end
