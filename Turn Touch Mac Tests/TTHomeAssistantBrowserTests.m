#import <Cocoa/Cocoa.h>
#import "TTHomeAssistantClient.h"
#import "TTHomeAssistantWindowController.h"
@interface TTHomeAssistantWindowController (Tests)
- (void)filter:(id)sender;
- (void)save:(id)sender;
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
        TTHomeAssistantWindowController *window = [[TTHomeAssistantWindowController alloc] init];
        __block NSDictionary *saved;
        window.saveHandler = ^(NSDictionary *binding) { saved = binding; };
        [window setValue:@{@"entity_id": @"light.desk", @"service": @"light.turn_off"} forKey:@"initialBinding"];
        [window setValue:@"light.desk" forKey:@"selectedEntityID"];
        [window filter:nil];
        NSPopUpButton *picker = [window valueForKey:@"actionPicker"];
        NSTextView *editor = [window valueForKey:@"dataEditor"];
        NSSearchField *search = [window valueForKey:@"search"];
        Check([[window valueForKey:@"filtered"] count] == 2, @"default browser hides read-only sensors");
        Check([picker.selectedItem.representedObject isEqual:@"light.turn_off"], @"saved action restores instead of default toggle");
        editor.string = @"{\"transition\": 2}";
        [window filter:nil];
        Check([picker.selectedItem.representedObject isEqual:@"light.turn_off"], @"refresh preserves edited action");
        Check([editor.string isEqual:@"{\"transition\": 2}"], @"refresh preserves edited data");
        search.stringValue = @"Study"; [window filter:nil];
        Check([[window valueForKey:@"filtered"] count] == 1, @"search matches room registry metadata");
        search.stringValue = @"Desk bulb"; [window filter:nil];
        Check([[window valueForKey:@"filtered"] count] == 1, @"search matches device registry metadata");
        [window save:nil];
        Check([saved[@"entity_id"] isEqual:@"light.desk"] && [saved[@"service"] isEqual:@"light.turn_off"] && [saved[@"data"] isEqual:editor.string], @"save returns exact selected binding");
        saved = nil; editor.string = @"{\"entity_id\":\"all\"}"; [window save:nil];
        Check(saved == nil, @"invalid data cannot be saved");
        search.stringValue = @"missing"; [window filter:nil];
        Check(![[window valueForKey:@"saveButton"] isEnabled] && ![[window valueForKey:@"testButton"] isEnabled], @"empty search cannot dispatch a stale selection");
        search.stringValue = @"Evening"; [window filter:nil];
        [[window valueForKey:@"table"] selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        Check([[window valueForKey:@"testButton"] isEnabled], @"scene can activate before its first recorded state");
        [window close];
        printf("PASS: %d native AppKit browser assertions.\n", assertions);
    }
}
