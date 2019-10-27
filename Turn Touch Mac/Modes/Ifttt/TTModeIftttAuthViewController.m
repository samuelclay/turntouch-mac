//
//  TTModeIftttAuthViewController.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIftttAuthViewController.h"
#import "TTModeIfttt.h"

@implementation TTModeIftttAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (TTAppDelegate *)[NSApp delegate];
    
    [self.webView setResourceLoadDelegate:self];
    [self.webView setFrameLoadDelegate:self];
}

- (void)authorizeIfttt {
    NSDictionary *attrs = [self.appDelegate.modeMap deviceAttrs];
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://turntouch.com/ifttt/begin"];
    NSMutableArray *query = [NSMutableArray array];
    for (NSString *key in attrs) {
        [query addObject:[NSURLQueryItem queryItemWithName:key value:attrs[key]]];
    }
    components.queryItems = query;
    
    NSLog(@" ---> Authorizing IFTTT: %@", components.URL.absoluteString);
    [self.webView setMainFrameURL:components.URL.absoluteString];
}

- (void)openRecipe:(TTModeDirection)direction {
    NSString *modeDirection = [self.appDelegate.modeMap directionName:self.modeIfttt.modeDirection];
    NSString *actionDirection = [self.appDelegate.modeMap directionName:direction];
    
    NSMutableDictionary *attrs = [[self.appDelegate.modeMap deviceAttrs] mutableCopy];
    attrs[@"app_direction"] = modeDirection;
    attrs[@"button_direction"] = actionDirection;
    
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://turntouch.com/ifttt/open_recipe"];
    NSMutableArray *query = [NSMutableArray array];
    for (NSString *key in attrs) {
        [query addObject:[NSURLQueryItem queryItemWithName:key value:attrs[key]]];
    }
    components.queryItems = query;
    
    [self.webView setMainFrameURL:components.URL.absoluteString];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSURL *url = [[[frame dataSource] request] URL];
    if (url) NSLog(@" ---> URL: %@", url);
    NSString *iftttURL = [url absoluteString];
    NSLog(@" ---> IFTTT URL: %@", iftttURL);
    [sender stringByEvaluatingJavaScriptFromString:@"window.open = function(open) { return function (url, name, features) { window.location.href = url; return window; }; } (window.open);"];
    if ([iftttURL containsString:@"connection-finished"]) {
        [self.webView setMainFrameURL:@"https://ifttt.com/create/if-turntouch?sid=11"];
    }
}

@end
