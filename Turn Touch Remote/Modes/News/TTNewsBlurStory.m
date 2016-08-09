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

- (instancetype)initWithStory:(NSDictionary *)storyDict {
    if (self = [super init]) {
        storyTitle = storyDict[@"story_title"];
        storyContent = storyDict[@"story_content"];
    }
    
    return self;
}

@end
