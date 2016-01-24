//
//  TTModeWemoConnect.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemoConnect.h"

@interface TTModeWemoConnect ()

@end

@implementation TTModeWemoConnect

@synthesize authButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Actions

- (IBAction)clickAuthButton:(id)sender {
    [self.modeWemo beginConnectingToWemo];
}

@end
