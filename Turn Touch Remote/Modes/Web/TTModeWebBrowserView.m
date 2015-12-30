//
//  TTModeWebView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTModeWebBrowserView.h"

@implementation TTModeWebBrowserView

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    self.autoresizesSubviews = YES;
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
//    CGFloat alpha = 0.5f;
//    [NSColorFromRGBAlpha(0x50fbd6, alpha) set];
//    NSRectFill(self.bounds);
}

@end
