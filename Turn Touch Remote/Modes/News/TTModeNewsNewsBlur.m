//
//  TTModeNewsNewsBlur.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNewsNewsBlur.h"

@implementation TTModeNewsNewsBlur

- (void)fetchRiverStories:(void (^)(NSArray *stories))callback {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.newsblur.com/reader/river_stories"]];
    
    __block NSDictionary *json;
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//         NSLog(@"Async JSON: %@", json);
         
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             callback(json[@"stories"]);
         });
     }];
}

@end
