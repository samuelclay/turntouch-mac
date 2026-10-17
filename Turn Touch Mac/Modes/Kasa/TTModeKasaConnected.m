//
//  TTModeKasaConnected.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasaConnected.h"

@implementation TTModeKasaConnected

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateConnected];
}

- (void)updateConnected {
    NSInteger count = [TTModeKasa foundDevices].count;
    if (count > 0) {
        [self.connectedLabel setStringValue:[NSString stringWithFormat:TTText(@"Connected Kasa devices: %ld"), (long)count]];
    } else {
        [self.connectedLabel setStringValue:TTText(@"No Kasa devices found")];
    }

    // Show/hide credentials button based on whether KLAP devices exist
    if (self.credentialsButton) {
        self.credentialsButton.hidden = ![TTModeKasa hasKLAPDevices];
    }
}

- (IBAction)scanForDevices:(id)sender {
    [self.modeKasa beginConnectingToKasa];
}

- (IBAction)enterCredentials:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:TTText(@"TP-Link Kasa Credentials")];
    [alert setInformativeText:TTText(@"Enter your TP-Link/Kasa account credentials for newer devices that use KLAP authentication.")];
    [alert addButtonWithTitle:TTText(@"Save")];
    [alert addButtonWithTitle:TTText(@"Cancel")];

    NSView *accessoryView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 58)];

    NSTextField *usernameField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 32, 300, 22)];
    usernameField.placeholderString = TTText(@"Email / Username");

    NSDictionary *creds = [TTModeKasa loadCredentials];
    if (creds) {
        usernameField.stringValue = creds[@"username"];
    }

    NSSecureTextField *passwordField = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 4, 300, 22)];
    passwordField.placeholderString = TTText(@"Password");

    [accessoryView addSubview:usernameField];
    [accessoryView addSubview:passwordField];
    [alert setAccessoryView:accessoryView];

    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        NSString *username = usernameField.stringValue;
        NSString *password = passwordField.stringValue;
        if (username.length > 0 && password.length > 0) {
            [TTModeKasa saveCredentialsUsername:username password:password];
            // Re-authenticate KLAP devices
            [self.modeKasa refreshDevices];
        }
    }
}

@end
