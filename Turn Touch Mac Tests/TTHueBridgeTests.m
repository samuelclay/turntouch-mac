#import <Cocoa/Cocoa.h>
#import "TTHueBridge.h"
@interface TTHueClient (Testing)
- (void)refresh:(void (^)(NSError *))completion;
- (void)request:(NSString *)path method:(NSString *)method body:(NSDictionary *)body authenticated:(BOOL)authenticated completion:(void (^)(id, NSError *))completion;
@end
static int count;
static void Check(BOOL ok, NSString *message) { count++; if (!ok) { fprintf(stderr, "FAIL: %s\n", message.UTF8String); exit(1); } }
static void Wait(void (^start)(void (^)(NSArray *)), BOOL expectedError) {
    __block BOOL done=NO; __block NSArray *errors;
    start(^(NSArray *result){ errors=result; done=YES; });
    NSDate *deadline=[NSDate dateWithTimeIntervalSinceNow:8];
    while (!done && deadline.timeIntervalSinceNow>0) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.01]];
    Check(done, @"callback completes"); Check((errors.count>0)==expectedError, @"expected success or Hue error");
}
int main(int argc, char **argv) {
    @autoreleasepool {
        TTHueClient *client = TTHueClient.sharedClient;
        [client setValue:[NSString stringWithUTF8String:argv[1]] forKey:@"address"];
        [client setValue:@"fixture-token" forKey:@"username"];
        TTHueLightState *state=[TTHueLightState new]; state.on=@YES; state.brightness=@255; state.saturation=@255;
        Check([state.JSON[@"bri"] isEqual:@254] && [state.JSON[@"sat"] isEqual:@254], @"Hue limits prevent out-of-range writes");
        state.x=@.4; state.y=@.3; state.hue=@2000;
        Check(state.JSON[@"hue"]==nil && state.JSON[@"sat"]==nil && [state.JSON[@"xy"] isEqual:@[@.4,@.3]], @"XY removes conflicting hue/saturation");
        CGPoint black=[TTHueColor calculateXY:NSColor.blackColor forModel:@""];
        Check(isfinite(black.x) && isfinite(black.y), @"black conversion avoids NaN");
        Wait(^(void (^c)(NSArray *)){ [client refresh:^(NSError *error){c(error ? @[error] : @[]);}]; }, NO);
        Check(client.localConnected, @"native bridge connection works");
        TTHueBridgeResources *cache=TTHueResourcesReader.readBridgeResourcesCache;
        Check(cache.lights.count==2 && cache.groups.count==1 && cache.scenes.count==1, @"catalog models retain lights rooms and scenes");
        TTHueCommands *commands=[TTHueCommands new];
        Wait(^(void (^c)(NSArray *)){ [commands updateLightStateForId:@"1" withLightState:state completionHandler:c]; }, NO);
        TTHueLightState *increment=[TTHueLightState new]; increment.on=@YES; increment.brightnessIncrement=@(-25);
        Wait(^(void (^c)(NSArray *)){ [commands setLightStateForGroupWithId:@"3" lightState:increment completionHandler:c]; }, NO);
        Wait(^(void (^c)(NSArray *)){ [commands activateSceneWithIdentifier:@"evening" onGroup:@"3" completionHandler:c]; }, NO);
        TTHueLightState *fade=[TTHueLightState new]; fade.on=@NO; fade.transitionTime=@100;
        Wait(^(void (^c)(NSArray *)){ [commands saveLightState:fade forLightIdentifier:@"2" inSceneWithIdentifier:@"evening" completionHandler:c]; }, NO);
        Wait(^(void (^c)(NSArray *)){ [commands activateSceneWithIdentifier:@"error" onGroup:@"3" completionHandler:c]; }, YES);
        Wait(^(void (^c)(NSArray *)){ [client request:@"/redirect" method:@"GET" body:nil authenticated:YES completion:^(id result,NSError *error){ c(error ? @[error] : @[]); }]; }, YES);
        printf("PASS: %d native Hue assertions.\n",count);
    }
}
