//
//  TTModeNestOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestOptions.h"
#import "TTModeNestAuthViewController.h"

@interface TTModeNestOptions ()

@end

@implementation TTModeNestOptions

@synthesize authButton;
@synthesize nestStructureManager;
@synthesize nestThermostatManager;
@synthesize currentStructure;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nestStructureManager = [[NestStructureManager alloc] init];
    [self.nestStructureManager setDelegate:self];
    [self.nestStructureManager initialize];
    
    self.nestThermostatManager = [[NestThermostatManager alloc] init];
    [self.nestThermostatManager setDelegate:self];
}

#pragma mark - Actions

- (IBAction)clickAuthButton:(id)sender {
    TTModeNestAuthViewController *nestAuthViewController = [[TTModeNestAuthViewController alloc] init];

    NSPopover *authPopover = [[NSPopover alloc] init];
    [authPopover setContentSize:NSMakeSize(320, 480)];
    [authPopover setBehavior:NSPopoverBehaviorTransient];
    [authPopover setAnimates:YES];
    [authPopover setContentViewController:nestAuthViewController];
    
    NSRect entryRect = [sender convertRect:((NSButton *)sender).bounds
                                    toView:appDelegate.panelController.backgroundView];
    
    [authPopover showRelativeToRect:entryRect
                             ofView:appDelegate.panelController.backgroundView
                      preferredEdge:NSMinYEdge];
}

- (void)structureUpdated:(NSDictionary *)structure {
    NSLog(@"Nest Structure updated: %@", structure);
    self.currentStructure = structure;
    [self displayThermostats];
}

- (void)thermostatValuesChanged:(Thermostat *)thermostat {
    NSLog(@"thermostat value changed: %@: %ld - %ld", thermostat, thermostat.targetTemperatureF, thermostat.ambientTemperatureF);
}

- (void)displayThermostats {
    Thermostat *thermostat = [[self.currentStructure objectForKey:@"thermostats"] objectAtIndex:0];
    [self.nestThermostatManager beginSubscriptionForThermostat:thermostat];
}

@end
