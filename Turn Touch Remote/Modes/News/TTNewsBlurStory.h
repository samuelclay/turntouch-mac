//
//  TTNewsBlurStory.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTNewsBlurStory : NSObject

@property (nonatomic) NSString *storyTitle;
@property (nonatomic) NSString *storyContent;

- (instancetype)initWithStory:(NSDictionary *)storyDict;

@end
