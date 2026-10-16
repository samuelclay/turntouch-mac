//
//  TTModeGoveeAPIClient.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGoveeAPIClient.h"

static NSString *const kGoveeBaseURL = @"https://openapi.api.govee.com";
static NSString *const kGoveeDevicesEndpoint = @"/router/api/v1/user/devices";
static NSString *const kGoveeControlEndpoint = @"/router/api/v1/device/control";
static NSString *const kGoveeStateEndpoint = @"/router/api/v1/device/state";

@interface TTModeGoveeAPIClient ()

@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation TTModeGoveeAPIClient

- (instancetype)init {
    if (self = [super init]) {
        self.session = [NSURLSession sharedSession];
    }
    return self;
}

- (void)setApiKey:(NSString *)apiKey {
    _apiKey = [apiKey copy];
}

#pragma mark - Fetch Devices

- (void)fetchDevices {
    if (!self.apiKey || self.apiKey.length == 0) {
        [self.delegate apiClientDidFailWithError:@"No API key configured"];
        return;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kGoveeBaseURL, kGoveeDevicesEndpoint]];
    if (!url) {
        [self.delegate apiClientDidFailWithError:@"Invalid URL"];
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:self.apiKey forHTTPHeaderField:@"Govee-API-Key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSLog(@" ---> Govee API: Fetching devices...");

    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@" ---> Govee API: Network error: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate apiClientDidFailWithError:[NSString stringWithFormat:@"Network error: %@", error.localizedDescription]];
            });
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (httpResponse.statusCode == 401) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate apiClientDidFailWithError:@"Invalid API key"];
            });
            return;
        }

        if (httpResponse.statusCode == 429) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate apiClientDidFailWithError:@"Rate limit exceeded. Try again later."];
            });
            return;
        }

        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate apiClientDidFailWithError:@"No data received"];
            });
            return;
        }

        NSError *jsonError;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError || !responseDict) {
            NSLog(@" ---> Govee API: JSON parse error: %@", jsonError);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate apiClientDidFailWithError:[NSString stringWithFormat:@"Failed to parse response: %@", jsonError.localizedDescription]];
            });
            return;
        }

        NSNumber *code = responseDict[@"code"];
        if (code && code.integerValue != 200) {
            NSString *msg = responseDict[@"message"] ?: @"Unknown error";
            NSLog(@" ---> Govee API: Error response: %@", msg);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate apiClientDidFailWithError:msg];
            });
            return;
        }

        NSMutableArray<TTModeGoveeDevice *> *devices = [NSMutableArray array];
        NSArray *deviceDataList = responseDict[@"data"];

        for (NSDictionary *deviceData in deviceDataList) {
            NSString *deviceId = deviceData[@"device"];
            NSString *sku = deviceData[@"sku"];
            if (!deviceId || !sku) continue;

            NSString *name = deviceData[@"deviceName"] ?: @"Govee Device";
            TTModeGoveeDevice *device = [[TTModeGoveeDevice alloc] initWithDeviceId:deviceId sku:sku deviceName:name];
            device.capabilities = deviceData[@"capabilities"] ?: @[];
            [devices addObject:device];
        }

        NSLog(@" ---> Govee API: Found %lu devices", (unsigned long)devices.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate apiClientDidFetchDevices:devices];
        });
    }] resume];
}

#pragma mark - Control Device

- (void)controlDevice:(TTModeGoveeDevice *)device turnOn:(BOOL)turnOn {
    [self sendControlCommandToDevice:device
                      capabilityType:@"devices.capabilities.on_off"
                            instance:@"powerSwitch"
                               value:turnOn ? 1 : 0];
}

- (void)setBrightness:(TTModeGoveeDevice *)device brightness:(NSInteger)brightness {
    NSInteger clampedBrightness = MAX(1, MIN(100, brightness));
    [self sendControlCommandToDevice:device
                      capabilityType:@"devices.capabilities.range"
                            instance:@"brightness"
                               value:clampedBrightness];
}

