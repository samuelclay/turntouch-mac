//
//  TTModeHue.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/25/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTModeHueSceneOptions.h"

#define MAX_HUE 65535

@interface TTModeHue()

@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;

@end

@implementation TTModeHue

@synthesize delegate;
@synthesize hueState;

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
             @"TTModeHueSceneSleep",
             @"TTModeHueSceneOff",
             @"TTModeHueSceneRandom"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeHueSceneEarlyEvening {
    return @"Early evening";
}
- (NSString *)titleTTModeHueSceneLateEvening {
    return @"Late evening";
}
- (NSString *)titleTTModeHueSceneSleep {
    return @"Sleep";
}
- (NSString *)titleTTModeHueSceneOff {
    return @"Lights off";
}
- (NSString *)titleTTModeHueSceneRandom {
    return @"Random";
}

#pragma mark - Action Images

- (NSString *)imageTTModeHueSceneEarlyEvening {
    return @"volume_up.png";
}
- (NSString *)imageTTModeHueSceneLateEvening {
    return @"volume_down.png";
}
- (NSString *)imageTTModeHueSceneSleep {
    return @"play.png";
}
- (NSString *)imageTTModeHueSceneOff {
    return @"next_track.png";
}
- (NSString *)imageTTModeHueSceneRandom {
    return @"next_track.png";
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeHueSceneEarlyEvening";
}
- (NSString *)defaultEast {
    return @"TTModeHueSceneLateEvening";
}
- (NSString *)defaultWest {
    return @"TTModeHueSceneRandom";
}
- (NSString *)defaultSouth {
    return @"TTModeHueSceneSleep";
}

#pragma mark - Action methods

- (void)runScene:(TTModeDirection)direction {
    if (!self.phHueSDK.localConnected) {
        return;
    }
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    NSString *sceneIdentifier = [appDelegate.modeMap actionOptionValue:kHueScene inDirection:direction];
    NSNumber *sceneDuration = (NSNumber *)[appDelegate.modeMap actionOptionValue:kHueDuration inDirection:direction];
    NSNumber *sceneTransition = [NSNumber numberWithInteger:([sceneDuration integerValue] * 10 * 60)];
    PHScene *activeScene;
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];

    NSMutableArray *scenes = [[NSMutableArray alloc] init];
    for (PHScene *scene in cache.scenes.allValues) {
        [scenes addObject:@{@"name": scene.name, @"identifier": scene.identifier}];
        if ([scene.identifier isEqualToString:sceneIdentifier]) {
//            NSLog(@"Checking scene %@=%@: %@", scene.identifier, sceneIdentifier, scene.name);
            activeScene = scene;
        }
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [scenes sortUsingDescriptors:@[sd]];
    
    if (!sceneIdentifier || ![sceneIdentifier length]) {
        // Use default, which is first scene in sorted scene list
        sceneIdentifier = scenes[0][@"identifier"];
    }
    
    NSNumber *originalTransitionTime = activeScene.transitionTime;
    if ([sceneTransition integerValue] && (!originalTransitionTime ||
                                           ![sceneTransition isEqualToNumber:originalTransitionTime])) {
        for (NSString *lightIdentifier in activeScene.lightIdentifiers) {
            PHLight *light = [[cache lights] objectForKey:lightIdentifier];
            PHLightState *lightState = light.lightState;
//            PHLightState *lightState = [[PHLightState alloc] init];
            
//            [lightState setHue:[NSNumber numberWithInt:0]];
            lightState.on = [NSNumber numberWithBool:NO];
            [lightState setBrightness:[NSNumber numberWithInt:0]];
            [lightState setSaturation:[NSNumber numberWithInt:0]];

            lightState.transitionTime = sceneTransition;
            lightState.alert = 0;
            [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
                NSLog(@"Light saved: %@", errors);
            }];
        }
    } else {
        [bridgeSendAPI activateSceneWithIdentifier:sceneIdentifier onGroup:@"0" completionHandler:nil];
    }
}

- (void)runTTModeHueSceneEarlyEvening:(TTModeDirection)direction {
//    NSLog(@"Running early evening... %d", direction);
    [self runScene:direction];
}

- (void)runTTModeHueSceneLateEvening:(TTModeDirection)direction {
//    NSLog(@"Running late evening... %d", direction);
    [self runScene:direction];
}

