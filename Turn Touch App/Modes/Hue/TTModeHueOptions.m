//
//  TTModeHueOptions.m
//  Turn Touch App
//
//  Created by Samuel Clay on 1/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHueOptions.h"
#import "TTModeHueConnect.h"

@interface TTModeHueOptions ()

@property (nonatomic, strong) TTModeHueConnect *connectViewController;

@end

@implementation TTModeHueOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // No Hue found, show connection button
    [self showLoadingViewWithText:NSLocalizedString(@"Connect to your Hue...", @"Searching for bridges text")];
}


- (void)showLoadingViewWithText:(NSString*)message{
    if (self.connectViewController == nil) {
        self.connectViewController = [[TTModeHueConnect alloc] initWithNibName:@"TTModeHueConnect" bundle:[NSBundle mainBundle]];
    }
    if (self.connectViewController.view) {
        [self.connectViewController.view removeFromSuperview];
    }
    [appDelegate.panelController.backgroundView.optionsView drawModeOptions:self.connectViewController];
    
    NSLog(@"Connect frame: %@", NSStringFromRect(self.connectViewController.view.frame));
    [self.connectViewController setLoadingWithMessage:message];
}

@end
