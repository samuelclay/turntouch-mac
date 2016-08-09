//
//  TTModeNewsBrowserView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNewsBrowserView.h"
#import <QuartzCore/QuartzCore.h>
#import "TTModeNewsStoryView.h"

@implementation TTModeNewsBrowserView

@synthesize stackOffsetConstraint;
@synthesize storyStack;
@synthesize zoomFactor;
@synthesize textSize;
@synthesize currentStoryIndex;
@synthesize storyCount;
@synthesize storyViews;
@synthesize storyWidth;

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    
    zoomFactor = 2.3f;
    textSize = 0;
    storyWidth = 800;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    storyStack.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self assembleStoryViews];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)assembleStoryViews {
    for (int i=0; i < 12; i++) {
        TTModeNewsStoryView *storyView = [[TTModeNewsStoryView alloc] init];
        [storyViews addObject:storyView];
        storyView.storyIndex = i;
        storyCount += 1;
        [storyStack addArrangedSubview:storyView];
        [storyStack addConstraint:[NSLayoutConstraint constraintWithItem:storyView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:storyWidth]];
        [storyView loadStory];
    }
    
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    stackOffsetConstraint.constant = NSWidth(mainScreen.frame)/2 - currentStoryIndex*(storyWidth+64) - storyWidth/2;
}

#pragma mark - Interacting with webView

- (void)nextStory {
    currentStoryIndex += 1;
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    CGFloat openDuration = 0.65f;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [stackOffsetConstraint animator].constant = NSWidth(mainScreen.frame)/2 - currentStoryIndex*(storyWidth+64) - storyWidth/2;
    
    [NSAnimationContext endGrouping];
}

- (void)previousStory {
    
}

- (void)zoomIn {
    zoomFactor += 0.05;
    
    NSLog(@" ---> Zoom factor: %f", zoomFactor);
}

- (void)zoomOut {
    zoomFactor -= 0.05;

    NSLog(@" ---> Zoom factor: %f", zoomFactor);
}

- (void)widenMargin {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.26f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    storyWidth += 125;
//    [[widthConstraint animator] setConstant:widthConstraint.constant+125];
    [NSAnimationContext endGrouping];
}

- (void)narrowMargin {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.26f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    storyWidth -= 125;
//    [[widthConstraint animator] setConstant:widthConstraint.constant-125];
    [NSAnimationContext endGrouping];
}

- (void)scrollUp {
    TTModeNewsStoryView *activeStoryView = [storyViews objectAtIndex:currentStoryIndex];
    [activeStoryView scrollUp];
}

- (void)scrollDown {
    TTModeNewsStoryView *activeStoryView = [storyViews objectAtIndex:currentStoryIndex];
    [activeStoryView scrollDown];
}

@end
