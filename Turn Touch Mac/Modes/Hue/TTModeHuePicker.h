//
//  TTModeHuePicker.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 12/23/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@interface TTModeHuePicker : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSPopUpButton *roomDropdown;
@property (nonatomic) IBOutlet NSProgressIndicator *roomSpinner;
@property (nonatomic) IBOutlet NSButton *roomRefreshButton;

- (IBAction)didChangeRoom:(id)sender;

@end
