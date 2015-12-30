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

@interface TTModeWebBrowserView : NSView {
    TTAppDelegate *appDelegate;
    WebView *webView;
}

@property (nonatomic) IBOutlet WebView *webView;

@end
