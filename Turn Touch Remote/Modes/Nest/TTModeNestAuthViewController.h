//
//  TTModeNestAuthViewController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/18/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "TTAppDelegate.h"

@interface TTModeNestAuthViewController : NSViewController <WebResourceLoadDelegate> {
    TTAppDelegate *appDelegate;
    NSTimer *checkTokenTimer;
}

@property (nonatomic) IBOutlet WebView *webView;

@end
