//
//  TTModeNest.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNest.h"
#import "NestAuthManager.h"
#import "FirebaseManager.h"

@implementation TTModeNest

NSString *const kNestThermostat = @"nestThermostatIdentifier";
NSString *const kNestSetTemperature = @"nestSetTemperature";
NSString *const kNestSetTemperatureMode = @"nestSetTemperatureMode";
NSString *const kNestApiHost = @"https://developer-api.nest.com/";
NSString *const kNestApiThermostats = @"devices/thermostats/";
NSString *const kNestApiStructures = @"structures/";

static NSDictionary *currentStructure;
static TTModeNestDelegateManager *delegateManager;

//@synthesize nestStructureManager;
//@synthesize nestThermostatManager;
//@synthesize currentStructure;
@synthesize delegate;
@synthesize nestState;

- (instancetype)init {
    if (self = [super init]) {
        if (!delegateManager) {
            delegateManager = [[TTModeNestDelegateManager alloc] init];
        }
        
        [delegateManager.delegates addObject:self];
    }
    
    return self;
}

- (NestStructureManager *)sharedNestStructureManager {
    static NestStructureManager *nestStructureManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nestStructureManager = [[NestStructureManager alloc] init];
    });
    return nestStructureManager;
}

- (NestThermostatManager *)sharedNestThermostatManager {
    static NestThermostatManager *nestThermostatManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nestThermostatManager = [[NestThermostatManager alloc] init];
    });
    return nestThermostatManager;
}

- (NSDictionary *)currentStructure {
    return currentStructure;
}

#pragma mark - Mode

+ (NSString *)title {
    return @"Nest";
}

+ (NSString *)description {
    return @"Smart learning thermostat";
}

