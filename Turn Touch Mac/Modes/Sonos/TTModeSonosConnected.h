//
//  TTModeSonosConnected.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/18/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeSonos.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeSonosConnected : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeSonos *modeSonos;
@property (nonatomic) IBOutlet NSTextField *connectedLabel;
@property (nonatomic) IBOutlet TTChangeButtonView *scanButton;
@property (nonatomic) IBOutlet NSPopUpButton *deviceSelect;

- (IBAction)scanForDevices:(id)sender;

@end
