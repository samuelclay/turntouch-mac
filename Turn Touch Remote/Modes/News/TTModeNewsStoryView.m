//
//  TTModeNewsStoryView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTModeNewsStoryView.h"

@implementation TTModeNewsStoryView

@synthesize browserView;
@synthesize webView;
@synthesize storyIndex;
@synthesize story;

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        self.wantsLayer = YES;
        self.layer.backgroundColor = CGColorCreateGenericRGB(0, 0, 0, 0.1);
        
        webView = [[WebView alloc] init];
        webView.translatesAutoresizingMaskIntoConstraints = NO;
        webView.resourceLoadDelegate = self;
        webView.drawsBackground = NO;
        [self addSubview:webView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1. constant:0]];

        loadingSpinner = [[TTPairingSpinner alloc] init];
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:loadingSpinner];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:loadingSpinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1. constant:-64]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:loadingSpinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:loadingSpinner attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:64]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:loadingSpinner attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:64]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

}

- (void)showLoadingView {
    loadingSpinner.hidden = NO;
}

- (void)blurStory {
    NSLog(@"Blurring: %@", story.storyTitle);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    animation.fromValue = (id)self.layer.backgroundColor;
    animation.toValue = [CIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    animation.duration = 0.5f;
    [self.layer addAnimation:animation forKey:@"backgroundColor"];
    self.layer.backgroundColor = CGColorCreateGenericRGB(0, 0, 0, 0.1);

}

- (void)focusStory {
    NSLog(@"Focusing: %@", story.storyTitle);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    animation.fromValue = (id)self.layer.backgroundColor;
    animation.toValue = [CIColor colorWithRed:1 green:1 blue:1 alpha:1];
    animation.duration = 0.65f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:@"backgroundColor"];
    self.layer.backgroundColor = CGColorCreateGenericRGB(1, 1, 1, 1);
}

#pragma mark - Loading URLs

- (void)loadStory {
    loadingSpinner.hidden = YES;
    [[webView mainFrame] loadHTMLString:[NSString stringWithFormat:@"%@", story.storyTitle] baseURL:[NSURL URLWithString:@"http://mac.turntouch.com"]];
}
- (void)loadURL:(NSString *)urlString html:(NSString *)htmlSource title:(NSString *)title {
    NSLog(@"Loading: %@", title);
    [[webView mainFrame] loadHTMLString:htmlSource baseURL:[NSURL URLWithString:urlString]];
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", browserView.zoomFactor]];
    
    for (NSString *scriptName in @[@"jquery-2.0.3.js"]) {
        NSString *jQueryFile = [NSString stringWithFormat:@"%@/scripts/%@", [[NSBundle mainBundle] resourcePath], scriptName];
        NSString *jQuery = [NSString stringWithContentsOfFile:jQueryFile encoding:NSUTF8StringEncoding error:nil];
        [webView stringByEvaluatingJavaScriptFromString:jQuery];
    }
    
    [webView stringByEvaluatingJavaScriptFromString:@"window.$TT = jQuery = jQuery.noConflict(true);"];
}

#pragma mark - Interacting with webView

- (NSInteger)currentScroll {
    return [[webView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
}

- (NSInteger)scrollAmount {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    return NSHeight(mainScreen.frame) / 3;
}

- (void)scrollUp {
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$TT('body').stop().animate({scrollTop:%ld}, 150, 'swing')", self.currentScroll - self.scrollAmount]];
}

- (void)scrollDown {
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$TT('body').stop().animate({scrollTop:%ld}, 200, 'swing')", self.currentScroll + self.scrollAmount]];
}

- (void)zoomIn {
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", browserView.zoomFactor]];
}

- (void)zoomOut {
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", browserView.zoomFactor]];
}

@end
