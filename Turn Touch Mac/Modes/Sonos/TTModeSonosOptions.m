//
//  TTModeSonosOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/18/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//
#import "TTModeSonosOptions.h"
#import "TTModeSonosConnect.h"
#import "TTModeSonosConnecting.h"
#import "TTModeSonosConnected.h"

@interface TTModeSonosOptions ()

@property (nonatomic, strong) TTModeSonosConnect *connectViewController;
@property (nonatomic, strong) TTModeSonosConnecting *connectingViewController;
@property (nonatomic, strong) TTModeSonosConnected *connectedViewController;

@end

@implementation TTModeSonosOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modeSonos = (TTModeSonos *)self.mode;
    [self.modeSonos setDelegate:self];
    
    [self changeState:TTModeSonos.sonosState withMode:self.modeSonos];
}

- (void)changeState:(TTSonosState)sonosState withMode:(TTModeSonos *)modeSonos {
    //    NSLog(@" Changing Sonos state: %lu", sonosState);
    switch (sonosState) {
        case SONOS_STATE_NOT_CONNECTED:
            [self drawConnectViewController];
            break;
            
        case SONOS_STATE_CONNECTING:
            [self drawConnectingViewController];
            [self.connectingViewController setConnectingWithMessage:nil];
            break;
            
        case SONOS_STATE_CONNECTED:
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
    self.connectViewController = [[TTModeSonosConnect alloc]
                                  initWithNibName:@"TTModeSonosConnect"
                                  bundle:[NSBundle mainBundle]];
    self.connectViewController.modeSonos = self.modeSonos;
    [self drawViewController:self.connectViewController];
}

- (void)drawConnectingViewController {
    [self clearViewConnectrollers];
    self.connectingViewController = [[TTModeSonosConnecting alloc]
                                     initWithNibName:@"TTModeSonosConnecting"
                                     bundle:[NSBundle mainBundle]];
    self.connectingViewController.modeSonos = self.modeSonos;
    [self drawViewController:self.connectingViewController];
}

- (void)drawConnectedViewController {
    [self clearViewConnectrollers];
    self.connectedViewController = [[TTModeSonosConnected alloc]
                                    initWithNibName:@"TTModeSonosConnected"
                                    bundle:[NSBundle mainBundle]];
    self.connectedViewController.modeSonos = self.modeSonos;
    [self drawViewController:self.connectedViewController];
}

@end
