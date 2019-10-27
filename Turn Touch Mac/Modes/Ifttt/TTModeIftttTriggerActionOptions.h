//
//  TTModeIftttTriggerActionOptions.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "TTAppDelegate.h"
#import "TTModeIfttt.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeIftttTriggerActionOptions : TTOptionsDetailViewController <WebResourceLoadDelegate, NSMenuDelegate>

@property (nonatomic) TTModeIfttt *modeIfttt;
@property (nonatomic) NSPopover *authPopover;
@property (nonatomic) IBOutlet NSButton *settingsButton;
@property (nonatomic) IBOutlet NSButton *chooseButton;

- (IBAction)clickRecipeButton:(id)sender;
- (IBAction)showIftttMenu:(id)sender;

@end
