//
//  TTModeNewsNewsBlur.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNewsNewsBlur.h"

@implementation TTModeNewsNewsBlur

- (void)fetchRiverStories:(void (^)(NSArray *stories, NSArray *feeds))callback {
//    NSString *path = @"/reader/river_stories?include_feeds=true";
//    NSString *path = @"/reader/feed/107?include_feeds=true";
    NSString *path = @"/reader/feed/39?include_feeds=true";
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", NEWSBLUR_HOST, path]]];
    
    __block NSDictionary *json;
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//         NSLog(@"Async JSON: %@", json);
         
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             callback(json[@"stories"], json[@"feeds"]);
         });
     }];
}

@end
