//
//  TTModeNanoleafConnect.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTModeNanoleafConnect.h"

@interface TTModeNanoleafConnect ()

@property (nonatomic, weak) IBOutlet NSTextField *titleLabel;
@property (nonatomic, weak) IBOutlet NSTextField *subtitleLabel;

@end

@implementation TTModeNanoleafConnect

- (void)setStoppedWithMessage:(NSString *)message {
    if (!message) {
        self.titleLabel.stringValue = @"Find your Nanoleaf";
        self.subtitleLabel.stringValue = @"Make sure your Nanoleaf panels are powered on\nand connected to the same Wi-Fi network.";
    } else if ([message isEqualToString:@"No Nanoleaf devices found"]) {
        self.titleLabel.stringValue = @"No Nanoleaf found";
        self.subtitleLabel.stringValue = @"Make sure your Nanoleaf panels are powered on\nand connected to the same Wi-Fi network.";
    } else if ([message isEqualToString:@"No network interfaces found"]) {
        self.titleLabel.stringValue = @"No network connection";
        self.subtitleLabel.stringValue = @"Please connect to Wi-Fi and try again.";
    } else {
        self.titleLabel.stringValue = message;
        self.subtitleLabel.stringValue = @"Make sure your Nanoleaf panels are powered on\nand connected to the same Wi-Fi network.";
    }
}

#pragma mark - Actions

- (IBAction)searchForDevice:(id)sender {
    self.titleLabel.stringValue = @"Searching for Nanoleaf...";
    self.subtitleLabel.stringValue = @"Scanning your local network for Nanoleaf panels.";
    [self.modeNanoleaf findDevices];
}

@end
