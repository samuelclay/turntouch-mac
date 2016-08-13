//
//  TTModeNewsBrowserView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTModeNewsBrowserView : NSView {
    TTAppDelegate *appDelegate;
    NSStackView *storyStack;
    CGFloat zoomFactor;
    NSInteger textSize;
    NSInteger page;
}

@property (nonatomic) IBOutlet NSStackView *storyStack;
@property (nonatomic) IBOutlet NSLayoutConstraint *stackOffsetConstraint;
@property (nonatomic) CGFloat zoomFactor;
@property (nonatomic) NSInteger textSize;
@property (nonatomic) NSInteger currentStoryIndex;
@property (nonatomic) NSInteger storyCount;
@property (nonatomic) NSInteger storyWidth;
@property (nonatomic) NSMutableArray *storyViews;

- (void)addStories:(NSArray *)stories;
- (void)nextStory;
- (void)previousStory;
- (void)scrollUp;
- (void)scrollDown;
- (void)zoomIn;
- (void)zoomOut;
- (void)widenStory;
- (void)narrowStory;

@end
