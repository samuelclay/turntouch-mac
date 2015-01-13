//
//  TTModeHueOptions.h
//  Turn Touch App
//
//  Created by Samuel Clay on 1/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <HueSDK_OSX/HueSDK.h>
#import "TTOptionsDetailViewController.h"
#import "TTModeHueConnecting.h"
#import "TTModeHueConnected.h"
#import "TTModeHuePushlink.h"

@interface TTModeHueOptions : TTOptionsDetailViewController
<PHBridgePushLinkViewControllerDelegate>

@property (strong, nonatomic) PHHueSDK *phHueSDK;

- (void)searchForBridgeLocal;

- (void)showStoppedViewWithText:(NSString*)message;
- (void)showLoadingViewWithText:(NSString*)message;

@end
