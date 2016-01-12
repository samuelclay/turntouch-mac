//
//  TTModeWeb.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTModeWeb.h"
#import <WebKit/WebKit.h>

@implementation TTModeWeb

#pragma mark - Mode

+ (NSString *)title {
    return @"Reader";
}

+ (NSString *)description {
    return @"Read the news on your Mac";
}

+ (NSString *)imageName {
    return @"mode_web.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeWebBack",
             @"TTModeWebNext",
             @"TTModeWebScrollUp",
             @"TTModeWebScrollDown",
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeWebBack {
    return @"Menu / Back";
}
- (NSString *)titleTTModeWebNext {
    return @"OK / Next";
}
- (NSString *)titleTTModeWebScrollUp {
    return @"Scroll up";
}
- (NSString *)titleTTModeWebScrollDown {
    return @"Scroll down";
}

#pragma mark - Action Images

- (NSString *)imageTTModeWebBack {
    return @"next_story.png";
}
- (NSString *)imageTTModeWebNext {
    return @"next_site.png";
}
- (NSString *)imageTTModeWebScrollUp {
    return @"previous_story.png";
}
- (NSString *)imageTTModeWebScrollDown {
    return @"previous_site.png";
}

#pragma mark - Action methods

- (void)runTTModeWebBack {
    NSLog(@"Running TTModeWebBack");
    if (state == TTModeWebStateBrowser) {
        state = TTModeWebStateMenu;
        [webWindowController.menuView slideIn];
    } else if (state == TTModeWebStateMenu) {
        state = TTModeWebStateBrowser;
        [webWindowController.menuView slideOut];
    }
}
- (void)runTTModeWebNext {
    NSLog(@"Running TTModeWebNext");
    if (state == TTModeWebStateBrowser) {
        [webWindowController.browserView zoomIn];
    } else if (state == TTModeWebStateMenu) {
//        [webWindowController.menuView menuUp];
    }
}
- (void)runTTModeWebScrollUp {
    NSLog(@"Running TTModeWebScrollUp");
    if (state == TTModeWebStateBrowser) {
        [webWindowController.browserView scrollUp];
    } else if (state == TTModeWebStateMenu) {
        [webWindowController.menuView menuUp];
    }
}
- (void)runTTModeWebScrollDown {
    NSLog(@"Running TTModeWebScrollDown");
    if (state == TTModeWebStateBrowser) {
        [webWindowController.browserView scrollDown];
    } else if (state == TTModeWebStateMenu) {
        [webWindowController.menuView menuDown];
    }
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeWebScrollUp";
}
- (NSString *)defaultEast {
    return @"TTModeWebNext";
}
- (NSString *)defaultWest {
    return @"TTModeWebBack";
}
- (NSString *)defaultSouth {
    return @"TTModeWebScrollDown";
}

#pragma mark - Web

- (void)activate {
    state = TTModeWebStateBrowser;
    
    webWindowController = [[TTModeWebWindowController alloc] initWithWindowNibName:@"TTModeWebWindowController"];
    [webWindowController fadeIn];
    [webWindowController.browserView loadURL:@"https://medium.com/message/is-mars-man-s-midlife-crisis-cab4723c611d"];
    
    [webWindowController.browserView setHidden:YES];
}

- (void)deactivate {
    [webWindowController fadeOut];
}

@end