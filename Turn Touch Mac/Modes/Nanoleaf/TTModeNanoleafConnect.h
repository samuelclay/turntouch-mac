//
//  TTModeNanoleafConnect.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTOptionsDetailViewController.h"
#import "TTModeNanoleaf.h"

@interface TTModeNanoleafConnect : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeNanoleaf *modeNanoleaf;

- (void)setStoppedWithMessage:(NSString *)message;

- (IBAction)searchForDevice:(id)sender;

@end
