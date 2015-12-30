//
//  TTModeWeb.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTModeWeb.h"

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
}
- (void)runTTModeWebNext {
    NSLog(@"Running TTModeWebNext");
}
- (void)runTTModeWebScrollUp {
    NSLog(@"Running TTModeWebScrollUp");
}
- (void)runTTModeWebScrollDown {
    NSLog(@"Running TTModeWebScrollDown");
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
    webWindowController = [[TTModeWebWindowController alloc] initWithWindowNibName:@"TTModeWebWindowController"];
    [webWindowController fadeIn];
}

- (void)deactivate {
    [webWindowController fadeOut];
}

@end
