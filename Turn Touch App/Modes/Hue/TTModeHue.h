//
//  TTModeHue.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/25/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTMode.h"
#import "TTModeProtocol.h"
#include "PHBridgePushLinkViewController.h"
#include "PHBridgeSelectionViewController.h"
#import <HueSDK_OSX/HueSDK.h>

@interface TTModeHue : TTMode
<PHBridgePushLinkViewControllerDelegate, PHBridgeSelectionViewControllerDelegate>

@property (strong, nonatomic) PHHueSDK *phHueSDK;

- (void)searchForBridgeLocal;

@end
