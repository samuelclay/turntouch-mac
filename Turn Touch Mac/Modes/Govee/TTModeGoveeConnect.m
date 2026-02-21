//
//  TTModeGoveeConnect.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGoveeConnect.h"

@implementation TTModeGoveeConnect

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *existingKey = [TTModeGovee loadApiKey];
    if (existingKey) {
        [self.apiKeyField setStringValue:existingKey];
    }
}

- (IBAction)clickConnectButton:(id)sender {
    NSString *apiKey = [self.apiKeyField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (apiKey.length == 0) return;

    [TTModeGovee saveApiKey:apiKey];
    [[TTModeGovee apiClient] setApiKey:apiKey];
    [self.modeGovee beginConnectingToGovee];
}

@end
