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

@interface TTModeNewsBrowserView ()

@property (nonatomic) NSInteger page;

@end

@implementation TTModeNewsBrowserView

- (void)awakeFromNib {
    self.appDelegate = (TTAppDelegate *)[NSApp delegate];

    self.zoomFactor = 2.3f;
    self.textSize = [[self.appDelegate.modeMap modeOptionValue:@"fontSize"] integerValue];
    self.storyWidth = [[self.appDelegate.modeMap modeOptionValue:@"browserWidth"] integerValue];
    if (self.storyWidth <= 100) {
        NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
        self.storyWidth = NSWidth(mainScreen.frame) / 2.5f;
    }
    self.page = 0;
    self.currentStoryIndex = 0;
    
    self.storyViews = [NSMutableArray array];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.storyStack.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self showLoadingStories];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)showLoadingStories {
    TTModeNewsStoryView *storyView = [[TTModeNewsStoryView alloc] init];
    [self.storyViews addObject:storyView];
    storyView.storyIndex = 0;
    self.storyCount = 1;
    [self.storyStack addView:storyView inGravity:NSStackViewGravityLeading];
    [self.storyStack addConstraint:[NSLayoutConstraint constraintWithItem:storyView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:self.storyWidth]];
    [storyView showLoadingView];

    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:1];
    
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CGFloat offset = NSWidth(mainScreen.frame)/2 - self.currentStoryIndex*(self.storyWidth+64) - self.storyWidth/2;
    [self.stackOffsetConstraint animator].constant = offset;
    [NSAnimationContext endGrouping];
}

- (void)addFeeds:(NSArray *)newFeeds {
    if (!self.feeds) self.feeds = [NSMutableDictionary dictionary];
    
    for (NSDictionary *feedDict in newFeeds) {
        TTNewsBlurFeed *feed = [[TTNewsBlurFeed alloc] initWithFeed:feedDict];
        [self.feeds setObject:feed forKey:feed.feedId];
    }
}

- (void)addStories:(NSArray *)stories {
    if (self.page == 0) {
        for (NSView *view in [self.storyStack viewsInGravity:NSStackViewGravityLeading]) {
            [self.storyStack removeView:view];
        }
        self.storyCount = 0;
        [self.storyStack removeConstraints:self.storyStack.constraints];
        self.storyViews = [NSMutableArray array];
    }
    
    self.page += 1;
    
    for (int i=0; i < stories.count; i++) {
        TTNewsBlurStory *story = [[TTNewsBlurStory alloc] initWithStory:[stories objectAtIndex:i]];
        story.feed = [self.feeds objectForKey:story.feedId];
        TTModeNewsStoryView *storyView = [[TTModeNewsStoryView alloc] initWithFrame:NSMakeRect(0, 0, self.storyWidth, NSHeight(self.frame))];
        [self.storyViews addObject:storyView];
        storyView.storyIndex = i;
        storyView.story = story;
        self.storyCount += 1;
        [self.storyStack addView:storyView inGravity:NSStackViewGravityLeading];
        [self.storyStack addConstraint:[NSLayoutConstraint constraintWithItem:storyView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:self.storyWidth]];
        [storyView loadStory];
    }
    
//    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
//    stackOffsetConstraint.constant = NSWidth(mainScreen.frame)/2 - currentStoryIndex*(storyWidth+64) - storyWidth/2;
    
    TTModeNewsStoryView *activeStory = [self.storyViews objectAtIndex:self.currentStoryIndex];
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
    if (self.currentStoryIndex + diff < 0) return;
    if (self.currentStoryIndex + diff >= self.storyViews.count) return;
    self.currentStoryIndex += diff;
    
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    CGFloat openDuration = 0.65f;// * 5;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CGFloat offset = NSWidth(mainScreen.frame)/2 - self.currentStoryIndex*(self.storyWidth+64) - self.storyWidth/2;
    [self.stackOffsetConstraint animator].constant = offset;
    
    [NSAnimationContext endGrouping];
    NSLog(@"> stackOffsetConstraint: %f/%f", self.stackOffsetConstraint.constant, offset);
    
    [self setNeedsUpdateConstraints:YES];
    
    if (self.currentStoryIndex-diff >= 0 && self.storyViews.count > 1) {
        TTModeNewsStoryView *oldStory = [self.storyViews objectAtIndex:self.currentStoryIndex-diff];
        [oldStory blurStory];
    }
    if (self.currentStoryIndex >= 0 && self.storyViews.count > 1) {
        TTModeNewsStoryView *activeStory = [self.storyViews objectAtIndex:self.currentStoryIndex];
        [activeStory focusStory];
    }
}