- (void)runTTModeHueSceneOff:(TTModeDirection)direction {
//    NSLog(@"Running scene off... %d", direction);
    [self runScene:direction];
}

- (void)runTTModeHueSceneSleep:(TTModeDirection)direction {
    //    NSLog(@"Running scene off... %d", direction);
    [self runScene:direction];
}

- (void)runTTModeHueSceneRandom:(TTModeDirection)direction {
    //    NSLog(@"Running scene off... %d", direction);
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
        [lightState setBrightness:[NSNumber numberWithInt:254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {}];
    }
}

#pragma mark - Hue Init

- (void)activate {
//    NSLog(@" ---> Activating Hue mode: %@", self.phHueSDK);
    
    if (self.phHueSDK) {
        [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
        [self disableLocalHeartbeat];
        [self.phHueSDK stopSDK];
        self.phHueSDK = nil;
    }
    self.phHueSDK = [[PHHueSDK alloc] init];
    [self.phHueSDK startUpSDK];
    [self.phHueSDK enableLogging:NO];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    [notificationManager deregisterObjectForAllNotifications:self];
    
    /***************************************************
     The SDK will send the following notifications in response to events:
     
     - LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
     
     - NO_LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that there is no connection with the bridge
     
     - NO_LOCAL_AUTHENTICATION_NOTIFICATION
     This notification will notify that there is no authentication against the bridge
     *****************************************************/
    
    [notificationManager registerObject:self withSelector:@selector(localConnection)
                        forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection)
                        forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated)
                        forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];

    // No Hue found, show connection button
    hueState = STATE_CONNECTING;
    [self.delegate changeState:hueState withMode:self showMessage:@"Connecting..."];
    
    [self enableLocalHeartbeat];
}

- (void)deactivate {
//    NSLog(@" ---> DE-Activating Hue mode: %@", self.phHueSDK);

    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    [self disableLocalHeartbeat];
    [self.phHueSDK stopSDK];
    self.phHueSDK = nil;
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
        [self showNoConnectionDialog];
    }
    else {
        // One of the connections is made, remove popups and loading views
        hueState = STATE_CONNECTED;
        [self.delegate changeState:hueState withMode:self showMessage:nil];
        [self ensureScenes];
    }
}

/**
 Shows the first no connection alert
 */
- (void)showNoConnectionDialog {
    NSLog(@"Connection to bridge lost!");
    hueState = STATE_NOT_CONNECTED;
    [self.delegate changeState:hueState withMode:self showMessage:@"Connection to Hue bridge lost"];
}

/**
 Shows the no bridges found alert
 */
- (void)showNoBridgesFoundDialog {
    NSLog(@"Could not find bridge!");
    hueState = STATE_NOT_CONNECTED;
    [self.delegate changeState:hueState withMode:self showMessage:@"Could not find any Hue bridges"];
}

/**
 Shows the not authenticated alert
 */
- (void)showNotAuthenticatedDialog{
    hueState = STATE_NOT_CONNECTED;
    [self.delegate changeState:hueState withMode:self showMessage:@"Pushlink button not pressed within 30 seconds"];
    NSLog(@"Pushlink button not pressed within 30 sec!");
}

#pragma mark - Bridge searching and selection

/**
 Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
 */
