// Standalone integration tests: compile the production client, exercise HTTP with a local fixture.
#import <Foundation/Foundation.h>
#import "TTHomeAssistantClient.h"

static int assertions;
static void Check(BOOL condition, NSString *message) {
    assertions++;
    if (!condition) { fprintf(stderr, "FAIL: %s\n", message.UTF8String); exit(1); }
}
static id Wait(void (^start)(TTHACompletion), BOOL expectError) {
    __block BOOL done = NO; __block NSError *failure; __block id output;
    start(^(id result, NSError *error) { output = result; failure = error; done = YES; });
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:8];
    while (!done && deadline.timeIntervalSinceNow > 0) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    Check(done, @"request completed");
    Check(expectError == (failure != nil), failure.localizedDescription ?: @"expected failure");
    return output;
}
@interface TTHomeAssistantClient (KeychainTest)
- (NSDictionary *)readCredentialsForURL:(NSString *)url;
@end
static BOOL keychainReadOffMain;
@interface KeychainProbeClient : TTHomeAssistantClient
@end
@implementation KeychainProbeClient
- (NSDictionary *)readCredentialsForURL:(NSString *)url {
    keychainReadOffMain = !NSThread.isMainThread;
    return [super readCredentialsForURL:url];
}
@end
int main(int argc, char **argv) {
    @autoreleasepool {
        // Avoid sharing the app's server preference during tests.
        NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
        id originalURL = [defaults objectForKey:@"TT:HomeAssistant:URL"];
        NSString *server = [NSString stringWithUTF8String:argv[1]];
        Check([[TTHomeAssistantClient normalizedURL:@"  homeassistant.local:8123/ "] isEqual:@"http://homeassistant.local:8123"], @"local URL normalization");
        for (NSString *bad in @[@"", @"ftp://home.local", @"http://user:password@home.local", @"http://home.local/#fragment", @"http://home.local?token=x", @"http://home.local:99999"]) Check([TTHomeAssistantClient normalizedURL:bad] == nil, @"reject ambiguous/unsafe URL");
        NSError *error;
        NSDictionary *body = [TTHomeAssistantClient serviceBodyForEntity:@"light.desk" data:@"{\"brightness_pct\":45}" error:&error];
        Check([body[@"brightness_pct"] isEqual:@45] && [body[@"entity_id"] isEqual:@"light.desk"], @"service data and target preserved");
        for (NSString *bad in @[@"[]", @"broken", @"{\"entity_id\":\"all\"}", @"{\"area_id\":\"kitchen\"}", @"{\"target\":{}}"])
            Check([TTHomeAssistantClient serviceBodyForEntity:@"light.desk" data:bad error:&error] == nil, @"invalid data cannot broaden target");
        NSDictionary *services = @{@"scene": @{@"turn_on": @{@"target": @{}}, @"reload": @{}}, @"sensor": @{}};
        NSArray *actions = [TTHomeAssistantClient actionsForEntity:@{@"entity_id": @"scene.evening"} services:services];
        Check(actions.count == 1 && [actions[0][@"id"] isEqual:@"scene.turn_on"] && [actions[0][@"name"] isEqual:@"Activate scene"], @"scene activation excludes reload");
        Check([TTHomeAssistantClient actionsForEntity:@{@"entity_id": @"sensor.temperature"} services:services].count == 0, @"read-only sensor has no invented action");
        TTHomeAssistantClient *client = [[TTHomeAssistantClient alloc] init];
        Wait(^(TTHACompletion c) { [client connectToURL:server token:@"invalid" completion:c]; }, YES);
        Wait(^(TTHACompletion c) { [client connectToURL:server token:@"fixture-token" completion:c]; }, NO);
        Check(client.connected && client.entities.count == 3, @"authenticated catalog loaded");
        Check([client.services[@"light"] isKindOfClass:NSDictionary.class], @"live action catalog loaded");
        Wait(^(TTHACompletion c) { [client callAction:@"light.turn_on" entity:@"light.desk" data:@"{\"brightness_pct\":45}" completion:c]; }, NO);
        Wait(^(TTHACompletion c) { [client callAction:@"automation.trigger" entity:@"automation.evening" data:@"{}" completion:c]; }, NO);
        Wait(^(TTHACompletion c) { [client callAction:@"light.redirect" entity:@"light.desk" data:@"{}" completion:c]; }, YES);
        Wait(^(TTHACompletion c) { [client callAction:@"light.denied" entity:@"light.desk" data:@"{}" completion:c]; }, YES);
        Wait(^(TTHACompletion c) { [client callAction:@"light/evil.turn_on" entity:@"light.desk" data:@"{}" completion:c]; }, YES);
        Wait(^(TTHACompletion c) { [client exchangeCode:@"fixture-code" serverURL:server completion:c]; }, NO);
        // Fixture returns a short-lived token, so this exercises serialized refresh as well.
        Wait(^(TTHACompletion c) { [client callAction:@"scene.turn_on" entity:@"scene.evening" data:@"{}" completion:c]; }, NO);
        TTHomeAssistantClient *restored = [[KeychainProbeClient alloc] init];
        Check(TTHomeAssistantClient.isAwaitingKeychainAuthorization, @"panel protection is active while Keychain authorization is pending");
        Check(restored.restoringConnection && !restored.connected, @"initializer returns before Keychain authorization finishes");
        Wait(^(TTHACompletion c) { [restored refreshCatalog:c]; }, NO);
        Check(restored.connected, @"connection restored asynchronously from Keychain");
        Check(keychainReadOffMain, @"Keychain read never blocks the AppKit main thread");
        TTHomeAssistantClient *cancelled = [[TTHomeAssistantClient alloc] init];
        [cancelled disconnect];
        Wait(^(TTHACompletion c) { [cancelled refreshCatalog:c]; }, YES);
        Check(!cancelled.connected, @"pending Keychain restore cannot undo disconnect");
        Check(!TTHomeAssistantClient.isAwaitingKeychainAuthorization, @"panel protection ends when Keychain finishes, including cancelled restores");
        [client disconnect];
        TTHomeAssistantClient *disconnected = [[TTHomeAssistantClient alloc] init];
        Wait(^(TTHACompletion c) { [disconnected refreshCatalog:c]; }, YES);
        Check(!disconnected.connected, @"disconnect removes Keychain credentials");
        Wait(^(TTHACompletion c) { [client callAction:@"light.toggle" entity:@"light.desk" data:@"{}" completion:c]; }, YES);
        if (originalURL) [defaults setObject:originalURL forKey:@"TT:HomeAssistant:URL"]; else [defaults removeObjectForKey:@"TT:HomeAssistant:URL"];
        printf("PASS: %d assertions, including authenticated HTTP, action dispatch, errors, OAuth refresh, and Keychain persistence.\n", assertions);
    }
}
