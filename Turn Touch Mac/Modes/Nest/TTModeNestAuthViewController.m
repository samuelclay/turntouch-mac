//
//  TTModeNestAuthViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/18/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestAuthViewController.h"
#import "NestAuthManager.h"
#import "NestConstants.h"
#import "TTModeNest.h"

#define QUESTION_MARK @"?"
#define SLASH @"/"
#define HASHTAG @"#"
#define EQUALS @"="
#define AMPERSAND @"&"
#define EMPTY_STRING @""

@interface TTModeNestAuthViewController ()

@end

@implementation TTModeNestAuthViewController

@synthesize webView;
@synthesize modeNest;
@synthesize authPopover;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    
    [webView setMainFrameURL:self.authURL];
    [webView setResourceLoadDelegate:self];
}

- (NSString *)authURL {
    [[NestAuthManager sharedManager] setClientId:NestClientID];
    [[NestAuthManager sharedManager] setClientSecret:NestClientSecret];
    
    NSString *authorizationCodeURL = [[NestAuthManager sharedManager] authorizationURL];

    return authorizationCodeURL;
}

- (void)foundAuthorizationCode:(NSString *)authorizationCode
{
    // Save the authorization code
    [[NestAuthManager sharedManager] setAuthorizationCode:authorizationCode];
    
    // Check for the access token every second and once we have it leave this page
    [self setupCheckTokenTimer];
    
    [modeNest beginConnectingToNest];
}

- (void)invalidateTimer
{
    if ([checkTokenTimer isValid]) {
        [checkTokenTimer invalidate];
        checkTokenTimer = nil;
    }
}

/**
 * Setup the checkTokenTimer
 */
- (void)setupCheckTokenTimer
{
    [self invalidateTimer];
    checkTokenTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self
                                                     selector:@selector(checkForAccessToken:)
                                                     userInfo:nil repeats:YES];
}

/**
 * Checks periodically every second after the authorization code is received to
 * see if it has been exchanged for the access token.
 * @param The timer that sent the message.
 */
- (void)checkForAccessToken:(NSTimer *)sender
{
    if ([[NestAuthManager sharedManager] isValidSession]) {
        [self invalidateTimer];
        [authPopover close];
        [modeNest subscribeToThermostat:0];
    }
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
    NSURL *url = [request URL];
    NSURL *redirectURL = [[NSURL alloc] initWithString:RedirectURL];
    if ([[url host] isEqualToString:[redirectURL host]]) {
        NSLog(@"Nest auth URL: %@", url);
        // Clean the string
        NSString *urlResources = [url resourceSpecifier];
        urlResources = [urlResources stringByReplacingOccurrencesOfString:QUESTION_MARK withString:EMPTY_STRING];
        urlResources = [urlResources stringByReplacingOccurrencesOfString:HASHTAG withString:EMPTY_STRING];
        
        // Seperate the /
        NSArray *urlResourcesArray = [urlResources componentsSeparatedByString:SLASH];
        
        // Get all the parameters after /
        NSString *urlParamaters = [urlResourcesArray objectAtIndex:([urlResourcesArray count]-1)];
        
        // Separate the &
        NSArray *urlParamatersArray = [urlParamaters componentsSeparatedByString:AMPERSAND];
        NSString *keyValue = [urlParamatersArray lastObject];
        NSArray *keyValueArray = [keyValue componentsSeparatedByString:EQUALS];
        
        // We found the code
        if([[keyValueArray objectAtIndex:0] isEqualToString:@"code"]) {
            [self foundAuthorizationCode:[keyValueArray objectAtIndex:1]];
        } else {
            NSLog(@"Error retrieving the authorization code.");
        }
        
        return request;
    } else {
        NSLog(@"Auth web url: %@ (%@)", url, [redirectResponse URL]);
    }

    return request;
}

@end