#pragma mark - Fetch Device State

- (void)fetchDeviceState:(TTModeGoveeDevice *)device {
    if (!self.apiKey || self.apiKey.length == 0) {
        [self.delegate apiClientDidFailWithError:@"No API key configured"];
        return;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kGoveeBaseURL, kGoveeStateEndpoint]];
    if (!url) {
        [self.delegate apiClientDidFailWithError:@"Invalid URL"];
        return;
    }

    NSDictionary *stateRequest = @{
        @"requestId": [[NSUUID UUID] UUIDString],
        @"payload": @{
            @"sku": device.sku,
            @"device": device.deviceId
        }
    };

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:self.apiKey forHTTPHeaderField:@"Govee-API-Key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSError *jsonError;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:stateRequest options:0 error:&jsonError];
    if (jsonError) {
        [self.delegate apiClientDidFailWithError:@"Failed to encode request"];
        return;
    }

    NSLog(@" ---> Govee API: Fetching state for %@...", device.deviceName);

    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@" ---> Govee API: State fetch error: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate apiClientDidFetchDeviceState:device powerState:nil brightness:nil];
            });
            return;
        }

        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate apiClientDidFetchDeviceState:device powerState:nil brightness:nil];
            });
            return;
        }

        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSNumber *powerState = nil;
        NSNumber *brightness = nil;

        NSArray *capabilities = responseDict[@"payload"][@"capabilities"];
        for (NSDictionary *cap in capabilities) {
            NSString *instance = cap[@"instance"];
            NSDictionary *state = cap[@"state"];
            id value = state[@"value"];

            if ([instance isEqualToString:@"powerSwitch"] && value) {
                powerState = @([value integerValue]);
            }
            if ([instance isEqualToString:@"brightness"] && value) {
                brightness = @([value integerValue]);
            }
        }

        NSLog(@" ---> Govee API: State for %@: power=%@, brightness=%@", device.deviceName, powerState, brightness);

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate apiClientDidFetchDeviceState:device powerState:powerState brightness:brightness];
        });
    }] resume];
}

#pragma mark - Private

- (void)sendControlCommandToDevice:(TTModeGoveeDevice *)device
                     capabilityType:(NSString *)capabilityType
                           instance:(NSString *)instance
                              value:(NSInteger)value {
    if (!self.apiKey || self.apiKey.length == 0) {
        [self.delegate apiClientDidFailWithError:@"No API key configured"];
        return;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kGoveeBaseURL, kGoveeControlEndpoint]];
    if (!url) {
        [self.delegate apiClientDidFailWithError:@"Invalid URL"];
        return;
    }

    NSDictionary *controlRequest = @{
        @"requestId": [[NSUUID UUID] UUIDString],
        @"payload": @{
            @"sku": device.sku,
            @"device": device.deviceId,
            @"capability": @{
                @"type": capabilityType,
                @"instance": instance,
                @"value": @(value)
            }
        }
    };

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:self.apiKey forHTTPHeaderField:@"Govee-API-Key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSError *jsonError;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:controlRequest options:0 error:&jsonError];
    if (jsonError) {
        [self.delegate apiClientDidFailWithError:@"Failed to encode request"];
        return;
    }

    NSLog(@" ---> Govee API: Sending %@=%ld to %@...", instance, (long)value, device.deviceName);

    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@" ---> Govee API: Control error: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate apiClientDidControlDevice:NO error:error.localizedDescription];
            });
            return;
        }

        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate apiClientDidControlDevice:NO error:@"No response data"];
            });
            return;
        }

        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSNumber *code = responseDict[@"code"];
        BOOL success = code && code.integerValue == 200;
        NSString *errorMsg = success ? nil : (responseDict[@"message"] ?: @"Unknown error");

        NSLog(@" ---> Govee API: Control response: success=%d, message=%@", success, responseDict[@"message"] ?: @"none");

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate apiClientDidControlDevice:success error:errorMsg];
        });
    }] resume];
}

@end
