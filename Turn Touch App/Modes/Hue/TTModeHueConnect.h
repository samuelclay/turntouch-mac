//
//  TTModeHueConnect.h
//  Turn Touch App
//
//  Created by Samuel Clay on 1/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTOptionsDetailViewController.h"
#import "TTModeHue.h"

@interface TTModeHueConnect : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeHue *modeHue;

- (void)setStoppedWithMessage:(NSString*)message;
- (void)setLoadingWithMessage:(NSString*)message;

- (IBAction)searchForBridge:(id)sender;

@end
