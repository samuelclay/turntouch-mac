//
//  TTModeNestOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestOptions.h"
#import "TTModeNestConnect.h"
#import "TTModeNestConnecting.h"
#import "TTModeNestConnected.h"

@interface TTModeNestOptions ()

@property (nonatomic, strong) TTModeNestConnect *connectViewController;
@property (nonatomic, strong) TTModeNestConnecting *connectingViewController;
@property (nonatomic, strong) TTModeNestConnected *connectedViewController;

@end

@implementation TTModeNestOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modeNest = (TTModeNest *)self.mode;
    [self.modeNest setDelegate:self];
    NSLog(@" ---> NEST %@ delegate: %@", self.modeNest, self);
    
    [self changeState:self.modeNest.nestState withMode:self.modeNest];
}

- (void)changeState:(TTNestState)nestState withMode:(TTModeNest *)modeNest {
//    NSLog(@" Changing Nest state: %lu", nestState);
    switch (nestState) {
        case NEST_STATE_NOT_CONNECTED:
            [self drawConnectViewController];
            break;
            
        case NEST_STATE_CONNECTING:
            [self drawConnectingViewController];
            [self.connectingViewController setConnectingWithMessage:nil];
            break;
            
        case NEST_STATE_CONNECTED:
            [self drawConnectedViewController];
            break;
            
        default:
            break;
    }
}

- (void)updateThermostat:(Thermostat *)thermostat {
    BOOL isCelsius = [thermostat.temperatureScale isEqualToString:@"C"];
    [self.connectedViewController.labelAmbient setStringValue:[NSString stringWithFormat:@"%ld°%@",
                                                               isCelsius ? thermostat.ambientTemperatureC :
                                                               thermostat.ambientTemperatureF,
                                                               thermostat.temperatureScale]];
    if ([thermostat.hvacMode isEqualToString:@"heat-cool"]) {
        [self.connectedViewController.labelTarget setStringValue:[NSString stringWithFormat:@"%ld°%@ - %ld°%@",
                                                                  isCelsius ? thermostat.targetTemperatureLowC :
                                                                  thermostat.targetTemperatureLowF,
                                                                  thermostat.temperatureScale,
                                                                  isCelsius ? thermostat.targetTemperatureHighC :
                                                                  thermostat.targetTemperatureHighF,
                                                                  thermostat.temperatureScale]];
    } else {
        [self.connectedViewController.labelTarget setStringValue:[NSString stringWithFormat:@"%ld°%@",
                                                                  isCelsius ? thermostat.targetTemperatureC :
                                                                  thermostat.targetTemperatureF,
                                                                  thermostat.temperatureScale]];
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
    self.connectViewController = [[TTModeNestConnect alloc]
                                  initWithNibName:@"TTModeNestConnect"
                                  bundle:[NSBundle mainBundle]];
    self.connectViewController.modeNest = self.modeNest;
    [self drawViewController:self.connectViewController];
}

- (void)drawConnectingViewController {
    [self clearViewConnectrollers];
    self.connectingViewController = [[TTModeNestConnecting alloc]
                                     initWithNibName:@"TTModeNestConnecting"
                                     bundle:[NSBundle mainBundle]];
    self.connectingViewController.modeNest = self.modeNest;
    [self drawViewController:self.connectingViewController];
}

- (void)drawConnectedViewController {
    [self clearViewConnectrollers];
    self.connectedViewController = [[TTModeNestConnected alloc]
                                    initWithNibName:@"TTModeNestConnected"
                                    bundle:[NSBundle mainBundle]];
    self.connectedViewController.modeNest = self.modeNest;
    [self drawViewController:self.connectedViewController];
    [self updateThermostat:[self.modeNest selectedThermostat]];
}

@end
