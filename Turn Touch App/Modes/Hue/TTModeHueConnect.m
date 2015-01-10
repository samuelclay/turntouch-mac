//
//  TTModeHueConnect.m
//  Turn Touch App
//
//  Created by Samuel Clay on 1/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTModeHueOptions.h"
#import "TTModeHueConnect.h"

@interface TTModeHueConnect ()

@property (nonatomic,weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic,weak) IBOutlet NSTextField *progressMessage;

@end

@implementation TTModeHueConnect

- (void)setStoppedWithMessage:(NSString*)message{
    self.progressMessage.stringValue = message;
    [self.progressIndicator stopAnimation:self];
}

- (void)setLoadingWithMessage:(NSString*)message{
    self.progressMessage.stringValue = message;
    [self.progressIndicator startAnimation:self];
}

#pragma mark - Actions

- (IBAction)searchForBridge:(id)sender {
    [self setLoadingWithMessage:@"Searching for Hue..."];
    [((TTModeHueOptions *)appDelegate.panelController.backgroundView.optionsView.modeOptionsViewController) searchForBridgeLocal];
}

@end
