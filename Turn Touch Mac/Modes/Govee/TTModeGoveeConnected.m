//
//  TTModeGoveeConnected.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGoveeConnected.h"

@implementation TTModeGoveeConnected

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateConnected];
}

- (void)updateConnected {
    NSInteger count = [TTModeGovee foundDevices].count;
    if (count > 0) {
        [self.connectedLabel setStringValue:[NSString stringWithFormat:@"Connected to %ld Govee device%@",
                                             (long)count, count == 1 ? @"" : @"s"]];
    } else {
        [self.connectedLabel setStringValue:@"No Govee devices found"];
    }
}

- (IBAction)scanForDevices:(id)sender {
    [self.modeGovee beginConnectingToGovee];
}

- (IBAction)changeApiKey:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Govee API Key"];
    [alert setInformativeText:@"Enter your Govee API key (from Govee Home App > Settings > My Profile > Apply for API Key)"];
    [alert addButtonWithTitle:@"Save"];
    [alert addButtonWithTitle:@"Cancel"];

    NSTextField *apiKeyField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 22)];
    apiKeyField.placeholderString = @"API Key";

    NSString *existingKey = [TTModeGovee loadApiKey];
    if (existingKey) {
        apiKeyField.stringValue = existingKey;
    }

    [alert setAccessoryView:apiKeyField];

    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        NSString *apiKey = [apiKeyField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (apiKey.length > 0) {
            [TTModeGovee saveApiKey:apiKey];
            [[TTModeGovee apiClient] setApiKey:apiKey];
            [self.modeGovee refreshDevices];
        }
    }
}

@end
