//
//  TTModeWebView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTModeWebBrowserView.h"

@implementation TTModeWebBrowserView

@synthesize widthConstraint;
@synthesize webView;

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];

    [webView setResourceLoadDelegate:self];
    zoomFactor  = 2.3f;
    textSize = 0;
    
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    [widthConstraint setConstant:NSWidth(mainScreen.frame) * 0.85];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

#pragma mark - Loading URLs

- (void)loadURL:(NSString *)urlString {
    [webView setMainFrameURL:urlString];
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", zoomFactor]];
    
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

- (void)adjustTextSizeUp {
    if ([webView canMakeTextLarger]) {
        [webView makeTextLarger:nil];
        textSize += 1;
        NSLog(@" ---> Text size: %ld", (long)textSize);
    }
}

- (void)adjustTextSizeDown {
    if ([webView canMakeTextSmaller]) {
        [webView makeTextSmaller:nil];
        textSize -= 1;
        NSLog(@" ---> Text size: %ld", (long)textSize);
    }
}

- (void)zoomIn {
    zoomFactor += 0.05;
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", zoomFactor]];
    NSLog(@" ---> Zoom factor: %f", zoomFactor);
}

- (void)zoomOut {
    zoomFactor -= 0.05;
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", zoomFactor]];
    NSLog(@" ---> Zoom factor: %f", zoomFactor);
}

@end
