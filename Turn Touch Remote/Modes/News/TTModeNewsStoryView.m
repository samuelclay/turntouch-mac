//
//  TTModeNewsStoryView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNewsStoryView.h"

@implementation TTModeNewsStoryView

@synthesize browserView;
@synthesize webView;
@synthesize storyIndex;

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        webView = [[WebView alloc] init];
        webView.translatesAutoresizingMaskIntoConstraints = NO;
        [webView setResourceLoadDelegate:self];
        [self addSubview:webView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1. constant:0]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

}


#pragma mark - Loading URLs

- (void)loadStory {
    [[webView mainFrame] loadHTMLString:[NSString stringWithFormat:@"%ld", (long)storyIndex] baseURL:[NSURL URLWithString:@"http://mac.turntouch.com"]];
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
