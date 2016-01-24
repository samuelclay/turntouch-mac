//
//  TTModeWemoOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemoOptions.h"
#import "TTModeWemoConnect.h"
#import "TTModeWemoConnecting.h"
#import "TTModeWemoConnected.h"

@interface TTModeWemoOptions ()

@property (nonatomic, strong) TTModeWemoConnect *connectViewController;
@property (nonatomic, strong) TTModeWemoConnecting *connectingViewController;
@property (nonatomic, strong) TTModeWemoConnected *connectedViewController;

@end

@implementation TTModeWemoOptions

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modeWemo = ((TTModeWemo *)NSAppDelegate.modeMap.selectedMode);
    [self.modeWemo setDelegate:self];
    
    [self changeState:self.modeWemo.wemoState withMode:self.modeWemo];
}

- (void)changeState:(TTWemoState)wemoState withMode:(TTModeWemo *)modeWemo {
    //    NSLog(@" Changing Wemo state: %lu", wemoState);
    switch (wemoState) {
        case WEMO_STATE_NOT_CONNECTED:
            [self drawConnectViewController];
            break;
            
        case WEMO_STATE_CONNECTING:
            [self drawConnectingViewController];
            [self.connectingViewController setConnectingWithMessage:nil];
            break;
            
        case WEMO_STATE_CONNECTED:
            [self drawConnectedViewController];
            break;
            
        default:
            break;
    }
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
    self.connectViewController = [[TTModeWemoConnect alloc]
                                  initWithNibName:@"TTModeWemoConnect"
                                  bundle:[NSBundle mainBundle]];
    self.connectViewController.modeWemo = self.modeWemo;
    [self drawViewController:self.connectViewController];
}

- (void)drawConnectingViewController {
    [self clearViewConnectrollers];
    self.connectingViewController = [[TTModeWemoConnecting alloc]
                                     initWithNibName:@"TTModeWemoConnecting"
                                     bundle:[NSBundle mainBundle]];
    self.connectingViewController.modeWemo = self.modeWemo;
    [self drawViewController:self.connectingViewController];
}

- (void)drawConnectedViewController {
    [self clearViewConnectrollers];
    self.connectedViewController = [[TTModeWemoConnected alloc]
                                    initWithNibName:@"TTModeWemoConnected"
                                    bundle:[NSBundle mainBundle]];
    self.connectedViewController.modeWemo = self.modeWemo;
    [self drawViewController:self.connectedViewController];
}

@end
