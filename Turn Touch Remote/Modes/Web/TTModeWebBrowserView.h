//
//  TTModeWebView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "TTAppDelegate.h"

@interface TTModeWebBrowserView : NSView <WebResourceLoadDelegate> {
    TTAppDelegate *appDelegate;
    WebView *webView;
    CGFloat zoomFactor;
    NSInteger textSize;
}

@property (nonatomic) IBOutlet WebView *webView;
@property (nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

- (void)loadURL:(NSString *)urlString;
- (void)scrollUp;
- (void)scrollDown;
- (void)adjustTextSizeUp;
- (void)adjustTextSizeDown;
- (void)zoomIn;
- (void)zoomOut;

@end
