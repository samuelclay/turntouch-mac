//
//  TTModeNestOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"
#import "NestThermostatManager.h"
#import "NestStructureManager.h"

@interface TTModeNestOptions : TTOptionsDetailViewController <NestThermostatManagerDelegate, NestStructureManagerDelegate>

@property (nonatomic) IBOutlet NSButton *authButton;
@property (nonatomic, strong) NestThermostatManager *nestThermostatManager;
@property (nonatomic, strong) NestStructureManager *nestStructureManager;

@property (nonatomic, strong) NSDictionary *currentStructure;

- (IBAction)clickAuthButton:(id)sender;
- (void)displayThermostats;

@end