- (void)searchForBridgeLocal {
    // Stop heartbeats
    [self disableLocalHeartbeat];
    
    // Start search
    hueState = STATE_CONNECTING;
    [self.delegate changeState:hueState withMode:self showMessage:@"Searching for a Hue bridge..."];
    
    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:YES];
    [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        /***************************************************
         The search is complete, check whether we found a bridge
         *****************************************************/
        
        // Check for results
        if (bridgesFound.count > 0) {
            hueState = STATE_CONNECTING;
            [self.delegate changeState:hueState withMode:self showMessage:@"Found Hue bridge..."];
            NSString *macAddress = [[bridgesFound allKeys] objectAtIndex:0];
            NSString *ipAddress = [bridgesFound objectForKey:macAddress];
            [self.phHueSDK setBridgeToUseWithIpAddress:ipAddress macAddress:macAddress];
            [self enableLocalHeartbeat];
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
    
    hueState = STATE_PUSHLINK;
    [self.delegate changeState:hueState withMode:self showMessage:nil];
    
    /***************************************************
     Start the push linking process.
     *****************************************************/
    
    // Start pushlinking when the interface is shown
    [self startPushLinking];
}

- (void)startPushLinking {
    /***************************************************
     Set up the notifications for push linkng
     *****************************************************/
    
    // Register for notifications about pushlinking
    PHNotificationManager *phNotificationMgr = [PHNotificationManager defaultManager];
    [phNotificationMgr deregisterObjectForAllNotifications:self];
    
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationSuccess)
                      forNotification:PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationFailed)
                      forNotification:PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalConnection)
                      forNotification:PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalBridge)
                      forNotification:PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(buttonNotPressed:)
                      forNotification:PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION];
    
    // Call to the hue SDK to start pushlinking process
    /***************************************************
     Call the SDK to start Push linking.
     The notifications sent by the SDK will confirm success
     or failure of push linking
     *****************************************************/
    
    [self.phHueSDK startPushlinkAuthentication];
}

#pragma mark - Notifications for Pushlink

/**
 Notification receiver which is called when the pushlinking was successful
 */
- (void)authenticationSuccess {
    /***************************************************
     The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION
     was received. We have confirmed the bridge.
     De-register for notifications and call
     pushLinkSuccess on the delegate
     *****************************************************/
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    hueState = STATE_CONNECTED;
    [self.delegate changeState:hueState withMode:self showMessage:nil];
    [self disableLocalHeartbeat];
    
    // Start local heartbeat
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

/**
 Notification receiver which is called when the pushlinking failed because the time limit was reached
 */
- (void)authenticationFailed {
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    // Inform delegate
    [self pushlinkFailed:[PHError errorWithDomain:SDK_ERROR_DOMAIN
                                                      code:PUSHLINK_TIME_LIMIT_REACHED
                                                  userInfo:[NSDictionary dictionaryWithObject:@"Authentication failed: time limit reached." forKey:NSLocalizedDescriptionKey]]];
}

/**
 Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
 */
- (void)noLocalBridge {
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    // Inform delegate
    [self pushlinkFailed:[PHError errorWithDomain:SDK_ERROR_DOMAIN code:PUSHLINK_NO_LOCAL_BRIDGE userInfo:[NSDictionary dictionaryWithObject:@"Authentication failed: No local bridge found." forKey:NSLocalizedDescriptionKey]]];
}

/**
 This method is called when the pushlinking is still ongoing but no button was pressed yet.
 @param notification The notification which contains the pushlinking percentage which has passed.
 */
- (void)buttonNotPressed:(NSNotification *)notification {
    // Update status bar with percentage from notification
    NSDictionary *dict = notification.userInfo;
    NSNumber *progressPercentage = [dict objectForKey:@"progressPercentage"];
    
    hueState = STATE_PUSHLINK;
    [self.delegate changeState:hueState withMode:self showMessage:progressPercentage];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
 */
- (void)pushlinkFailed:(PHError *)error {
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

- (void)ensureScenes {
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];

    // Collect scene ids to check against
    NSDictionary *scenes = cache.scenes;
    NSMutableArray *foundScenes = [[NSMutableArray alloc] init];
    for (PHScene *scene in scenes.allValues) {
        [foundScenes addObject:scene.identifier];
    }

    // Scene: All Lights Off
    if (![foundScenes containsObject:@"TT-all-off"]) {
        PHScene *scene = [[PHScene alloc] init];
        scene.name = @"All Lights Off";
        scene.identifier = @"TT-all-off";
        scene.lightIdentifiers = cache.lights.allKeys;
        [bridgeSendAPI saveSceneWithCurrentLightStates:scene completionHandler:^(NSArray *errors) {
            NSLog(@"Hue:SceneOff scene: %@", errors);
            for (PHLight *light in cache.lights.allValues) {
                PHLightState *lightState = light.lightState;
                lightState.on = [NSNumber numberWithBool:NO];
                lightState.alert = 0;
                [bridgeSendAPI saveLightState:lightState forLightIdentifier:light.identifier inSceneWithIdentifier:scene.identifier completionHandler:^(NSArray *errors) {
                    NSLog(@"Hue:SceneOff light: %@", errors);
                }];
            }
        }];
    }
}
@end
