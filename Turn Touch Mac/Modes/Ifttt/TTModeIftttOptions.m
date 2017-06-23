//
//  TTModeIftttOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIftttOptions.h"
#import "TTModeIftttConnect.h"
#import "TTModeIftttConnecting.h"
#import "TTModeIftttConnected.h"

@interface TTModeIftttOptions ()

@property (nonatomic, strong) TTModeIftttConnect *connectViewController;
@property (nonatomic, strong) TTModeIftttConnecting *connectingViewController;
@property (nonatomic, strong) TTModeIftttConnected *connectedViewController;

@end

@implementation TTModeIftttOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modeIfttt = (TTModeIfttt *)self.mode;
    [self.modeIfttt setDelegate:self];
    
    [self changeState:TTModeIfttt.iftttState withMode:self.modeIfttt];
}

- (void)changeState:(TTIftttState)iftttState withMode:(TTModeIfttt *)modeIfttt {
    //    NSLog(@" Changing Ifttt state: %lu", iftttState);
    switch (iftttState) {
        case IFTTT_STATE_NOT_CONNECTED:
            [self drawConnectViewController];
            break;
            
        case IFTTT_STATE_CONNECTING:
            [self drawConnectingViewController];
            [self.connectingViewController setConnectingWithMessage:nil];
            break;
            
        case IFTTT_STATE_CONNECTED:
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
    self.connectViewController = [[TTModeIftttConnect alloc]
                                  initWithNibName:@"TTModeIftttConnect"
                                  bundle:[NSBundle mainBundle]];
    self.connectViewController.modeIfttt = self.modeIfttt;
    [self drawViewController:self.connectViewController];
}

- (void)drawConnectingViewController {
    [self clearViewConnectrollers];
    self.connectingViewController = [[TTModeIftttConnecting alloc]
                                     initWithNibName:@"TTModeIftttConnecting"
                                     bundle:[NSBundle mainBundle]];
    self.connectingViewController.modeIfttt = self.modeIfttt;
    [self drawViewController:self.connectingViewController];
}

- (void)drawConnectedViewController {
    [self clearViewConnectrollers];
    self.connectedViewController = [[TTModeIftttConnected alloc]
                                    initWithNibName:@"TTModeIftttConnected"
                                    bundle:[NSBundle mainBundle]];
    self.connectedViewController.modeIfttt = self.modeIfttt;
    [self drawViewController:self.connectedViewController];
}

@end
