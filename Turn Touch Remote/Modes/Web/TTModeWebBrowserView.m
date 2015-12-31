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
    
    
//    CGFloat alpha = 0.5f;
//    [NSColorFromRGBAlpha(0x50fbd6, alpha) set];
//    NSRectFill(self.bounds);
}

#pragma mark - Loading URLs

- (void)loadURL:(NSString *)urlString {
    [webView setMainFrameURL:@"https://medium.com/message/is-mars-man-s-midlife-crisis-cab4723c611d"];
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", zoomFactor]];
}

#pragma mark - Interacting with webView

- (void)scrollUp {
    [webView scrollPageUp:nil];
}

- (void)scrollDown {
    [webView scrollPageDown:nil];
}

- (void)adjustTextSizeUp {
    if ([webView canMakeTextLarger]) {
        [webView makeTextLarger:nil];
        textSize += 1;
        NSLog(@" ---> Text size: %d", textSize);
    }
}

- (void)adjustTextSizeDown {
    if ([webView canMakeTextSmaller]) {
        [webView makeTextSmaller:nil];
        textSize -= 1;
        NSLog(@" ---> Text size: %d", textSize);
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
