//
//  TTModalSettings.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/14/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTModalSettings : NSViewController

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) IBOutlet NSButton *checkboxRecordUsage;
@property (nonatomic) IBOutlet NSButton *checkboxShowActionHud;
@property (nonatomic) IBOutlet NSButton *checkboxShowModeHud;
@property (nonatomic) IBOutlet NSButton *checkboxEnableHud;
@property (nonatomic) IBOutlet NSButton *checkboxPerformActions;

- (IBAction)closeModal:(id)sender;
- (IBAction)changeForm:(id)sender;

@end
