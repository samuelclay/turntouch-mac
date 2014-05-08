//
//  TTModeNews.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/8/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeNews.h"

@implementation TTModeNews

#pragma mark - Mode

+ (NSString *)title {
    return @"News";
}

+ (NSString *)description {
    return @"Today's headlines";
}

+ (NSString *)imageName {
    return @"newspaper-3.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeNewsNextStory",
             @"TTModeNewsNextSite",
             @"TTModeNewsPreviousStory",
             @"TTModeNewsPreviousSite"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeNewsNextStory {
    return @"Next story";
}
- (NSString *)titleTTModeNewsNextSite {
    return @"Next site";
}
- (NSString *)titleTTModeNewsPreviousStory {
    return @"Previous story";
}
- (NSString *)titleTTModeNewsPreviousSite {
    return @"Previous site";
}

#pragma mark - Action Images

- (NSString *)imageTTModeNewsNextStory {
    return @"next_story.png";
}
- (NSString *)imageTTModeNewsNextSite {
    return @"next_site.png";
}
- (NSString *)imageTTModeNewsPreviousStory {
    return @"previous_story.png";
}
- (NSString *)imageTTModeNewsPreviousSite {
    return @"previous_site.png";
}

#pragma mark - Action methods

- (void)runTTModeNewsNextStory {
    NSLog(@"Running TTModeNewsNextStory");
}
- (void)runTTModeNewsNextSite {
    NSLog(@"Running TTModeNewsNextSite");
}
- (void)runTTModeNewsPreviousStory {
    NSLog(@"Running TTModeNewsPreviousStory");
}
- (void)runTTModeNewsPreviousSite {
    NSLog(@"Running TTModeNewsPreviousSite");
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeNewsNextStory";
}
- (NSString *)defaultEast {
    return @"TTModeNewsNextSite";
}
- (NSString *)defaultWest {
    return @"TTModeNewsPreviousStory";
}
- (NSString *)defaultSouth {
    return @"TTModeNewsPreviousSite";
}

@end
