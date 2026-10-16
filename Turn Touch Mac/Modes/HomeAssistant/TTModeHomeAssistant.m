#import "TTModeHomeAssistant.h"
#import "TTHomeAssistantClient.h"
@implementation TTModeHomeAssistant
+ (NSString *)title { return @"Home Assistant"; }
+ (NSString *)description { return @"Your home, scenes, and automations"; }
+ (NSString *)imageName { return @"mode_home.png"; }
- (NSArray *)actions { return @[@"TTModeHomeAssistantAction"]; }
- (NSString *)defaultNorth { return @"TTModeHomeAssistantAction"; }
- (NSString *)defaultEast { return @"TTModeHomeAssistantAction"; }
- (NSString *)defaultWest { return @"TTModeHomeAssistantAction"; }
- (NSString *)defaultSouth { return @"TTModeHomeAssistantAction"; }
- (NSString *)titleTTModeHomeAssistantAction { return @"Home Assistant action"; }
- (NSString *)imageTTModeHomeAssistantAction { return @"mode_home.png"; }
- (NSString *)titleInDirection:(TTModeDirection)direction buttonMoment:(TTButtonMoment)moment {
    NSDictionary *binding = [self.appDelegate.modeMap mode:self actionOptionValue:@"homeAssistantBinding" actionName:@"TTModeHomeAssistantAction" inDirection:direction];
    return binding[@"name"] ?: [super titleInDirection:direction buttonMoment:moment];
}
- (void)runTTModeHomeAssistantAction {
    NSDictionary *binding = [self.action optionValue:@"homeAssistantBinding"];
    TTHomeAssistantClient *client = TTHomeAssistantClient.sharedClient;
    if (![binding[@"entity_id"] length] || ![binding[@"server_url"] isEqual:client.serverURL]) {
        NSBeep();
        NSLog(@"Home Assistant: configure this button for the connected home first.");
        return;
    }
    [client callAction:binding[@"service"] entity:binding[@"entity_id"] data:binding[@"data"] completion:^(id result, NSError *error) {
        if (error) { NSBeep(); NSLog(@"Home Assistant action failed: %@", error.localizedDescription); }
    }];
}
@end
