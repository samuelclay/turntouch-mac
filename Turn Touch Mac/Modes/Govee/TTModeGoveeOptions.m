//
//  TTModeGoveeOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGoveeOptions.h"
#import "TTModeGoveeConnect.h"
#import "TTModeGoveeConnecting.h"
#import "TTModeGoveeConnected.h"

@interface TTModeGoveeOptions ()

@property (nonatomic, strong) TTModeGoveeConnect *connectViewController;
@property (nonatomic, strong) TTModeGoveeConnecting *connectingViewController;
@property (nonatomic, strong) TTModeGoveeConnected *connectedViewController;
@property (nonatomic, strong) NSLayoutConstraint *viewHeightConstraint;

@end

@implementation TTModeGoveeOptions

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modeGovee = (TTModeGovee *)self.mode;
    [self.modeGovee setDelegate:self];

    [self changeState:TTModeGovee.goveeState withMode:self.modeGovee];
}

- (void)changeState:(TTGoveeState)goveeState withMode:(TTModeGovee *)modeGovee {
    switch (goveeState) {
        case GOVEE_STATE_NOT_CONNECTED:
            [self drawConnectViewController];
            break;

        case GOVEE_STATE_CONNECTING:
            [self drawConnectingViewController];
            [self.connectingViewController setConnectingWithMessage:nil];
            break;

        case GOVEE_STATE_CONNECTED:
            [self drawConnectedViewController];
            break;

        default:
            break;
    }
}

- (void)fetchStatusUpdate:(NSString *)status {
    [self.connectingViewController setConnectingWithMessage:status];
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
    self.connectViewController = [[TTModeGoveeConnect alloc]
                                  initWithNibName:@"TTModeGoveeConnect"
                                  bundle:[NSBundle mainBundle]];
    self.connectViewController.modeGovee = self.modeGovee;
    [self drawViewController:self.connectViewController];
}

- (void)drawConnectingViewController {
    [self clearViewControllers];
    self.connectingViewController = [[TTModeGoveeConnecting alloc]
                                     initWithNibName:@"TTModeGoveeConnecting"
                                     bundle:[NSBundle mainBundle]];
    self.connectingViewController.modeGovee = self.modeGovee;
    [self drawViewController:self.connectingViewController];
}

- (void)drawConnectedViewController {
    [self clearViewControllers];
    self.connectedViewController = [[TTModeGoveeConnected alloc]
                                    initWithNibName:@"TTModeGoveeConnected"
                                    bundle:[NSBundle mainBundle]];
    self.connectedViewController.modeGovee = self.modeGovee;
    [self drawViewController:self.connectedViewController];
}

@end
