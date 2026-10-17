#import "TTModeHomeAssistantOptions.h"
#import "TTHomeAssistantViewController.h"
#import "TTOptionsDetailView.h"

@interface TTHomeAssistantOptionsView : TTOptionsDetailView
@end
@implementation TTHomeAssistantOptionsView
- (BOOL)isFlipped { return YES; }
@end

@interface TTModeHomeAssistantOptions ()
@property TTHomeAssistantViewController *browser;
@end

@implementation TTModeHomeAssistantOptions
- (void)loadView {
    self.view = [[TTHomeAssistantOptionsView alloc] initWithFrame:NSMakeRect(0, 0, 380, 470)];
    self.browser = [[TTHomeAssistantViewController alloc] init];
    TTAction *action = self.action;
    if (action) {
        TTModeMap *map = NSAppDelegate.modeMap;
        NSString *bank = [map directionName:action.mode.modeDirection];
        NSString *direction = [map directionName:action.direction];
        NSString *key = action.batchActionKey ?
            [NSString stringWithFormat:@"TT:mode:%@:action:%@:batchactions:%@:actionoption:homeAssistantBinding", bank, direction, action.batchActionKey] :
            [NSString stringWithFormat:@"TT:mode:%@-%@:action:%@-%@:option:homeAssistantBinding", NSStringFromClass(action.mode.class), bank, action.actionName, direction];
        self.browser.saveHandler = ^(NSDictionary *binding) {
            [NSUserDefaults.standardUserDefaults setObject:binding forKey:key];
            // Refresh labels without rebuilding the editor or losing the search.
            [NSAppDelegate.panelController.backgroundView.diamondLabels setNeedsDisplay:YES];
            for (NSView *view in NSAppDelegate.panelController.backgroundView.batchActionStackView.subviews) [view setNeedsDisplay:YES];
        };
    }
    self.browser.interactionHandler = ^(BOOL active) { NSAppDelegate.panelController.preventClosing = active; };
    [self addChildViewController:self.browser];
    [self.view addSubview:self.browser.view];
    [NSLayoutConstraint activateConstraints:@[
        [self.view.widthAnchor constraintEqualToConstant:380],
        [self.browser.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.browser.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.browser.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.browser.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    [self.browser loadBinding:[action optionValue:@"homeAssistantBinding"]];
}
@end
@implementation TTModeHomeAssistantActionOptions
@end
