//
//  TTNewsBlurUtilities.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTNewsBlurUtilities : NSObject

+ (NSString *)md5:(NSString *)string;
+ (NSString *)formatLongDateFromTimestamp:(NSInteger)timestamp;
+ (NSString *)formatShortDateFromTimestamp:(NSInteger)timestamp;

@end
