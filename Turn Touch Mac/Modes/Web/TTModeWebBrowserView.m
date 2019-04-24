//
//  TTModeWebView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTModeWebBrowserView.h"

@interface TTModeWebBrowserView ()

@property (nonatomic) CGFloat zoomFactor;
@property (nonatomic) NSInteger textSize;

@end

@implementation TTModeWebBrowserView

- (void)awakeFromNib {
    self.appDelegate = (TTAppDelegate *)[NSApp delegate];

    [self.webView setResourceLoadDelegate:self];
    self.zoomFactor  = 2.3f;
    self.textSize = 0;
    
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    [self.widthConstraint setConstant:NSWidth(mainScreen.frame) * 0.85];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

#pragma mark - Loading URLs

- (void)loadURL:(NSString *)urlString {
    [self.webView setMainFrameURL:urlString];
}

- (void)loadURL:(NSString *)urlString html:(NSString *)htmlSource title:(NSString *)title {
    NSLog(@"Loading: %@", title);
    [[self.webView mainFrame] loadHTMLString:htmlSource baseURL:[NSURL URLWithString:urlString]];
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", self.zoomFactor]];
}

#pragma mark - Interacting with webView

- (NSInteger)currentScroll {
    return [[self.webView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
}

- (NSInteger)scrollAmount {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    return NSHeight(mainScreen.frame) / 3;
}

- (void)scrollUp {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$TT('body').stop().animate({scrollTop:%ld}, 150, 'swing')", self.currentScroll - self.scrollAmount]];
}

- (void)scrollDown {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$TT('body').stop().animate({scrollTop:%ld}, 200, 'swing')", self.currentScroll + self.scrollAmount]];
}

- (void)adjustTextSizeUp {
    if ([self.webView canMakeTextLarger]) {
        [self.webView makeTextLarger:nil];
        self.textSize += 1;
        NSLog(@" ---> Text size: %ld", (long)self.textSize);
    }
}

- (void)adjustTextSizeDown {
    if ([self.webView canMakeTextSmaller]) {
        [self.webView makeTextSmaller:nil];
        self.textSize -= 1;
        NSLog(@" ---> Text size: %ld", (long)self.textSize);
    }
}

- (void)zoomIn {
    self.zoomFactor += 0.05;
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", self.zoomFactor]];
    NSLog(@" ---> Zoom factor: %f", self.zoomFactor);
}

- (void)zoomOut {
    self.zoomFactor -= 0.05;
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", self.zoomFactor]];
    NSLog(@" ---> Zoom factor: %f", self.zoomFactor);
}

- (void)widenMargin {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.26f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.widthConstraint animator] setConstant:self.widthConstraint.constant+125];
    [NSAnimationContext endGrouping];
}

- (void)narrowMargin {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.26f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.widthConstraint animator] setConstant:self.widthConstraint.constant-125];
    [NSAnimationContext endGrouping];
}

@end
