//
//  TTModeWemoDevice.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/23/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemoDevice.h"
#import "XPathQuery.h"

@implementation TTModeWemoDevice

@synthesize ipAddress;
@synthesize port;
@synthesize deviceName;
@synthesize deviceState;
@synthesize delegate;

- (id)initWithIpAddress:(NSString *)_ip port:(NSInteger)_port {
    if (self = [super init]) {
        ipAddress = _ip;
        port = _port;
    }
    
    return self;
}

#pragma mark - State

- (BOOL)isEqualToDevice:(TTModeWemoDevice *)device {
    BOOL sameAddress = [ipAddress isEqualToString:device.ipAddress];
    BOOL samePort = port == device.port;
    
    return sameAddress && samePort;
}

- (NSString *)location {
    return [NSString stringWithFormat:@"%@:%ld", ipAddress, port];
}

#pragma mark - Networking

- (void)requestDeviceInfo {
    [self requestDeviceInfo:5];
}

- (void)requestDeviceInfo:(NSInteger)attemptsLeft {
    if (!attemptsLeft) {
        NSLog(@"Error: could not find wemo setup.xml %@", self.location);
        return;
    }
    
    attemptsLeft -= 1;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/setup.xml",
                                       self.location]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response,
                                               NSData * _Nullable data,
                                               NSError * _Nullable connectionError) {
                               if (!connectionError) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if (httpResponse.statusCode == 200) {
                                       if (!data || ![data bytes] || ![data length]) {
                                           NSLog(@"Retrying setup.xml fetch...");
                                           [self requestDeviceInfo:attemptsLeft];
                                       } else {
                                           [self parseSetupXml:data];
                                       }
                                   }
                               } else {
                                   NSLog(@"Wemo REST error: %@", connectionError);
                               }
                           }];
}

- (void)parseSetupXml:(NSData *)data {
    NSArray *results = PerformXMLXPathQuery(data, @"/wemo:root/wemo:device/wemo:friendlyName",
                                            "wemo", "urn:Belkin:device-1-0");
    if (![results count]) {
        NSLog(@"Error: Could not find friendlyName for wemo.");
        deviceName = [NSString stringWithFormat:@"Wemo device (%@)", self.location];
    } else {
        deviceName = [[results objectAtIndex:0] objectForKey:@"nodeContent"];
        NSLog(@" ---> Found wemo device: %@ (%@)", deviceName, self.location);
    }
    
    [delegate deviceReady:self];
}

- (void)requestDeviceState:(void (^)())callback {
    [self requestDeviceState:5 callback:callback];
}

- (void)requestDeviceState:(NSInteger)attemptsLeft callback:(void (^)())callback {
    if (!attemptsLeft) {
        NSLog(@"Error: could not find wemo state: %@", self.location);
        return;
    }
    
    attemptsLeft -= 1;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/upnp/control/basicevent1",
                                       self.location]];
    NSData *body = [[@[@"<?xml version=\"1.0\" encoding=\"utf-8\"?>",
                        @"<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">",
                        @"<s:Body>",
                        @"<u:GetBinaryState xmlns:u=\"urn:Belkin:service:basicevent:1\">",
                        @"</u:GetBinaryState>",
                        @"</s:Body>",
                        @"</s:Envelope>"] componentsJoinedByString:@"\r\n"]
                    dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"\"urn:Belkin:service:basicevent:1#GetBinaryState\"" forHTTPHeaderField:@"SOAPACTION"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response,
                                               NSData * _Nullable data,
                                               NSError * _Nullable connectionError) {
                               if (!connectionError) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if (httpResponse.statusCode == 200) {
                                       if (!data || ![data bytes] || ![data length]) {
                                           NSLog(@"Retrying basicevent.xml fetch...");
                                           [self requestDeviceState:attemptsLeft callback:callback];
                                       } else {
                                           [self parseBasicEventXml:data callback:callback];
                                       }
                                   }
                               } else {
                                   NSLog(@"Wemo REST error: %@", connectionError);
                               }
                           }];
}

- (void)parseBasicEventXml:(NSData *)data callback:(void (^)())callback {
    NSArray *results = PerformXMLXPathQuery(data, @"/*/*/u:GetBinaryStateResponse/BinaryState",
                                            "u", "urn:Belkin:service:basicevent:1");
    if (![results count]) {
        NSLog(@"Error: Could not find friendlyName for wemo.");
        deviceName = [NSString stringWithFormat:@"Wemo device (%@)", self.location];
    } else {
        NSString *state = [[results objectAtIndex:0] objectForKey:@"nodeContent"];
        if ([state isEqualToString:@"1"] || [state isEqualToString:@"8"]) deviceState = WEMO_DEVICE_STATE_ON;
        else if ([state isEqualToString:@"0"]) deviceState = WEMO_DEVICE_STATE_OFF;
        NSLog(@" ---> Wemo State: %@ (%@)", deviceName, state);
        callback();
    }
    
    
}

- (void)updateDeviceState {
    
}

- (void)changeDeviceState:(TTWemoDeviceState)state {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/upnp/control/basicevent1",
                                       self.location]];
    NSData *body = [[NSString stringWithFormat:
                     [@[@"<?xml version=\"1.0\" encoding=\"utf-8\"?>",
                        @"<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">",
                        @"<s:Body>",
                        @"<u:SetBinaryState xmlns:u=\"urn:Belkin:service:basicevent:1\">",
                        @"<BinaryState>%d</BinaryState>",
                        @"</u:SetBinaryState>",
                        @"</s:Body>",
                        @"</s:Envelope>"] componentsJoinedByString:@"\r\n"],
                     state == WEMO_DEVICE_STATE_OFF ? 0 : 1]
                    dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"\"urn:Belkin:service:basicevent:1#SetBinaryState\"" forHTTPHeaderField:@"SOAPACTION"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response,
                                               NSData * _Nullable data,
                                               NSError * _Nullable connectionError) {
                               if (!connectionError) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if (httpResponse.statusCode == 200) {
//                                       NSLog(@"Wemo basicevent: %@", [NSString stringWithUTF8String:[data bytes]]);
                                   }
                               } else {
                                   NSLog(@"Wemo REST error: %@", connectionError);
                               }
                           }];
}
@end
