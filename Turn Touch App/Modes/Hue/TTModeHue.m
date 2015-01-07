//
//  TTModeHue.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/25/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "PHLoadingViewController.h"

@interface TTModeHue()

@property (nonatomic, strong) PHBridgeSelectionViewController *bridgeSelectionViewController;
@property (nonatomic, strong) PHLoadingViewController *loadingViewController;
@property (nonatomic, strong) PHBridgePushLinkViewController *pushLinkViewController;
@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;

@end

@implementation TTModeHue

#pragma mark - Mode

+ (NSString *)title {
    return @"Hue";
}

+ (NSString *)description {
    return @"Lights and scenes";
}

+ (NSString *)imageName {
    return @"mode_meditation.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeHueSceneEarlyEvening",
             @"TTModeHueSceneLateEvening",
             @"TTModeHueSleep",
             @"TTModeHueOff"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeHueSceneEarlyEvening {
    return @"Early evening";
}
- (NSString *)titleTTModeHueSceneLateEvening {
    return @"Late evening";
}
- (NSString *)titleTTModeHueSleep {
    return @"Sleep";
}
- (NSString *)titleTTModeHueOff {
    return @"Lights off";
}

#pragma mark - Action Images

- (NSString *)imageTTModeHueSceneEarlyEvening {
    return @"volume_up.png";
}
- (NSString *)imageTTModeHueSceneLateEvening {
    return @"volume_down.png";
}
- (NSString *)imageTTModeHueSleep {
    return @"play.png";
}
- (NSString *)imageTTModeHueOff {
    return @"next_track.png";
}

#pragma mark - Action methods


#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeHueSceneEarlyEvening";
}
- (NSString *)defaultEast {
    return @"TTModeHueSceneLateEvening";
}
- (NSString *)defaultWest {
    return @"TTModeHueOff";
}
- (NSString *)defaultSouth {
    return @"TTModeHueSleep";
}

#pragma mark - Hue Init

- (void)activate {
    self.phHueSDK = [[PHHueSDK alloc] init];
    [self.phHueSDK startUpSDK];
    [self.phHueSDK enableLogging:YES];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    
    /***************************************************
     The SDK will send the following notifications in response to events:
     
     - LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
     
     - NO_LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that there is no connection with the bridge
     
     - NO_LOCAL_AUTHENTICATION_NOTIFICATION
     This notification will notify that there is no authentication against the bridge
     *****************************************************/
    
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
}


#pragma mark - HueSDK

/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    /***************************************************
     We are not authenticated so we start the authentication process
     *****************************************************/
    
    /***************************************************
     doAuthentication will start the push linking
     *****************************************************/
    
    // Start local authenticion process
    [self performSelector:@selector(doAuthentication) withObject:nil afterDelay:0.5];
}

/**
 Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
 */
- (void)checkConnectionState {
    if (!self.phHueSDK.localConnected) {
//        if (self.noConnectionAlert == nil) {
            // Show popup
            [self showNoConnectionDialog];
//        }
    }
    else {
        // One of the connections is made, remove popups and loading views
//        [self hideCurrentSheetWindow];
    }
}

/**
 Shows the first no connection alert
 */
- (void)showNoConnectionDialog {
    NSLog(@"Connection to bridge lost!");
}

/**
 Shows the no bridges found alert
 */
- (void)showNoBridgesFoundDialog {
    NSLog(@"Could not find bridge!");
}

/**
 Shows the not authenticated alert
 */
- (void)showNotAuthenticatedDialog{
    NSLog(@"Pushlink button not pressed within 30 sec!");
}

#pragma mark - Bridge searching and selection

/**
 Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
 */
- (void)searchForBridgeLocal {
    // Stop heartbeats
    [self disableLocalHeartbeat];
    
    // Remove currently showing popups, loading sheets or other screens
//    [self hideCurrentSheetWindow];
    
    // Show search screen
    [self showLoadingViewWithText:NSLocalizedString(@"Searching for bridges...", @"Searching for bridges text")];
    /***************************************************
     A bridge search is started using UPnP to find local bridges
     *****************************************************/
    
    // Start search
    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:YES];
    [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        
        // Done with search, remove loading sheet view
//        [self hideCurrentSheetWindow];
        
        /***************************************************
         The search is complete, check whether we found a bridge
         *****************************************************/
        
        // Check for results
        if (bridgesFound.count > 0) {
            // Results were found, show options to user (from a user point of view, you should select automatically when there is only one bridge found)
            
            /***************************************************
             Use the list of bridges, present them to the user, so one can be selected.
             *****************************************************/
            self.bridgeSelectionViewController = [[PHBridgeSelectionViewController alloc] initWithNibName:@"PHBridgeSelectionViewController" bundle:[NSBundle mainBundle] bridges:bridgesFound delegate:self];
            
            
            [appDelegate.modeMap.selectedMode.modeOptionsView addSubview:self.bridgeSelectionViewController.view];
            
        }
        else {
            /***************************************************
             No bridge was found was found. Tell the user and offer to retry..
             *****************************************************/
            
            // No bridges were found, show this to the user
            [self showNoBridgesFoundDialog];
        }
    }];
    
}

