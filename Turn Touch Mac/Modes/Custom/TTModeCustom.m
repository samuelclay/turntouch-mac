//
//  TTModeCustom.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 12/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeCustom.h"

@implementation TTModeCustom

NSString *const kSingleCustomUrl = @"singleCustomUrl";
NSString *const kDoubleCustomUrl = @"doubleCustomUrl";
NSString *const kSingleOutput = @"singleOutput";
NSString *const kDoubleOutput = @"doubleOutput";
NSString *const kSingleHitCount = @"singleHitCount";
NSString *const kDoubleHitCount = @"doubleHitCount";
NSString *const kSingleLastSuccess = @"singleLastSuccess";
NSString *const kDoubleLastSuccess = @"doubleLastSuccess";

#pragma mark - Mode

+ (NSString *)title {
    return @"Custom";
}

+ (NSString *)description {
    return @"Hit a website on command";
}

+ (NSString *)imageName {
    return @"mode_custom.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeCustomURL",
//             @"TTModeCustomScript",
             ];
}

- (BOOL)shouldIgnoreSingleBeforeDouble:(TTModeDirection)direction {
    return YES;
}

#pragma mark - Action Titles

- (NSString *)titleTTModeCustomURL {
    return @"Custom URL";
}
- (NSString *)titleTTModeCustomScript {
    return @"Custom Script";
}

#pragma mark - Action Images

- (NSString *)imageTTModeCustomURL {
    return @"webhook";
}
- (NSString *)imageTTModeCustomScript {
    return @"script";
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeCustomURL";
}
- (NSString *)defaultEast {
    return @"TTModeCustomScript";
}
- (NSString *)defaultWest {
    return @"TTModeCustomScript";
}
- (NSString *)defaultSouth {
    return @"TTModeCustomURL";
}

#pragma mark - Mode specific

- (void)activate {

}

#pragma mark - Action methods

- (void)runTTModeCustomURL:(TTModeDirection)direction {
    NSString *customUrlString = [self.action optionValue:kSingleCustomUrl inDirection:direction];
    
    __block TTAction *action = self.action;
    
    [self hitUrl:customUrlString callback:^(NSString *response, BOOL success) {
        [action changeActionOption:kSingleOutput to:response];
        [action changeActionOption:kSingleLastSuccess to:@(success)];
        
        NSInteger hitCount = [[action optionValue:kSingleHitCount inDirection:direction] integerValue];
        hitCount += 1;
        [action changeActionOption:kSingleHitCount to:@(hitCount)];
        dispatch_async(dispatch_get_main_queue(), ^{
            appDelegate.modeMap.inspectingModeDirection = appDelegate.modeMap.inspectingModeDirection;
        });
    }];
}

- (void)doubleRunTTModeCustomURL:(TTModeDirection)direction {
    NSString *customUrlString = [self.action optionValue:kDoubleCustomUrl inDirection:direction];

    __block TTAction *action = self.action;

    [self hitUrl:customUrlString callback:^(NSString *response, BOOL success) {
        [action changeActionOption:kDoubleOutput to:response];
        [action changeActionOption:kDoubleLastSuccess to:@(success)];
        
        NSInteger hitCount = [[action optionValue:kDoubleHitCount inDirection:direction] integerValue];
        hitCount += 1;
        [action changeActionOption:kDoubleHitCount to:@(hitCount)];
        dispatch_async(dispatch_get_main_queue(), ^{
            appDelegate.modeMap.inspectingModeDirection = appDelegate.modeMap.inspectingModeDirection;
        });
    }];
}

- (void)runTTModeCustomScript:(TTModeDirection)direction {
    
}

- (void)doubleRunTTModeCustomScript:(TTModeDirection)direction {
    
}

- (void)hitUrl:(NSString *)customUrlString callback:(void (^)(NSString *responseString, BOOL success))callback {
    if (!customUrlString || !customUrlString.length) {
        printf(" ---> No URL");
        callback(@"No URL specified", NO);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^{
        __block NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:customUrlString]];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
            NSString *responseString;
            BOOL success = NO;
            if ([urlResponse statusCode] != 200) {
                NSLog(@"Error getting %@, HTTP status code %li", customUrlString, (long)[urlResponse statusCode]);
                responseString = [NSString stringWithFormat:@"Error (%li): %@", (long)[urlResponse statusCode], error];
            } else {
                responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                success = YES;
            }
            
            callback(responseString, success);
        }] resume];
    });
}

@end
