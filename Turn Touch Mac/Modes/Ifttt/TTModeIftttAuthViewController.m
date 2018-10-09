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

@synthesize webView;
@synthesize modeIfttt;
@synthesize authPopover;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    
    [webView setResourceLoadDelegate:self];
    [webView setFrameLoadDelegate:self];
}

- (void)authorizeIfttt {
    NSDictionary *attrs = [appDelegate.modeMap deviceAttrs];
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://turntouch.com/ifttt/begin"];
    NSMutableArray *query = [NSMutableArray array];
    for (NSString *key in attrs) {
        [query addObject:[NSURLQueryItem queryItemWithName:key value:attrs[key]]];
    }
    components.queryItems = query;
    
    NSLog(@" ---> Authorizing IFTTT: %@", components.URL.absoluteString);
    [webView setMainFrameURL:components.URL.absoluteString];
}

- (void)openRecipe:(TTModeDirection)direction {
    NSString *modeDirection = [appDelegate.modeMap directionName:self.modeIfttt.modeDirection];
    NSString *actionDirection = [appDelegate.modeMap directionName:direction];
    
    NSMutableDictionary *attrs = [[appDelegate.modeMap deviceAttrs] mutableCopy];
    attrs[@"app_direction"] = modeDirection;
    attrs[@"button_direction"] = actionDirection;
    
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://turntouch.com/ifttt/open_recipe"];
    NSMutableArray *query = [NSMutableArray array];
    for (NSString *key in attrs) {
        [query addObject:[NSURLQueryItem queryItemWithName:key value:attrs[key]]];
    }
    components.queryItems = query;
    
    [webView setMainFrameURL:components.URL.absoluteString];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSURL *url = [[[frame dataSource] request] URL];
    if (url) NSLog(@" ---> URL: %@", url);
    NSString *iftttURL = [url absoluteString];
    NSLog(@" ---> IFTTT URL: %@", iftttURL);
    [sender stringByEvaluatingJavaScriptFromString:@"window.open = function(open) { return function (url, name, features) { window.location.href = url; return window; }; } (window.open);"];
    if ([iftttURL containsString:@"connection-finished"]) {
        [webView setMainFrameURL:@"https://ifttt.com/create/if-turntouch?sid=11"];
    }
}

@end
