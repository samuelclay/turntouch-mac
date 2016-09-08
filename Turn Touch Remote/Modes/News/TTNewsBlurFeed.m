//
//  TTNewsBlurFeed.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/16/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTNewsBlurFeed.h"

@implementation TTNewsBlurFeed

@synthesize feedId;
@synthesize feedTitle;
@synthesize faviconFade;
@synthesize faviconColor;
@synthesize faviconBorder;
@synthesize faviconTextColor;

- (instancetype)initWithFeed:(NSDictionary *)feedDict {
    if (self = [super init]) {
        feedTitle = feedDict[@"feed_title"];
        feedId = feedDict[@"feedId"];
        faviconFade = feedDict[@"faviconFade"];
        faviconColor = feedDict[@"faviconColor"];
        faviconBorder = feedDict[@"faviconBorder"];
        faviconTextColor = feedDict[@"faviconTextColor"];
    }
    
    return self;
}
@end
