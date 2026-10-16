#import <Foundation/Foundation.h>
#import "TTHueAPIClient.h"
#include <assert.h>

// Exercise the production request queue/parser against a local HTTP fixture.
@interface TTHueAPIClient (Tests)
- (void)performRequest:(NSURLRequest *)request completion:(TTHueAPICompletionHandler)completion;
@end

int main(int argc, const char **argv) {
    @autoreleasepool {
        NSString *base = [NSString stringWithUTF8String:argv[1]];
        TTHueAPIClient *client = [[TTHueAPIClient alloc] initWithBridgeIP:@"127.0.0.1" applicationKey:@"fixture-only"];
        NSArray *paths = @[@"success", @"api-error", @"partial-error", @"malformed", @"unauthorized", @"redirect"];
        NSArray *expected = @[@(-1), @(TTHueAPIClientErrorAPI), @(TTHueAPIClientErrorAPI),
                             @(TTHueAPIClientErrorInvalidResponse), @(TTHueAPIClientErrorNotAuthenticated), @(TTHueAPIClientErrorHTTP)];
        for (NSUInteger i = 0; i < paths.count; i++) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[base stringByAppendingFormat:@"/%@", paths[i]]]];
            request.HTTPMethod = @"PUT";
            request.HTTPBody = [@"{\"on\":{\"on\":true}}" dataUsingEncoding:NSUTF8StringEncoding];
            [request setValue:@"fixture-only" forHTTPHeaderField:@"hue-application-key"];
            __block BOOL done = NO;
            [client performRequest:request completion:^(id result, NSError *error) {
                assert(NSThread.isMainThread);
                if ([expected[i] integerValue] == -1) {
                    assert(error == nil && [result[@"data"] count] == 1);
                } else {
                    assert(result == nil && error != nil);
                    assert([error.domain isEqual:TTHueAPIClientErrorDomain]);
                    assert(error.code == [expected[i] integerValue]);
                }
                done = YES;
            }];
            NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:10];
            while (!done && deadline.timeIntervalSinceNow > 0) {
                [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
            }
            assert(done);
        }
        puts("PASS: Hue v2 success, API/partial errors, malformed responses, authentication, and redirects.");
    }
}
