//
//  TTNewsBlurFeed.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/16/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTNewsBlurFeed.h"
#import "TTModeNewsNewsBlur.h"

@implementation TTNewsBlurFeed

@synthesize feedId;
@synthesize feedTitle;
@synthesize faviconFade;
@synthesize faviconColor;
@synthesize faviconBorder;
@synthesize faviconTextColor;
@synthesize faviconUrl;

- (instancetype)initWithFeed:(NSDictionary *)feedDict {
    if (self = [super init]) {
        feedTitle = feedDict[@"feed_title"];
        feedId = feedDict[@"id"];
        faviconFade = feedDict[@"favicon_fade"];
        faviconColor = feedDict[@"favicon_color"];
        faviconBorder = feedDict[@"favicon_border"];
        faviconTextColor = feedDict[@"favicon_text_color"];
        faviconUrl = [NSString stringWithFormat:@"%@%@", NEWSBLUR_HOST, feedDict[@"favicon_url"]];
    }
    
    return self;
}
@end
