//
//  NSString+TTEncoding.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/17/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "NSString+TTEncoding.h"

@implementation NSString (TTEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}

@end
