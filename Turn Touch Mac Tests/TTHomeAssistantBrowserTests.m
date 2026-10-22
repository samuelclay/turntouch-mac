#import <Cocoa/Cocoa.h>
#import "TTHomeAssistantClient.h"
#import "TTHomeAssistantViewController.h"
@interface TTHomeAssistantViewController (Tests)
- (void)filter:(id)sender;
- (void)save:(id)sender;
- (void)toggleAction:(id)sender;
- (void)toggleAdvanced:(id)sender;
- (void)actionChanged:(id)sender;
@end
static int assertions;
static void Check(BOOL condition, NSString *message) {
    assertions++; if (!condition) { fprintf(stderr, "FAIL: %s\n", message.UTF8String); exit(1); }
}
int main(void) {
    @autoreleasepool {
        [NSApplication sharedApplication];
        TTHomeAssistantClient *client = TTHomeAssistantClient.sharedClient;
        // In-memory catalog only: no real-home requests, credentials, or preference changes.
        [client setValue:@{@"access_token": @"in-memory-test-only"} forKey:@"credentials"];
        [client setValue:@"http://127.0.0.1:1" forKey:@"serverURL"];
        [client setValue:@{ @"light": @{@"toggle": @{@"target": @{}}, @"turn_on": @{@"target": @{}}, @"turn_off": @{@"target": @{}}},
                           @"scene": @{@"turn_on": @{@"target": @{}}} } forKey:@"services"];
        [client setValue:@[
            @{@"entity_id": @"light.desk", @"state": @"on", @"tt_area": @"Study", @"tt_device": @"Desk bulb", @"attributes": @{@"friendly_name": @"Desk"}},
            @{@"entity_id": @"scene.evening", @"state": @"unknown", @"attributes": @{@"friendly_name": @"Evening"}},
            @{@"entity_id": @"sensor.temperature", @"state": @"22", @"attributes": @{@"friendly_name": @"Temperature"}}] forKey:@"entities"];
        TTHomeAssistantViewController *window = [[TTHomeAssistantViewController alloc] init];
        (void)window.view;
        __block NSDictionary *saved;
        window.saveHandler = ^(NSDictionary *binding) { saved = binding; };
        [window setValue:@{@"entity_id": @"light.desk", @"service": @"light.turn_off"} forKey:@"initialBinding"];
        [window setValue:@"light.desk" forKey:@"selectedEntityID"];
        [window filter:nil];
        // In a window, optional stack hugging can preserve the expanded height
        // even though the editor's fittingSize is already smaller. Exercise
        // actual AppKit resizing, not just fittingSize on a detached view.
        NSView *changeMenu = [NSView new];
        NSLayoutConstraint *menuHeight = [changeMenu.heightAnchor constraintEqualToConstant:1];
        menuHeight.active = YES;
        NSStackView *panelContent = [NSStackView stackViewWithViews:@[changeMenu, window.view]];
        panelContent.orientation = NSUserInterfaceLayoutOrientationVertical;
        panelContent.spacing = 0;
        [panelContent setViews:@[changeMenu, window.view] inGravity:NSStackViewGravityTop];
        [panelContent setHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
        [panelContent.widthAnchor constraintEqualToConstant:380].active = YES;
        [window.view.widthAnchor constraintEqualToAnchor:panelContent.widthAnchor].active = YES;
        NSWindow *panel = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 380, 470)
            styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        panel.contentView = panelContent;
        [panelContent layoutSubtreeIfNeeded];
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.02]];
        CGFloat collapsedHeight = panelContent.fittingSize.height;
        [panel setContentSize:NSMakeSize(380, collapsedHeight)];
        for (NSInteger cycle = 0; cycle < 2; cycle++) {
            menuHeight.constant = 146;
            [panelContent layoutSubtreeIfNeeded];
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.02]];
            Check(fabs(NSHeight(panel.frame) - collapsedHeight - 145) < 1, @"Change grows the window to fit the menu");
            menuHeight.constant = 1;
            [panelContent layoutSubtreeIfNeeded];
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.02]];
            Check(fabs(NSHeight(panel.frame) - collapsedHeight) < 1, @"Cancel shrinks the window without blank space");
            [window toggleAction:nil];
            [panelContent layoutSubtreeIfNeeded];
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.02]];
            Check(NSHeight(panel.frame) > collapsedHeight, @"action settings expand the window");
            [window toggleAction:nil];
            [panelContent layoutSubtreeIfNeeded];
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.02]];
            Check(fabs(NSHeight(panel.frame) - collapsedHeight) < 1, @"collapsing action settings restores the original window height");
        }
        NSPopUpButton *picker = [window valueForKey:@"actionPicker"];
        NSTextView *editor = [window valueForKey:@"dataEditor"];
        NSSearchField *search = [window valueForKey:@"search"];
        Check([[window valueForKey:@"filtered"] count] == 2, @"default browser hides read-only sensors");
        Check([[window valueForKey:@"status"] isHidden], @"connected browser does not show a redundant entity count");
        Check([[window valueForKey:@"actionOptionsStack"] isHidden], @"advanced action options stay out of the default browsing view");
        Check([picker.selectedItem.representedObject isEqual:@"light.turn_off"], @"saved action restores instead of default toggle");
        Check(picker.hidden && [[window valueForKey:@"advancedStack"] isHidden], @"action details and JSON start collapsed");
        editor.string = @"{\"transition\": 2}";
        [window filter:nil];
        Check([picker.selectedItem.representedObject isEqual:@"light.turn_off"], @"refresh preserves edited action");
        Check([editor.string isEqual:@"{\"transition\": 2}"], @"refresh preserves edited data");
        search.stringValue = @"Study"; [window filter:nil];
        Check([[window valueForKey:@"filtered"] count] == 1, @"search matches room registry metadata");
        search.stringValue = @"Desk bulb"; [window filter:nil];
        Check([[window valueForKey:@"filtered"] count] == 1, @"search matches device registry metadata");
        window.buttonDestination = @"North · Single tap";
        [window save:nil];
        Check([[[window valueForKey:@"status"] stringValue] containsString:@"North · Single tap"] && [[[window valueForKey:@"status"] stringValue] containsString:@"Desk"], @"save confirmation identifies both destination and entity");
        Check([saved[@"entity_id"] isEqual:@"light.desk"] && [saved[@"service"] isEqual:@"light.turn_off"] && [saved[@"data"] isEqual:editor.string], @"save returns exact selected binding");
        saved = nil; editor.string = @"{\"entity_id\":\"all\"}"; [window save:nil];
        Check(saved == nil, @"invalid data cannot be saved");
        Check(![[window valueForKey:@"advancedStack"] isHidden], @"invalid data reveals the editor for correction");
        [window toggleAdvanced:nil];
        search.stringValue = @"missing"; [window filter:nil];
        Check(![[window valueForKey:@"saveButton"] isEnabled] && ![[window valueForKey:@"testButton"] isEnabled], @"empty search cannot dispatch a stale selection");
        search.stringValue = @"Evening"; [window filter:nil];
        [[window valueForKey:@"table"] selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        Check([[window valueForKey:@"testButton"] isEnabled], @"scene can activate before its first recorded state");
        Check([[window valueForKey:@"connectionStack"] isHidden] && [[window valueForKey:@"tokenStack"] isHidden], @"connection and token controls are hidden behind the menu");
        [window toggleAction:nil];
        Check(!picker.hidden, @"action disclosure reveals the service picker");
        [window toggleAction:nil];
        [window toggleAdvanced:nil];
        Check(![[window valueForKey:@"advancedStack"] isHidden], @"advanced disclosure reveals data editor");
        [window toggleAdvanced:nil];
        [window toggleAction:nil];
        Check(window.view.fittingSize.height < 550, @"collapsed editor fits the native options panel");
        NSPopUpButton *category = [window valueForKey:@"category"];
        [category selectItemAtIndex:1]; search.stringValue = @"Temperature"; [window filter:nil];
        [[window valueForKey:@"table"] selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        Check(![[window valueForKey:@"saveButton"] isEnabled] && ![[window valueForKey:@"testButton"] isEnabled], @"read-only entity cannot be assigned or tested");
        [window loadBinding:@{@"entity_id": @"light.desk", @"service": @"light.turn_off", @"data": @"{\"transition\":3}"}];
        Check([picker.selectedItem.representedObject isEqual:@"light.turn_off"] && [editor.string isEqual:@"{\"transition\":3}"], @"embedded editor restores full binding when opened for another button");
        [window loadBinding:@{@"entity_id": @"light.desk", @"service": @"light.turn_on", @"data": @"{}"}];
        Check([picker.selectedItem.representedObject isEqual:@"light.turn_on"], @"opening another binding for the same entity replaces the previous service");
        [window.view removeFromSuperview];
        printf("PASS: %d native AppKit browser assertions.\n", assertions);
    }
}
