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

- (instancetype)initWithFeed:(NSDictionary *)feedDict {
    if (self = [super init]) {
        self.feedTitle = feedDict[@"feed_title"];
        self.feedId = feedDict[@"id"];
        self.faviconFade = feedDict[@"favicon_fade"];
        self.faviconColor = feedDict[@"favicon_color"];
        self.faviconBorder = feedDict[@"favicon_border"];
        self.faviconTextColor = feedDict[@"favicon_text_color"];
        self.faviconUrl = [NSString stringWithFormat:@"%@%@", NEWSBLUR_HOST, feedDict[@"favicon_url"]];
    }
    
    return self;
}
@end
