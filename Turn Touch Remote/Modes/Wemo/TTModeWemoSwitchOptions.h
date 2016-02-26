//
//  TTModeWemoSwitchOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemo.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeWemoSwitchOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSPopUpButton *devicePopup;

- (IBAction)didChangeDevice:(id)sender;

@end
