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

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSView *_superv = [self superview];
    [self removeFromSuperview];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [_superv addSubview:self];
    
    NSLog(@"Doing the mode options view dance");
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
    }];
    
    block();
    
    [appDelegate.panelController.backgroundView.optionsView layoutSubtreeIfNeeded];
    [appDelegate.panelController.backgroundView layoutSubtreeIfNeeded];
    
    [NSAnimationContext endGrouping];
    
}
@end