/**
 Delegate method for PHbridgeSelectionViewController which is invoked when a bridge is selected
 */
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andMacAddress:(NSString *)macAddress {
    /***************************************************
     Removing the selection view controller takes us to
     the 'normal' UI view
     *****************************************************/
//    [self hideCurrentSheetWindow];
    
    // Show a connecting loading sheet while we try to connect to the bridge
    [self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
    
    // Set SDK to use bridge and our default username (which should be the same across all apps, so pushlinking is only required once)
    
    /***************************************************
     Set the username, ipaddress and mac address,
     as the bridge properties that the SDK framework will use
     *****************************************************/
    
    [self.phHueSDK setBridgeToUseWithIpAddress:ipAddress macAddress:macAddress];
    
    /***************************************************
     Setting the hearbeat running will cause the SDK
     to regularly update the cache with the status of the
     bridge resources
     *****************************************************/
    
    // Start local heartbeat again
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

#pragma mark - Heartbeat control

/**
 Starts the local heartbeat with a 10 second interval
 */
- (void)enableLocalHeartbeat {
    /***************************************************
     The heartbeat processing collects data from the bridge
     so now try to see if we have a bridge already connected
     *****************************************************/
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        // Hide sheet if there is any
//        [self hideCurrentSheetWindow];
        
        // Show a connecting sheet while we try to connect to the bridge
        [self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
        
        // Enable heartbeat with interval of 10 seconds
        [self.phHueSDK enableLocalConnection];
    } else {
        // Automaticly start searching for bridges
        [self searchForBridgeLocal];
    }
}

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat {
    [self.phHueSDK disableLocalConnection];
}

#pragma mark - Bridge authentication

/**
 Start the local authentication process
 */
- (void)doAuthentication {
    // Disable heartbeats
    [self disableLocalHeartbeat];
    
    // Remove loading sheet view
//    [self hideCurrentSheetWindow];
    
    /***************************************************
     To be certain that we own this bridge we must manually
     push link it. Here we display the view to do this.
     *****************************************************/
    
    // Create an interface for the pushlinking
    self.pushLinkViewController = [[PHBridgePushLinkViewController alloc] initWithNibName:@"PHBridgePushLinkViewController" bundle:[NSBundle mainBundle] delegate:self];
    
    [appDelegate.modeMap.selectedMode.modeOptionsView addSubview:self.pushLinkViewController.view];
    
    /***************************************************
     Start the push linking process.
     *****************************************************/
    
    // Start pushlinking when the interface is shown
    [self.pushLinkViewController startPushLinking];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successfull
 */
- (void)pushlinkSuccess {
    /***************************************************
     Push linking succeeded we are authenticated against
     the chosen bridge.
     *****************************************************/
    
    // Remove pushlink view controller
//    [self hideCurrentSheetWindow];
    
    // Start local heartbeat
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
 */
- (void)pushlinkFailed:(PHError *)error {
    // Remove pushlink view controller
//    [self hideCurrentSheetWindow];
    
    // Check which error occured
    if (error.code == PUSHLINK_NO_CONNECTION) {
        // No local connection to bridge
        [self noLocalConnection];
        
        // Start local heartbeat (to see when connection comes back)
        [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
    }
    else {
        // Bridge button not pressed in time
        [self showNotAuthenticatedDialog];
    }
}

#pragma mark - View management

- (void)showLoadingViewWithText:(NSString*)message{
    if (self.loadingViewController == nil) {
        self.loadingViewController = [[PHLoadingViewController alloc] initWithNibName:@"PHLoadingViewController" bundle:[NSBundle mainBundle]];
    }
    [self.loadingViewController setLoadingWithMessage:message];
}



@end
