//
//  TTNewsBlurStory.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTNewsBlurFeed.h"

@interface TTNewsBlurStory : NSObject

@property (nonatomic) NSString *storyTitle;
@property (nonatomic) NSString *storyContent;
@property (nonatomic) NSString *originalText;
@property (nonatomic) NSString *feedId;
@property (nonatomic) TTNewsBlurFeed *feed;
@property (nonatomic) NSString *storyAuthor;
@property (nonatomic) NSArray *storyTags;
@property (nonatomic) NSString *storyPermalink;
@property (nonatomic) NSNumber *storyTimestamp;
@property (nonatomic) NSNumber *shareCount;

- (instancetype)initWithStory:(NSDictionary *)storyDict;

@end
