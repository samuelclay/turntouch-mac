//
//  TTModeIftttConnecting.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIftttConnecting.h"

@interface TTModeIftttConnecting ()

@end

@implementation TTModeIftttConnecting

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setConnectingWithMessage:(NSString*)message {
    if (!message) message = @"Connecting to Ifttt...";
    
    self.progressMessage.stringValue = message;
    [self.progressIndicator startAnimation:self];
}

- (IBAction)clickCancelButton:(id)sender {
    [self.modeIfttt cancelConnectingToIfttt];
}

@end
