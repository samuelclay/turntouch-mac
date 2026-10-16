//
//  TTModeNanoleafConnected.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTOptionsDetailViewController.h"

@class TTModeNanoleaf;

@interface TTModeNanoleafConnected : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeNanoleaf *modeNanoleaf;

- (IBAction)selectOtherDevice:(id)sender;

@end
