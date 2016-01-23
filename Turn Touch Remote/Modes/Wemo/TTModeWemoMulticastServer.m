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

@implementation TTModeWemoMulticastServer

@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)beginbroadcast {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [self createMulticastReceiver];
    });
}

#pragma mark - Multicast Receive

- (void)createMulticastReceiver {
    GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (![udpSocket bindToPort:7700 error:&error])
    {
        NSLog(@"Error binding to port: %@", error);
        return;
    }
    if(![udpSocket joinMulticastGroup:@"239.255.255.250" error:&error]){
        NSLog(@"Error connecting to multicast group: %@", error);
        return;
    }

    NSString *message = @"M-SEARCH * HTTP/1.1\r\nHOST:239.255.255.250:1900\r\nST:upnp:rootdevice\r\nMX:2\r\nMAN:\"ssdp:discover\"\r\n\r\n";
    NSData* data=[message dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:@"239.255.255.250" port:1900 withTimeout:3 tag:0];

    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    NSLog(@"Socket Ready");
}

#pragma mark - Match Belkin

- (void)checkDevice:(NSString *)data host:(NSString *)host port:(NSInteger)port {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    for (NSString *line in [data componentsSeparatedByString:@"\r\n"]) {
        NSRange match = [line rangeOfString:@":"];
        if (match.location == NSNotFound) continue;
        NSString *key = [[line substringToIndex:match.location] lowercaseString];
        NSString *value = [line substringFromIndex:match.location+1];
        [headers setObject:value forKey:key];
    }
    
    NSLog(@"%@", headers);
    NSString *userAgent = [headers objectForKey:@"x-user-agent"];
    if ([userAgent containsString:@"redsonic"]) {
        NSLog(@"Found Wemo: %@: %@", host, headers);
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate foundDevice:headers host:host port:port];
        });
    }
}

#pragma mark - Async delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {

    [self checkDevice:[NSString stringWithUTF8String:[data bytes]]
                 host:[GCDAsyncUdpSocket hostFromAddress:address]
                 port:[GCDAsyncUdpSocket portFromAddress:address]];
}

@end
