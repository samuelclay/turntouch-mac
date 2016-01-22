//
//  TTModeNestConnected.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNest.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeNestConnected : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeNest *modeNest;
@property (nonatomic) IBOutlet NSTextField *labelAmbient;
@property (nonatomic) IBOutlet NSTextField *labelTarget;
@property (nonatomic) IBOutlet NSPopUpButton *thermostatPopup;

- (IBAction)didChangeThermostat:(id)sender;

@end
