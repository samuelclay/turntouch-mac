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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (TTAppDelegate *)[NSApp delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.checkboxShowActionHud.state = [prefs boolForKey:@"TT:pref:show_action_hud"];
    self.checkboxShowShortcutHud.state = [prefs boolForKey:@"TT:pref:show_shortcut_hud"];
    self.checkboxShowModeHud.state = [prefs boolForKey:@"TT:pref:show_mode_hud"];
    self.checkboxRecordUsage.state = [prefs boolForKey:@"TT:pref:share_usage_stats"];
    self.checkboxEnableHud.state = [prefs boolForKey:@"TT:pref:enable_hud"];
    self.checkboxPerformActions.state = [prefs integerForKey:@"TT:pref:action_mode"];
    
    self.shortcutView.enabled = self.checkboxShowShortcutHud.state == NSOnState;
    self.shortcutView.style = MASShortcutViewStyleTexturedRect;
    self.shortcutView.associatedUserDefaultsKey = @"TT:shortcut:hud";
}

- (void)closeModal:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

- (void)changeForm:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:self.checkboxShowActionHud.state]
              forKey:@"TT:pref:show_action_hud"];
    [prefs setObject:[NSNumber numberWithBool:self.checkboxShowShortcutHud.state]
              forKey:@"TT:pref:show_shortcut_hud"];
    [prefs setObject:[NSNumber numberWithBool:self.checkboxShowModeHud.state]
              forKey:@"TT:pref:show_mode_hud"];
    [prefs setObject:[NSNumber numberWithBool:self.checkboxRecordUsage.state]
              forKey:@"TT:pref:share_usage_stats"];
    [prefs setObject:[NSNumber numberWithBool:self.checkboxEnableHud.state]
              forKey:@"TT:pref:enable_hud"];
    [prefs setObject:[NSNumber numberWithInteger:self.checkboxPerformActions.state]
              forKey:@"TT:pref:action_mode"];
    [prefs synchronize];
    
    self.shortcutView.enabled = self.checkboxShowShortcutHud.state == NSOnState;
}
@end
