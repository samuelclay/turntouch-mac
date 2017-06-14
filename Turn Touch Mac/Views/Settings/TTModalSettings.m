//
//  TTModalSettings.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/14/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModalSettings.h"

@interface TTModalSettings ()

@end

@implementation TTModalSettings

@synthesize checkboxRecordUsage;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    checkboxRecordUsage.state = [prefs boolForKey:@"TT:pref:share_usage_stats"];
}

- (void)closeModal:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

- (void)changeForm:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:checkboxRecordUsage.state]
              forKey:@"TT:pref:share_usage_stats"];
    [prefs synchronize];
}
@end
