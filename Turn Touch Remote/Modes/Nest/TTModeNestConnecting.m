//
//  TTModeNestConnecting.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestConnecting.h"

@interface TTModeNestConnecting ()

@end

@implementation TTModeNestConnecting

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setConnectingWithMessage:(NSString*)message {
    if (!message) message = @"Connecting to Nest...";
    
    self.progressMessage.stringValue = message;
    [self.progressIndicator startAnimation:self];
}

- (IBAction)clickCancelButton:(id)sender {
    [self.modeNest cancelConnectingToNest];
}

@end
