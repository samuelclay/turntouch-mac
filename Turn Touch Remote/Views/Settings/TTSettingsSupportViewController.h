//
//  TTSettingsSupportViewController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RHPreferences.h"

@interface TTSettingsSupportViewController : NSViewController
<RHPreferencesViewControllerProtocol>

@property (nonatomic) IBOutlet NSButton *emailButton;

- (IBAction)openSupportEmail:(id)sender;

@end
