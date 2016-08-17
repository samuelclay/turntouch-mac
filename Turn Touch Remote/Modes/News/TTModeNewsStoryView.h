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

@interface TTModeNewsStoryView : NSView  <WebResourceLoadDelegate> {
    WebView *webView;
    TTPairingSpinner *loadingSpinner;
    BOOL inTextView;
}

@property (nonatomic) IBOutlet WebView *webView;
@property (nonatomic) TTModeNewsBrowserView *browserView;
@property (nonatomic) NSInteger storyIndex;
@property (nonatomic) TTNewsBlurStory *story;
@property (nonatomic, strong) NSString *loadingHTML;
@property (nonatomic, strong) NSURL *loadingURL;

- (void)showLoadingView;
- (void)blurStory;
- (void)focusStory;
- (void)adjustSize;
- (void)adjustSize:(CGFloat)width;

- (void)loadStory;
- (void)scrollUp;
- (void)scrollDown;
- (void)zoomIn;
- (void)zoomOut;

@end
