//
//  TTModeSonosConnecting.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/18/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeSonosConnecting.h"

@interface TTModeSonosConnecting ()

@end

@implementation TTModeSonosConnecting

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setConnectingWithMessage:(NSString*)message {
    if (!message) message = @"Connecting to Sonos...";
    
    self.progressMessage.stringValue = message;
    [self.progressIndicator startAnimation:self];
}

- (IBAction)clickCancelButton:(id)sender {
    [self.modeSonos cancelConnectingToSonos];
}

@end
