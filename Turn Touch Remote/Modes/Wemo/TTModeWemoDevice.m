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

- (BOOL)isOn {
    return [self state] == WEMO_DEVICE_STATE_ON;
}

- (TTWemoDeviceState)state {
    
}

- (BOOL)isEqualToDevice:(TTModeWemoDevice *)device {
    BOOL sameAddress = [ipAddress isEqualToString:device.ipAddress];
    BOOL samePort = port == device.port;
    
    return sameAddress && samePort;
}

#pragma mark - Actions

- (void)turnOn {
    
}

- (void)turnOff {
    
}

- (void)toggleState {
    
}

#pragma mark - Networking

- (void)requestDeviceInfo {
    [self requestDeviceInfo:5];
}

- (void)requestDeviceInfo:(NSInteger)attemptsLeft {
    if (!attemptsLeft) {
        NSLog(@"Error: could not find wemo setup.xml %@:%ld", ipAddress, port);
        return;
    }
    
    attemptsLeft -= 1;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%ld/setup.xml",
                                       ipAddress, port]];
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
        deviceName = [NSString stringWithFormat:@"Wemo device (%@:%ld)", ipAddress, port];
    } else {
        deviceName = [[results objectAtIndex:0] objectForKey:@"nodeContent"];
        NSLog(@" ---> Found wemo device: %@ (%@:%ld)", deviceName, ipAddress, port);
    }
    
    [delegate deviceReady:self];
}

- (void)changeDeviceState:(TTWemoDeviceState)state {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%ld/upnp/control/basicevent1",
                                       ipAddress, port]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"urn:Belkin:service:basicevent:1#GetBinaryState" forHTTPHeaderField:@"SOAPACTION"];
    [request setHTTPBody:[[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:SetBinaryState xmlns:u=\"urn:Belkin:service:basicevent:1\"><BinaryState>%d</BinaryState></u:SetBinaryState></s:Body></s:Envelope>", state == WEMO_DEVICE_STATE_OFF ? 0 : 1] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response,
                                               NSData * _Nullable data,
                                               NSError * _Nullable connectionError) {
                               if (!connectionError) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if (httpResponse.statusCode == 200) {
                                       NSLog(@"Wemo basicevent: %@", [NSString stringWithUTF8String:[data bytes]]);
                                   }
                               } else {
                                   NSLog(@"Wemo REST error: %@", connectionError);
                               }
                           }];
}
@end
