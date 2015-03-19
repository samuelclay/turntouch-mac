//
//  TTModeHueOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTModeHueOptions.h"
#import "TTModeHueConnect.h"
#import "TTModeHueConnecting.h"
#import "TTModeHueConnected.h"

@interface TTModeHueOptions ()

@property (nonatomic, strong) TTModeHueConnect *connectViewController;
@property (nonatomic, strong) TTModeHueConnecting *connectingViewController;
@property (nonatomic, strong) TTModeHueConnected *connectedViewController;
@property (nonatomic, strong) TTModeHuePushlink *pushlinkViewController;

@end

@implementation TTModeHueOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modeHue = ((TTModeHue *)NSAppDelegate.modeMap.selectedMode);
    [self.modeHue setDelegate:self];
    
    [self changeState:self.modeHue.hueState withMode:self.modeHue showMessage:nil];
}

- (void)changeState:(TTHueState)hueState withMode:(TTModeHue *)modeHue showMessage:(id)message {
    NSLog(@" Changing Hue state: %lu - %@", hueState, message);
    switch (hueState) {
        case STATE_NOT_CONNECTED:
            [self drawConnectViewController];
            [self.connectViewController setStoppedWithMessage:message];
            break;
            
        case STATE_CONNECTING:
            [self drawConnectingViewController];
            [self.connectingViewController setConnectingWithMessage:message];
            break;
            
        case STATE_PUSHLINK:
            [self drawPushlinkViewController];
            [self.pushlinkViewController setProgress:message];
            break;
            
        case STATE_CONNECTED:
            [self drawConnectedViewController];
            break;
            
        default:
            break;
    }
}

- (IBAction)selectOtherBridge:(id)sender {
    [self.modeHue searchForBridgeLocal];
}

#pragma mark - View Connectrollers

- (void)clearViewConnectrollers {
    if (self.connectViewController) {
        [self.connectViewController.view removeFromSuperview];
        self.connectViewController = nil;
    }
    if (self.connectingViewController) {
        [self.connectingViewController.view removeFromSuperview];
        self.connectingViewController = nil;
    }
    if (self.connectedViewController) {
        [self.connectedViewController.view removeFromSuperview];
        self.connectedViewController = nil;
    }
    if (self.pushlinkViewController) {
        [self.pushlinkViewController.view removeFromSuperview];
        self.pushlinkViewController = nil;
    }
}

- (void)drawViewController:(TTOptionsDetailViewController *)viewController {
    [self.view addSubview:viewController.view];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewController.view
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0 constant:0]];
}

- (void)drawConnectViewController {
    [self clearViewConnectrollers];
    self.connectViewController = [[TTModeHueConnect alloc]
                                  initWithNibName:@"TTModeHueConnect"
                                  bundle:[NSBundle mainBundle]];
    self.connectViewController.modeHue = self.modeHue;
    [self drawViewController:self.connectViewController];
}

- (void)drawConnectingViewController {
    [self clearViewConnectrollers];
    self.connectingViewController = [[TTModeHueConnecting alloc]
                                     initWithNibName:@"TTModeHueConnecting"
                                     bundle:[NSBundle mainBundle]];
    self.connectingViewController.modeHue = self.modeHue;
    [self drawViewController:self.connectingViewController];
}

- (void)drawConnectedViewController {
    [self clearViewConnectrollers];
    self.connectedViewController = [[TTModeHueConnected alloc]
                                    initWithNibName:@"TTModeHueConnected"
                                    bundle:[NSBundle mainBundle]];
    self.connectedViewController.modeHue = self.modeHue;
    [self drawViewController:self.connectedViewController];
}

- (void)drawPushlinkViewController {
    [self clearViewConnectrollers];
    self.pushlinkViewController = [[TTModeHuePushlink alloc]
                                    initWithNibName:@"TTModeHuePushlink"
                                    bundle:[NSBundle mainBundle]];
    self.pushlinkViewController.modeHue = self.modeHue;
    [self drawViewController:self.pushlinkViewController];
}

@end
