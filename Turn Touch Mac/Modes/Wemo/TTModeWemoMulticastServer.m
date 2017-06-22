//
//  TTModeWemoMulticastServer.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/22/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemoMulticastServer.h"
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include "GCDAsyncUdpSocket.h"

#define MULTICAST_GROUP_IP @"239.255.255.250"

@implementation TTModeWemoMulticastServer

@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)deactivate {
    [udpSocket leaveMulticastGroup:MULTICAST_GROUP_IP error:nil];
    [udpSocket close];
    udpSocket = nil;
    attemptsLeft = 0;
}

- (void)beginbroadcast {
    attemptsLeft = 5;
    [self createMulticastReceiver];
}

#pragma mark - Multicast Receive

- (void)createMulticastReceiver {
    if (!udpSocket) {
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                  delegateQueue:dispatch_get_main_queue()];
        NSError *error = nil;
        if (![udpSocket bindToPort:7700 error:&error]) {
            NSLog(@"Error binding to port: %@", error);
            return;
        }
        if(![udpSocket joinMulticastGroup:MULTICAST_GROUP_IP error:&error]){
            NSLog(@"Error connecting to multicast group: %@", error);
            return;
        }
        if (![udpSocket beginReceiving:&error]) {
            NSLog(@"Error receiving: %@", error);
            return;
        }
    }
    
    NSString *message = [@[@"M-SEARCH * HTTP/1.1",
                           @"HOST:239.255.255.250:1900",
                           @"ST:upnp:rootdevice",
                           @"MX:2",
                           @"MAN:\"ssdp:discover\"",
                           @"USER-AGENT: Turn Touch Remote Wemo Finder",
                           @"", @""] componentsJoinedByString:@"\r\n"];
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:@"239.255.255.250" port:1900 withTimeout:2 tag:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!attemptsLeft || !udpSocket) {
            [self.delegate finishScanning];
            return;
        }
        attemptsLeft -= 1;
        NSLog(@"Attempting wemo M-SEARCH: %ld attempts left...", attemptsLeft);
        [self createMulticastReceiver];
    });
}

#pragma mark - Match Belkin

- (void)checkDevice:(NSString *)data host:(NSString *)host port:(NSInteger)port {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    for (NSString *line in [data componentsSeparatedByString:@"\r\n"]) {
        NSRange match = [line rangeOfString:@":"];
        if (match.location == NSNotFound) continue;
        NSString *key = [[line substringToIndex:match.location] lowercaseString];
        NSString *value = [[line substringFromIndex:match.location+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [headers setObject:value forKey:key];
    }
    
    NSString *userAgent = [headers objectForKey:@"x-user-agent"];
    if ([userAgent containsString:@"redsonic"]) { // redsonic = belkin
        // For some strange reason, `port` given here is not the port we need. The Location header has that.
        NSString *setupXmlLocation = [headers objectForKey:@"location"];
        NSURL *setupXmlUrl = [NSURL URLWithString:setupXmlLocation];
        NSString *locationHost = [setupXmlUrl host];
        NSInteger locationPort = [[setupXmlUrl port] integerValue];
        
//        NSLog(@"Found Wemo: %@/%@:%ld/%ld: %@", host, locationHost, port, locationPort, headers);
        
        [delegate foundDevice:headers host:locationHost port:locationPort name:nil live:YES];
    }
}

#pragma mark - Async delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    [self checkDevice:[NSString stringWithUTF8String:[data bytes]]
                 host:[GCDAsyncUdpSocket hostFromAddress:address]
                 port:[GCDAsyncUdpSocket portFromAddress:address]];
}

-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
//    NSLog(@"Closed UDP socket");
}

@end
