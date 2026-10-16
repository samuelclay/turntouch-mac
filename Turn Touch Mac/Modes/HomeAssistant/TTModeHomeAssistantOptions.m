#import "TTModeHomeAssistantOptions.h"
#import "TTHomeAssistantWindowController.h"
#import "TTHomeAssistantClient.h"
#import "TTOptionsDetailView.h"

@implementation TTModeHomeAssistantOptions
- (void)loadView {
    self.view = [[TTOptionsDetailView alloc] initWithFrame:NSMakeRect(0, 0, 320, 100)];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100]];
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(20, 51, 280, 30)];
    button.bezelStyle = NSBezelStyleRounded;
    button.title = self.action ? @"Choose Home Assistant action…" : @"Connect to Home Assistant…";
    button.target = self; button.action = @selector(openBrowser:);
    [self.view addSubview:button];
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 10, 280, 36)];
    label.editable = NO; label.bordered = NO; label.drawsBackground = NO;
    label.font = [NSFont systemFontOfSize:11]; label.textColor = NSColor.secondaryLabelColor;
    NSDictionary *binding = [self.action optionValue:@"homeAssistantBinding"];
    label.stringValue = binding ? [NSString stringWithFormat:@"%@ · %@", binding[@"name"], binding[@"service"]] : @"Search lights, scenes, scripts, and more.\nNo Home Assistant plugin needed.";
    [self.view addSubview:label];
}
- (void)openBrowser:(id)sender {
    // Keep the window alive when the menu-bar panel closes or changes modes.
    static TTHomeAssistantWindowController *browser;
    if (!browser) browser = [[TTHomeAssistantWindowController alloc] init];
    TTAction *action = self.action;
    if (action) {
        // Capture the preference key now: selection in the menu bar can change while this window is open.
        TTModeMap *map = self.appDelegate.modeMap;
        NSString *modeDirection = [map directionName:action.mode.modeDirection];
        NSString *actionDirection = [map directionName:action.direction];
        NSString *key = action.batchActionKey ?
            [NSString stringWithFormat:@"TT:mode:%@:action:%@:batchactions:%@:actionoption:homeAssistantBinding", modeDirection, actionDirection, action.batchActionKey] :
            [NSString stringWithFormat:@"TT:mode:%@-%@:action:%@-%@:option:homeAssistantBinding", NSStringFromClass(action.mode.class), modeDirection, action.actionName, actionDirection];
        browser.saveHandler = ^(NSDictionary *binding) {
            [[NSUserDefaults standardUserDefaults] setObject:binding forKey:key];
            [NSAppDelegate.panelController.backgroundView.optionsView redrawOptions];
            [NSAppDelegate.panelController.backgroundView setNeedsDisplay:YES];
        };
    } else browser.saveHandler = nil;
    [browser showWithBinding:[action optionValue:@"homeAssistantBinding"]];
}
@end
@implementation TTModeHomeAssistantActionOptions
@end
