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
        [self receiveMulticast];
        [self sendBroadcastPacket];
    });
}

#pragma mark - Multicast Send

- (void)sendBroadcastPacket {
    // Open a socket
    sendSocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sendSocket <= 0) {
        NSLog(@"Error: Could not open socket");
        return;
    }
    
    // Set socket options
    // Enable broadcast
    int broadcastEnable=1;
    int ret = setsockopt(sendSocket, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
    if (ret) {
        NSLog(@"Error: Could not open set socket to broadcast mode");
        close(sendSocket);
        return;
    }
    
    // Since we don't call bind() here, the system decides on the port for us, which is what we want.
    
    // Configure the port and ip we want to send to
    struct sockaddr_in broadcastAddr; // Make an endpoint
    memset(&broadcastAddr, 0, sizeof broadcastAddr);
    broadcastAddr.sin_family = AF_INET;
    inet_pton(AF_INET, "239.255.255.250", &broadcastAddr.sin_addr); // Set the broadcast IP address
    broadcastAddr.sin_port = htons(1900); // Set port 1900
    
    // Send the broadcast request, ie "Any upnp devices out there?"
    char *request = "M-SEARCH * HTTP/1.1\r\nHOST:239.255.255.250:1900\r\nST:upnp:rootdevice\r\nMX:2\r\nMAN:\"ssdp:discover\"\r\n\r\n";
    ssize_t sendRet = sendto(sendSocket, request, strlen(request), 0, (struct sockaddr*)&broadcastAddr, sizeof broadcastAddr);
    if (sendRet < 0) {
        NSLog(@"Error: Could not open send broadcast");
        close(sendSocket);
        return;
    }
    
    // Get responses here using recvfrom if you want...
    close(sendSocket);
}

#pragma mark - Multicast Receive

- (void)createMulticastReceiver {
    int flag = 1;
    int result = 0;
    
    receiveSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    struct sockaddr_in serverAddress;
    size_t namelen = sizeof(serverAddress);
    bzero(&serverAddress, namelen);
    serverAddress.sin_family = AF_INET;
    serverAddress.sin_addr.s_addr = htonl(INADDR_ANY);
    serverAddress.sin_port = htons(1900);
    result = setsockopt(receiveSocket, SOL_SOCKET, SO_REUSEADDR, &flag,(socklen_t)sizeof(flag));
    result = bind(receiveSocket, (struct sockaddr *)&serverAddress, (socklen_t)namelen);
    if (result != 0) {
        // Couldn't bind. Port probably in use. Let the parent process know then terminate.
        [(NSFileHandle *)[NSFileHandle fileHandleWithStandardOutput] writeData:[@"port in use" dataUsingEncoding:NSUTF8StringEncoding]];
//        exit(1);
        return;
    }
    
    struct ip_mreq  theMulti;
    result = inet_aton([@"239.255.255.250" cStringUsingEncoding:NSASCIIStringEncoding], &theMulti.imr_multiaddr );
    result = inet_aton([[self getIPAddress] cStringUsingEncoding:NSASCIIStringEncoding], &theMulti.imr_interface );
    result = setsockopt(receiveSocket, IPPROTO_IP, IP_ADD_MEMBERSHIP, &theMulti,(socklen_t)sizeof(theMulti));
}

- (void)receiveMulticast {
    char receivedLine[1000];
    
    while (receiveSocket != 0) {
        bzero(&receivedLine, 1000);
        struct sockaddr_in receiveAddress;
        socklen_t receiveAddressLen = sizeof(receiveAddress);
        
        // Receive packet.
        ssize_t result = recvfrom(receiveSocket, receivedLine, 1000, 0, (struct sockaddr *)&receiveAddress, &receiveAddressLen);
        if (result > 0) {
            // Extract address, port, message.
            UInt16 sentPort = ntohs(receiveAddress.sin_port);
            char addressBuffer[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, &receiveAddress.sin_addr, addressBuffer, sizeof(addressBuffer));
            NSString *sentHost = [NSString stringWithCString:addressBuffer encoding:NSASCIIStringEncoding];
            NSString *receivedMessage = [NSString stringWithCString:receivedLine encoding:NSASCIIStringEncoding];
            
            [self checkDevice:receivedMessage host:sentHost port:sentPort];
        } else {
            NSLog(@"Error receiving multicast packet: %zd", result);
        }
        
        // Sleep for 1s.
//        [NSThread sleepUntilDate:[[NSDate date] dateByAddingTimeInterval:1]];
    }
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
    if ([userAgent isEqualToString:@"redsonic"]) {
        NSLog(@"Found Wemo: %@: %@", host, headers);
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate foundDevice:headers host:host port:port];
        });
    }
}


- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

@end