- (void)zoomIn {
    self.zoomFactor += 0.05;
    
    NSLog(@" ---> Zoom factor: %f", self.zoomFactor);
}

- (void)zoomOut {
    self.zoomFactor -= 0.05;

    NSLog(@" ---> Zoom factor: %f", self.zoomFactor);
}

- (void)increaseFontSize {
    NSInteger fontSize = [[self.appDelegate.modeMap modeOptionValue:@"fontSize"] integerValue];
    [self.appDelegate.modeMap changeModeOption:@"fontSize" to:[NSNumber numberWithInteger:MIN(4, fontSize+1)]];
    
    for (TTModeNewsStoryView *storyView in self.storyViews) {
        [storyView adjustFontSize];
    }
}

- (void)decreaseFontSize {
    NSInteger fontSize = [[self.appDelegate.modeMap modeOptionValue:@"fontSize"] integerValue];
    [self.appDelegate.modeMap changeModeOption:@"fontSize" to:[NSNumber numberWithInteger:MAX(0, fontSize-1)]];
    
    for (TTModeNewsStoryView *storyView in self.storyViews) {
        [storyView adjustFontSize];
    }
}

- (void)widenStory {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.26f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    self.storyWidth += 125;
//    [self changeStory:0];
    CGFloat offset = NSWidth(mainScreen.frame)/2 - self.currentStoryIndex*(self.storyWidth+64) - self.storyWidth/2;
    [self.stackOffsetConstraint animator].constant = offset;
    for (NSLayoutConstraint *constraint in self.storyStack.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            [constraint animator].constant = self.storyWidth;
        }
    }
//    [[widthConstraint animator] setConstant:widthConstraint.constant+125];
    [NSAnimationContext endGrouping];
    
    for (TTModeNewsStoryView *storyView in self.storyViews) {
        [storyView adjustSize:self.storyWidth];
    }
    
    [self.appDelegate.modeMap changeModeOption:@"browserWidth" to:[NSNumber numberWithInteger:self.storyWidth]];
}

- (void)narrowStory {
    if (self.storyWidth <= 400) return;
    
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.26f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    self.storyWidth -= 125;
//    [self changeStory:0];
    CGFloat offset = NSWidth(mainScreen.frame)/2 - self.currentStoryIndex*(self.storyWidth+64) - self.storyWidth/2;
    [self.stackOffsetConstraint animator].constant = offset;
    for (NSLayoutConstraint *constraint in self.storyStack.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            [constraint animator].constant = self.storyWidth;
        }
    }
//    [[widthConstraint animator] setConstant:widthConstraint.constant-125];
    [NSAnimationContext endGrouping];

    for (TTModeNewsStoryView *storyView in self.storyViews) {
        [storyView adjustSize:self.storyWidth];
    }
    
    [self.appDelegate.modeMap changeModeOption:@"browserWidth" to:[NSNumber numberWithInteger:self.storyWidth]];
}

- (void)scrollUp {
    TTModeNewsStoryView *activeStoryView = [self.storyViews objectAtIndex:self.currentStoryIndex];
    [activeStoryView scrollUp];
}

- (void)scrollDown {
    TTModeNewsStoryView *activeStoryView = [self.storyViews objectAtIndex:self.currentStoryIndex];
    [activeStoryView scrollDown];
}

@end