+ (NSString *)imageName {
    return @"mode_nest.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeNestRaiseTemp",
             @"TTModeNestLowerTemp",
             @"TTModeNestSetTemp"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeNestRaiseTemp {
    return @"Raise temp";
}
- (NSString *)titleTTModeNestLowerTemp {
    return @"Lower temp";
}
- (NSString *)titleTTModeNestSetTemp {
    return @"Set temperature";
}

#pragma mark - Action Images

- (NSString *)imageTTModeNestRaiseTemp {
    return @"temperature_up.png";
}
- (NSString *)imageTTModeNestLowerTemp {
    return @"temperature_down.png";
}
- (NSString *)imageTTModeNestSetTemp {
    return @"temperature.png";
}

#pragma mark - Action methods

- (void)runTTModeNestRaiseTemp:(TTModeDirection)direction {
    Thermostat *thermostat = [self selectedThermostat];
    NSString *scale = [thermostat temperatureScale];
    NSLog(@"Running TTModeNestRaiseTemp: %ld+1", thermostat.targetTemperatureF);
    
    if ([thermostat.hvacMode isEqualToString:@"heat-cool"]) {
//        if ([[self.action optionValue:kNestSetTemperatureMode inDirection:direction] isEqualToString:@"cool"]) {
        if ([scale isEqualToString:@"C"]) {
            thermostat.targetTemperatureHighC += 1;
            thermostat.targetTemperatureLowC += 1;
        } else {
            thermostat.targetTemperatureHighF += 1;
            thermostat.targetTemperatureLowF += 1;
        }
    } else {
        thermostat.targetTemperatureF += 1;
    }
    
    [self changeThermostatTemp:thermostat]; // HTTP, not Firebase
//    [self.nestThermostatManager saveChangesForThermostat:thermostat]; // Firebase
}

- (void)runTTModeNestLowerTemp:(TTModeDirection)direction {
    Thermostat *thermostat = [self selectedThermostat];
    NSString *scale = [thermostat temperatureScale];
    NSLog(@"Running TTModeNestLowerTemp: %ld-1", thermostat.targetTemperatureF);
    
    if ([thermostat.hvacMode isEqualToString:@"heat-cool"]) {
//        if ([[self.action optionValue:kNestSetTemperatureMode inDirection:direction] isEqualToString:@"cool"]) {
        if ([scale isEqualToString:@"C"]) {
            thermostat.targetTemperatureHighC -= 1;
            thermostat.targetTemperatureLowC -= 1;
        } else {
            thermostat.targetTemperatureHighF -= 1;
            thermostat.targetTemperatureLowF -= 1;
        }
    } else {
        thermostat.targetTemperatureF -= 1;
    }
    
    [self changeThermostatTemp:thermostat]; // HTTP, not Firebase
//    [self.nestThermostatManager saveChangesForThermostat:thermostat]; // Firebase
}

- (void)runTTModeNestSetTemp:(TTModeDirection)direction {
    Thermostat *thermostat = [self selectedThermostat];
    NSString *scale = [thermostat temperatureScale];
    NSInteger temperature = [[self.action optionValue:kNestSetTemperature
                                          inDirection:direction] integerValue];
    NSLog(@"Running TTModeNestSetTemp: %ld", temperature);

    if ([thermostat.hvacMode isEqualToString:@"heat-cool"]) {
        if ([[self.action optionValue:kNestSetTemperatureMode inDirection:direction] isEqualToString:@"cool"]) {
            if ([scale isEqualToString:@"C"]) {
                thermostat.targetTemperatureHighC = temperature;
            } else {
                thermostat.targetTemperatureHighF = temperature;
            }
        } else {
            if ([scale isEqualToString:@"C"]) {
                thermostat.targetTemperatureLowC = temperature;
            } else {
                thermostat.targetTemperatureLowF = temperature;
            }
        }
    } else {
        if ([scale isEqualToString:@"C"]) {
            thermostat.targetTemperatureC = temperature;
        } else {
            thermostat.targetTemperatureF = temperature;
        }
    }
    
    [self changeThermostatTemp:thermostat]; // HTTP, not Firebase
//    [self.nestThermostatManager saveChangesForThermostat:thermostat]; // Firebase
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeNestRaiseTemp";
}
- (NSString *)defaultEast {
    return @"TTModeNestSetTemp";
}
- (NSString *)defaultWest {
    return @"TTModeNestSetTemp";
}
- (NSString *)defaultSouth {
    return @"TTModeNestLowerTemp";
}

#pragma mark - Activation

- (void)activate {
    if ([[NestAuthManager sharedManager] isValidSession]) {
//        NSLog(@"Nest access token: %@", [[NestAuthManager sharedManager] accessToken]);
        if (currentStructure) {
            nestState = NEST_STATE_CONNECTED;
        } else {
            nestState = NEST_STATE_CONNECTING;
            [self loadNestStructures];
        }
    } else {
        nestState = NEST_STATE_NOT_CONNECTED;
    }
    [self.delegate changeState:nestState withMode:self];
    
    [[self sharedNestThermostatManager] setDelegate:delegateManager];

    [[self sharedNestStructureManager] setDelegate:delegateManager];
    
}

- (void)deactivate {
//    self.nestThermostatManager = nil;
//    self.nestStructureManager = nil;
    [delegateManager.delegates removeObject:self];
}

#pragma mark - Connection

- (void)beginConnectingToNest {
    nestState = NEST_STATE_CONNECTING;
    [self.delegate changeState:nestState withMode:self];
}

- (void)cancelConnectingToNest {
    nestState = NEST_STATE_NOT_CONNECTED;
    [self.delegate changeState:nestState withMode:self];
}

#pragma mark - Nest API w/ Firebase

- (void)structureUpdated:(NSDictionary *)structure {
    NSLog(@"Nest Structure updated: %@", structure);
    currentStructure = structure;
    [self loadNestThermostats];
}

- (void)thermostatValuesChanged:(Thermostat *)thermostat {
    NSLog(@"thermostat value changed: %@ %ld°F (%ld°F-%ld°F) — currently: %ld°F",
          thermostat, thermostat.targetTemperatureF, thermostat.targetTemperatureLowF,
          thermostat.targetTemperatureHighF, thermostat.ambientTemperatureF);
    nestState = NEST_STATE_CONNECTED;
    [self.delegate changeState:nestState withMode:self];
    [self.delegate updateThermostat:thermostat];
}

- (Thermostat *)selectedThermostat {
    Thermostat *thermostat = [[currentStructure objectForKey:@"thermostats"] objectAtIndex:0];;
    return thermostat;
}

- (void)subscribeToThermostat:(Thermostat *)thermostat {
    if (!thermostat) {
        thermostat = [self selectedThermostat];
    }
    
    NSLog(@"Subscribing to thermostat: %@", thermostat);
    if (!thermostat) return;
    
    [[self sharedNestThermostatManager] beginSubscriptionForThermostat:thermostat];

    nestState = NEST_STATE_CONNECTED;
    [self.delegate changeState:nestState withMode:self];
}

#pragma mark - Nest API w/ REST

- (void)loadNestStructures {
    static BOOL loading = false;
    if (loading) {
        NSLog(@" ---> Already loading Nest structures...");
        return;
    }
    loading = true;
    NSString *accessToken = [[NestAuthManager sharedManager] accessToken];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?auth=%@",
                                       kNestApiHost, kNestApiStructures, accessToken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response,
                                               NSData * _Nullable data,
                                               NSError * _Nullable connectionError) {
                               if (!connectionError) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if (httpResponse.statusCode == 200) {
                                       NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                                       [[self sharedNestStructureManager] parseStructure:jsonData];
                                   }
                               } else {
                                   NSLog(@"Nest REST error: %@", connectionError);
                               }
                               loading = false;
                           }];
}

