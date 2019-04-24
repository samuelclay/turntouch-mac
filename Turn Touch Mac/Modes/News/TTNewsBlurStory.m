//
//  TTNewsBlurStory.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTNewsBlurStory.h"

@implementation TTNewsBlurStory

- (instancetype)initWithStory:(NSDictionary *)storyDict {
    if (self = [super init]) {
        self.storyTitle = storyDict[@"story_title"];
        self.storyContent = storyDict[@"story_content"];
        self.feedId = storyDict[@"story_feed_id"];
        self.storyAuthor = storyDict[@"story_authors"];
        self.storyTags = storyDict[@"story_tags"];
        self.storyPermalink = storyDict[@"story_permalink"];
        self.storyTimestamp = storyDict[@"story_timestamp"];
    }
    
    return self;
}

@end
