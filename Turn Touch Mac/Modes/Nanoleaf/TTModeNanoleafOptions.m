//
//  TTModeNanoleafOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTModeNanoleaf.h"
#import "TTModeNanoleafOptions.h"
#import "TTModeNanoleafConnect.h"
#import "TTModeNanoleafConnecting.h"
#import "TTModeNanoleafConnected.h"
#import "TTModeNanoleafPushlink.h"

@interface TTModeNanoleafOptions ()

@property (nonatomic, strong) TTModeNanoleafConnect *connectViewController;
@property (nonatomic, strong) TTModeNanoleafConnecting *connectingViewController;
@property (nonatomic, strong) TTModeNanoleafConnected *connectedViewController;
@property (nonatomic, strong) TTModeNanoleafPushlink *pushlinkViewController;
@property (nonatomic, strong) NSLayoutConstraint *viewHeightConstraint;

@end

@implementation TTModeNanoleafOptions

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modeNanoleaf = ((TTModeNanoleaf *)NSAppDelegate.modeMap.selectedMode);
    [self.modeNanoleaf setDelegate:self];

    [self changeState:self.modeNanoleaf.nanoleafState withMode:self.modeNanoleaf showMessage:nil];
}

- (void)changeState:(TTNanoleafState)state withMode:(TTModeNanoleaf *)mode showMessage:(id)message {
    switch (state) {
        case NANOLEAF_STATE_NOT_CONNECTED:
            [self drawConnectViewController];
            [self.connectViewController setStoppedWithMessage:message];
            break;

        case NANOLEAF_STATE_CONNECTING:
            [self drawConnectingViewController];
            [self.connectingViewController setConnectingWithMessage:message];
            break;

        case NANOLEAF_STATE_PUSHLINK:
            if (!self.pushlinkViewController) {
                [self drawPushlinkViewController];
            }
            [self.pushlinkViewController setProgress:message];
            break;

        case NANOLEAF_STATE_CONNECTED:
            [self drawConnectedViewController];
            break;
    }
}

#pragma mark - View Controllers

- (void)clearViewControllers {
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
    CGFloat viewHeight = NSHeight(viewController.view.frame);
    NSSize fittingSize = [viewController.view fittingSize];
    if (fittingSize.height > 0.f) {
        viewHeight = fittingSize.height;
    }

    if (self.viewHeightConstraint) {
        [self.view removeConstraint:self.viewHeightConstraint];
    }
    self.viewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0 constant:viewHeight];
    [self.view addConstraint:self.viewHeightConstraint];

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
    [self clearViewControllers];
    self.connectViewController = [[TTModeNanoleafConnect alloc]
                                  initWithNibName:@"TTModeNanoleafConnect"
                                  bundle:[NSBundle mainBundle]];
    self.connectViewController.modeNanoleaf = self.modeNanoleaf;
    [self drawViewController:self.connectViewController];
}

- (void)drawConnectingViewController {
    [self clearViewControllers];
    self.connectingViewController = [[TTModeNanoleafConnecting alloc]
                                     initWithNibName:@"TTModeNanoleafConnecting"
                                     bundle:[NSBundle mainBundle]];
    self.connectingViewController.modeNanoleaf = self.modeNanoleaf;
    [self drawViewController:self.connectingViewController];
}

- (void)drawConnectedViewController {
    [self clearViewControllers];
    self.connectedViewController = [[TTModeNanoleafConnected alloc]
                                    initWithNibName:@"TTModeNanoleafConnected"
                                    bundle:[NSBundle mainBundle]];
    self.connectedViewController.modeNanoleaf = self.modeNanoleaf;
    [self drawViewController:self.connectedViewController];
}

- (void)drawPushlinkViewController {
    [self clearViewControllers];
    self.pushlinkViewController = [[TTModeNanoleafPushlink alloc]
                                   initWithNibName:@"TTModeNanoleafPushlink"
                                   bundle:[NSBundle mainBundle]];
    self.pushlinkViewController.modeNanoleaf = self.modeNanoleaf;
    [self drawViewController:self.pushlinkViewController];
}

@end
