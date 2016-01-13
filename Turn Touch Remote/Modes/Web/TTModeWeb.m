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

- (NSArray *)menuOptions {
    return @[@{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeWebMenuReturn",
               @"title"      : @"Return",
               @"icon"       : @"double_tap",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeWebMenuNextStory",
               @"title"      : @"Next story",
               @"icon"       : @"heart",
               },
             @{@"identifier" : @"TTModeWebMenuPreviousStory",
               @"title"      : @"Previous story",
               @"icon"       : @"cog",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeWebMenuFontSizeUp",
               @"title"      : @"Larger text",
               @"icon"       : @"button_chevron",
               },
             @{@"identifier" : @"TTModeWebMenuFontSizeDown",
               @"title"      : @"Smaller text",
               @"icon"       : @"button_dash",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeWebMenuMarginWider",
               @"title"      : @"Widen margin",
               @"icon"       : @"arrow",
               },
             @{@"identifier" : @"TTModeWebMenuMarginNarrower",
               @"title"      : @"Narrow margin",
               @"icon"       : @"arrow",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeWebMenuClose",
               @"title"      : @"Close Reader",
               @"icon"       : @"button_x",
               },
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

- (BOOL)checkClosed {
    if (closed) {
        closed = NO;
        [webWindowController fadeIn];

        return YES;
    }
    
    return NO;
}

- (void)runTTModeWebBack {
    if ([self checkClosed]) return;
    
    if (state == TTModeWebStateBrowser) {
        state = TTModeWebStateMenu;
        [webWindowController.menuView slideIn];
    } else if (state == TTModeWebStateMenu) {
        state = TTModeWebStateBrowser;
        [webWindowController.menuView slideOut];
    }
}
- (void)runTTModeWebNext {
    if ([self checkClosed]) return;
    
    if (state == TTModeWebStateBrowser) {

    } else if (state == TTModeWebStateMenu) {
        [webWindowController.menuView selectMenuItem];
    }
}
- (void)runTTModeWebScrollUp {
    if ([self checkClosed]) return;
    
    if (state == TTModeWebStateBrowser) {
        [webWindowController.browserView scrollUp];
    } else if (state == TTModeWebStateMenu) {
        [webWindowController.menuView menuUp];
    }
}
- (void)runTTModeWebScrollDown {
    if ([self checkClosed]) return;
    
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
}

- (void)deactivate {
    [webWindowController fadeOut];
}

#pragma mark - Menu Options

- (void)menuTTModeWebMenuReturn {
    state = TTModeWebStateBrowser;
    [webWindowController.menuView slideOut];
}

- (void)menuTTModeWebMenuNextStory {
    
}

- (void)menuTTModeWebMenuPreviousStory {
    
}

- (void)menuTTModeWebMenuFontSizeUp {
    [webWindowController.browserView zoomIn];
}

- (void)menuTTModeWebMenuFontSizeDown {
    [webWindowController.browserView zoomOut];
}

- (void)menuTTModeWebMenuMarginWider {
    
}

- (void)menuTTModeWebMenuMarginNarrower {
    
}

- (void)menuTTModeWebMenuClose {
    if (!closed) {
        closed = YES;
        [webWindowController fadeOut];
        state = TTModeWebStateBrowser;
        [webWindowController.menuView slideOut];
    }
}

@end
