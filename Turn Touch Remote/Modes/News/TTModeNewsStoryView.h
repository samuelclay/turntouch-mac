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

@interface TTModeNewsStoryView : NSView  <WebResourceLoadDelegate> {
    WebView *webView;
}

@property (nonatomic) IBOutlet WebView *webView;
@property (nonatomic) TTModeNewsBrowserView *browserView;
@property (nonatomic) NSInteger storyIndex;

- (void)loadStory;
- (void)scrollUp;
- (void)scrollDown;
- (void)zoomIn;
- (void)zoomOut;

@end
