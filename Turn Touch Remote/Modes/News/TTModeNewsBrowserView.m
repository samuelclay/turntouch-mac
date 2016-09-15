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
#import "TTNewsBlurFeed.h"

@implementation TTModeNewsBrowserView

@synthesize stackOffsetConstraint;
@synthesize storyStack;
@synthesize zoomFactor;
@synthesize textSize;
@synthesize currentStoryIndex;
@synthesize storyCount;
@synthesize storyViews;
@synthesize storyWidth;
@synthesize feeds;

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];

    zoomFactor = 2.3f;
    textSize = [[appDelegate.modeMap modeOptionValue:@"fontSize"] integerValue];
    storyWidth = [[appDelegate.modeMap modeOptionValue:@"browserWidth"] integerValue];
    if (storyWidth <= 100) {
        NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
        storyWidth = NSWidth(mainScreen.frame) / 2.5f;
    }
    page = 0;
    currentStoryIndex = 0;
    
    storyViews = [NSMutableArray array];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    storyStack.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self showLoadingStories];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)showLoadingStories {
    TTModeNewsStoryView *storyView = [[TTModeNewsStoryView alloc] init];
    [storyViews addObject:storyView];
    storyView.storyIndex = 0;
    storyCount = 1;
    [storyStack addArrangedSubview:storyView];
    [storyStack addConstraint:[NSLayoutConstraint constraintWithItem:storyView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:storyWidth]];
    [storyView showLoadingView];

    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:1];
    
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CGFloat offset = NSWidth(mainScreen.frame)/2 - currentStoryIndex*(storyWidth+64) - storyWidth/2;
    [stackOffsetConstraint animator].constant = offset;
    [NSAnimationContext endGrouping];
}

- (void)addFeeds:(NSArray *)newFeeds {
    if (!feeds) feeds = [NSMutableDictionary dictionary];
    
    for (NSDictionary *feedDict in newFeeds) {
        TTNewsBlurFeed *feed = [[TTNewsBlurFeed alloc] initWithFeed:feedDict];
        [feeds setObject:feed forKey:feed.feedId];
    }
}

- (void)addStories:(NSArray *)stories {
    if (page == 0) {
        for (NSView *view in storyStack.arrangedSubviews) {
            [storyStack removeArrangedSubview:view];
        }
        storyCount = 0;
        [storyStack removeConstraints:storyStack.constraints];
        storyViews = [NSMutableArray array];
    }
    
    page += 1;
    
    for (int i=0; i < stories.count; i++) {
        TTNewsBlurStory *story = [[TTNewsBlurStory alloc] initWithStory:[stories objectAtIndex:i]];
        story.feed = [feeds objectForKey:story.feedId];
        TTModeNewsStoryView *storyView = [[TTModeNewsStoryView alloc] initWithFrame:NSMakeRect(0, 0, storyWidth, NSHeight(self.frame))];
        [storyViews addObject:storyView];
        storyView.storyIndex = i;
        storyView.story = story;
        storyCount += 1;
        [storyStack addArrangedSubview:storyView];
        [storyStack addConstraint:[NSLayoutConstraint constraintWithItem:storyView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:storyWidth]];
        [storyView loadStory];
    }
    
//    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
//    stackOffsetConstraint.constant = NSWidth(mainScreen.frame)/2 - currentStoryIndex*(storyWidth+64) - storyWidth/2;
    
    TTModeNewsStoryView *activeStory = [storyViews objectAtIndex:currentStoryIndex];
    [activeStory focusStory];
}

#pragma mark - Interacting with webView

- (void)nextStory {
    [self changeStory:1];
}

- (void)previousStory {
    [self changeStory:-1];
}

- (void)changeStory:(NSInteger)diff {
    if (currentStoryIndex + diff < 0) return;
    if (currentStoryIndex + diff >= storyViews.count) return;
    currentStoryIndex += diff;
    
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    CGFloat openDuration = 0.65f;// * 4;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CGFloat offset = NSWidth(mainScreen.frame)/2 - currentStoryIndex*(storyWidth+64) - storyWidth/2;
    [stackOffsetConstraint animator].constant = offset;
    
    [NSAnimationContext endGrouping];
    NSLog(@"> stackOffsetConstraint: %f/%f", stackOffsetConstraint.constant, offset);
    
    [self setNeedsUpdateConstraints:YES];
    
    if (currentStoryIndex-diff >= 0 && storyViews.count > 1) {
        TTModeNewsStoryView *oldStory = [storyViews objectAtIndex:currentStoryIndex-diff];
        [oldStory blurStory];
    }
    if (currentStoryIndex >= 0 && storyViews.count > 1) {
        TTModeNewsStoryView *activeStory = [storyViews objectAtIndex:currentStoryIndex];
        [activeStory focusStory];
    }
}

- (void)zoomIn {
    zoomFactor += 0.05;
    
    NSLog(@" ---> Zoom factor: %f", zoomFactor);
}

- (void)zoomOut {
    zoomFactor -= 0.05;

    NSLog(@" ---> Zoom factor: %f", zoomFactor);
}

- (void)increaseFontSize {
    NSInteger fontSize = [[appDelegate.modeMap modeOptionValue:@"fontSize"] integerValue];
    [appDelegate.modeMap changeModeOption:@"fontSize" to:[NSNumber numberWithInteger:MIN(4, fontSize+1)]];
    
    for (TTModeNewsStoryView *storyView in storyViews) {
        [storyView adjustFontSize];
    }
}

- (void)decreaseFontSize {
    NSInteger fontSize = [[appDelegate.modeMap modeOptionValue:@"fontSize"] integerValue];
    [appDelegate.modeMap changeModeOption:@"fontSize" to:[NSNumber numberWithInteger:MAX(0, fontSize-1)]];
    
    for (TTModeNewsStoryView *storyView in storyViews) {
        [storyView adjustFontSize];
    }
}

- (void)widenStory {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.26f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    storyWidth += 125;
//    [self changeStory:0];
    CGFloat offset = NSWidth(mainScreen.frame)/2 - currentStoryIndex*(storyWidth+64) - storyWidth/2;
    [stackOffsetConstraint animator].constant = offset;
    for (NSLayoutConstraint *constraint in storyStack.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            [constraint animator].constant = storyWidth;
        }
    }
//    [[widthConstraint animator] setConstant:widthConstraint.constant+125];
    [NSAnimationContext endGrouping];
    
    for (TTModeNewsStoryView *storyView in storyViews) {
        [storyView adjustSize:storyWidth];
    }
    
    [appDelegate.modeMap changeModeOption:@"browserWidth" to:[NSNumber numberWithInteger:storyWidth]];
}

- (void)narrowStory {
    if (storyWidth <= 400) return;
    
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.26f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    storyWidth -= 125;
//    [self changeStory:0];
    CGFloat offset = NSWidth(mainScreen.frame)/2 - currentStoryIndex*(storyWidth+64) - storyWidth/2;
    [stackOffsetConstraint animator].constant = offset;
    for (NSLayoutConstraint *constraint in storyStack.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            [constraint animator].constant = storyWidth;
        }
    }
//    [[widthConstraint animator] setConstant:widthConstraint.constant-125];
    [NSAnimationContext endGrouping];

    for (TTModeNewsStoryView *storyView in storyViews) {
        [storyView adjustSize:storyWidth];
    }
    
    [appDelegate.modeMap changeModeOption:@"browserWidth" to:[NSNumber numberWithInteger:storyWidth]];
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
