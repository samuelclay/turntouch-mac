//
//  TTNewsBlurFeed.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/16/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTNewsBlurFeed : NSObject

@property (nonatomic) NSString *feedId;
@property (nonatomic) NSString *feedTitle;
@property (nonatomic) NSString *faviconColor;
@property (nonatomic) NSString *faviconFade;
@property (nonatomic) NSString *faviconBorder;
@property (nonatomic) NSString *faviconTextColor;

- (instancetype)initWithFeed:(NSDictionary *)feedDict;

@end