- (void)loadNestThermostats {
    static BOOL loading = false;
    if (loading) {
        NSLog(@" ---> Already loading Nest thermostats...");
        return;
    }
    loading = true;
    
    NSString *accessToken = [[NestAuthManager sharedManager] accessToken];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?auth=%@",
                                       kNestApiHost, kNestApiThermostats, accessToken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response,
                                               NSData * _Nullable data,
                                               NSError * _Nullable connectionError) {
                               if (!connectionError) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if (httpResponse.statusCode == 200) {
                                       NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                                       for (NSDictionary *data in [jsonData allValues]) {
                                           for (Thermostat *device in [currentStructure objectForKey:@"thermostats"]) {
                                               if ([device.thermostatId isEqualToString:[data objectForKey:@"device_id"]]) {
                                                   NSLog(@"Thermostat: %@", data);
                                                   [[self sharedNestThermostatManager] updateThermostat:device forStructure:data];
                                                   [self subscribeToThermostat:device];
                                                   break;
                                               }
                                           }
                                       }
                                   }
                               } else {
                                   NSLog(@"Nest REST error: %@", connectionError);
                               }
                               loading = false;
                           }];
}

- (void)changeThermostatTemp:(Thermostat *)thermostat {
    NSString *scale = [thermostat temperatureScale];
    NSString *accessToken = [[NestAuthManager sharedManager] accessToken];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@?auth=%@",
                                       kNestApiHost, kNestApiThermostats, thermostat.thermostatId, accessToken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    if ([thermostat.hvacMode isEqualToString:@"heat-cool"]) {
        if ([scale isEqualToString:@"C"]) {
            [request setHTTPBody:[[NSString stringWithFormat:@"{\"target_temperature_high_c\": %ld,"
                                   "\"target_temperature_low_c\": %ld}",
                                   thermostat.targetTemperatureHighC,
                                   thermostat.targetTemperatureLowC]
                                  dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [request setHTTPBody:[[NSString stringWithFormat:@"{\"target_temperature_high_f\": %ld,"
                                   "\"target_temperature_low_f\": %ld}",
                                   thermostat.targetTemperatureHighF,
                                   thermostat.targetTemperatureLowF]
                                  dataUsingEncoding:NSUTF8StringEncoding]];
        }
    } else {
        if ([scale isEqualToString:@"C"]) {
            [request setHTTPBody:[[NSString stringWithFormat:@"{\"target_temperature_c\": %ld}", thermostat.targetTemperatureC]
                                  dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [request setHTTPBody:[[NSString stringWithFormat:@"{\"target_temperature_f\": %ld}", thermostat.targetTemperatureF]
                                  dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response,
                                               NSData * _Nullable data,
                                               NSError * _Nullable connectionError) {
                               if (!connectionError) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if (httpResponse.statusCode == 200) {
                                       NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                                       NSLog(@"thermostat temp data: %@", jsonData);
                                       [[self sharedNestThermostatManager] updateThermostat:thermostat forStructure:jsonData];
                                   } else {
                                       NSLog(@"Nest REST error %ld: %@ - %@", httpResponse.statusCode, response, [NSString stringWithUTF8String:[data bytes]]);
                                   }
                               } else {
                                   NSLog(@"Nest REST error: %@ / %@", connectionError, [NSString stringWithUTF8String:[data bytes]]);
                               }
                           }];
}

- (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary {
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        [parameterArray addObject:param];
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)percentEscapeString:(NSString *)string {
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

@end
