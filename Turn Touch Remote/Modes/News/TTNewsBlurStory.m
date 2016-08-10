//
//  TTNewsBlurStory.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTNewsBlurStory.h"

@implementation TTNewsBlurStory

@synthesize storyTitle;
@synthesize storyContent;
@synthesize originalText;
@synthesize feedId;
@synthesize storyAuthor;
@synthesize storyTags;
@synthesize storyPermalink;
@synthesize storyTimestamp;

- (instancetype)initWithStory:(NSDictionary *)storyDict {
    if (self = [super init]) {
        storyTitle = storyDict[@"story_title"];
        storyContent = storyDict[@"story_content"];
        feedId = storyDict[@"story_feed_id"];
        storyAuthor = storyDict[@"story_authors"];
        storyTags = storyDict[@"story_tags"];
        storyPermalink = storyDict[@"story_permalink"];
        storyTimestamp = storyDict[@"story_timestamp"];
    }
    
    return self;
}

@end
