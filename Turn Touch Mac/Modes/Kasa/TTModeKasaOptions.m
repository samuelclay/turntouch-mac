//
//  TTModeKasaOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasaOptions.h"
#import "TTModeKasaConnect.h"
#import "TTModeKasaConnecting.h"
#import "TTModeKasaConnected.h"

@interface TTModeKasaOptions ()

@property (nonatomic, strong) TTModeKasaConnect *connectViewController;
@property (nonatomic, strong) TTModeKasaConnecting *connectingViewController;
@property (nonatomic, strong) TTModeKasaConnected *connectedViewController;
@property (nonatomic, strong) NSLayoutConstraint *viewHeightConstraint;

@end

@implementation TTModeKasaOptions

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modeKasa = (TTModeKasa *)self.mode;
    [self.modeKasa setDelegate:self];

    [self changeState:TTModeKasa.kasaState withMode:self.modeKasa];
}

- (void)changeState:(TTKasaState)kasaState withMode:(TTModeKasa *)modeKasa {
    switch (kasaState) {
        case KASA_STATE_NOT_CONNECTED:
            [self drawConnectViewController];
            break;

        case KASA_STATE_CONNECTING:
            [self drawConnectingViewController];
            [self.connectingViewController setConnectingWithMessage:nil];
            break;

        case KASA_STATE_CONNECTED:
            [self drawConnectedViewController];
            break;

        default:
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
    self.connectViewController = [[TTModeKasaConnect alloc]
                                  initWithNibName:@"TTModeKasaConnect"
                                  bundle:[NSBundle mainBundle]];
    self.connectViewController.modeKasa = self.modeKasa;
    [self drawViewController:self.connectViewController];
}

- (void)drawConnectingViewController {
    [self clearViewControllers];
    self.connectingViewController = [[TTModeKasaConnecting alloc]
                                     initWithNibName:@"TTModeKasaConnecting"
                                     bundle:[NSBundle mainBundle]];
    self.connectingViewController.modeKasa = self.modeKasa;
    [self drawViewController:self.connectingViewController];
}

- (void)drawConnectedViewController {
    [self clearViewControllers];
    self.connectedViewController = [[TTModeKasaConnected alloc]
                                    initWithNibName:@"TTModeKasaConnected"
                                    bundle:[NSBundle mainBundle]];
    self.connectedViewController.modeKasa = self.modeKasa;
    [self drawViewController:self.connectedViewController];
}

@end
