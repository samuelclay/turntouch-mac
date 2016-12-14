//
//  TTModeNewsStoryView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "TTModeNewsBrowserView.h"
#import "TTNewsBlurStory.h"
#import "TTModeNews.h"
#import "TTAppDelegate.h"

@interface TTModeNewsStoryView : NSView  <WebResourceLoadDelegate> {
    WebView *webView;
    TTPairingSpinner *loadingSpinner;
    BOOL inTextView;
}

@property (nonatomic) TTAppDelegate *appDelegate;
@property (nonatomic) IBOutlet WebView *webView;
@property (nonatomic) TTModeNewsBrowserView *browserView;
@property (nonatomic) NSInteger storyIndex;
@property (nonatomic) TTNewsBlurStory *story;
@property (nonatomic, strong) NSString *loadingHTML;
@property (nonatomic, strong) NSURL *loadingURL;
@property (nonatomic) TTModeNews *mode;

- (void)showLoadingView;
- (void)blurStory;
- (void)focusStory;
- (void)adjustSize;
- (void)adjustSize:(CGFloat)width;
- (void)adjustFontSize;

- (void)loadStory;
- (void)scrollUp;
- (void)scrollDown;
- (void)zoomIn;
- (void)zoomOut;

@end
