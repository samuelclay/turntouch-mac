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
@synthesize checkboxShowActionHud;
@synthesize checkboxEnableHud;
@synthesize checkboxShowModeHud;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    checkboxShowActionHud.state = [prefs boolForKey:@"TT:pref:show_action_hud"];
    checkboxShowModeHud.state = [prefs boolForKey:@"TT:pref:show_mode_hud"];
    checkboxRecordUsage.state = [prefs boolForKey:@"TT:pref:share_usage_stats"];
    checkboxEnableHud.state = [prefs boolForKey:@"TT:pref:enable_hud"];
}

- (void)closeModal:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

- (void)changeForm:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:checkboxShowActionHud.state]
              forKey:@"TT:pref:show_action_hud"];
    [prefs setObject:[NSNumber numberWithBool:checkboxShowModeHud.state]
              forKey:@"TT:pref:show_mode_hud"];
    [prefs setObject:[NSNumber numberWithBool:checkboxRecordUsage.state]
              forKey:@"TT:pref:share_usage_stats"];
    [prefs setObject:[NSNumber numberWithBool:checkboxEnableHud.state]
              forKey:@"TT:pref:enable_hud"];
    [prefs synchronize];
}
@end
