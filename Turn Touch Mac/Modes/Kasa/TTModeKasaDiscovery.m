//
//  TTModeKasaDiscovery.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasaDiscovery.h"
#import "TTModeKasaLegacyProtocol.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#define KASA_LEGACY_PORT 9999
#define KASA_KLAP_DISCOVERY_PORT 20002
#define KASA_LEGACY_RECEIVE_PORT 7703
#define KASA_KLAP_RECEIVE_PORT 7704

@interface TTModeKasaDiscovery ()

@property (nonatomic, strong) GCDAsyncUdpSocket *legacySocket;
@property (nonatomic, strong) GCDAsyncUdpSocket *klapSocket;
@property (nonatomic) NSInteger attemptsLeft;
@property (nonatomic, strong) NSMutableSet *discoveredIPs;

// TCP scan
@property (nonatomic, strong) NSMutableDictionary *tcpSockets;
@property (nonatomic) NSInteger pendingScans;
@property (nonatomic, strong) dispatch_queue_t scanQueue;

@end

@implementation TTModeKasaDiscovery

- (id)init {
    if (self = [super init]) {
        self.discoveredIPs = [NSMutableSet set];
        self.tcpSockets = [NSMutableDictionary dictionary];
        self.scanQueue = dispatch_queue_create("com.turntouch.kasa.scan", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - Discovery Control

- (void)beginDiscovery {
    NSLog(@" ---> Kasa Discovery: BEGIN DISCOVERY");
    self.attemptsLeft = 5;
    [self.discoveredIPs removeAllObjects];

    [self createSockets];
    [self sendDiscoveryBroadcasts];
    [self startTCPScan];
}

- (void)stopDiscovery {
    self.attemptsLeft = 0;
    [self closeSockets];
    [self closeAllTCPSockets];
}

- (void)deactivate {
    [self stopDiscovery];
}

#pragma mark - Socket Setup

- (void)createSockets {
    // Legacy socket for port 9999
    if (!self.legacySocket) {
        self.legacySocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                          delegateQueue:dispatch_get_main_queue()];
        [self.legacySocket setIPv4Enabled:YES];
        [self.legacySocket setIPv6Enabled:NO];

        NSError *error = nil;
        if (![self.legacySocket enableBroadcast:YES error:&error]) {
            NSLog(@" ---> Kasa Discovery: Legacy broadcast error: %@", error);
        }
        if (![self.legacySocket bindToPort:KASA_LEGACY_RECEIVE_PORT error:&error]) {
            NSLog(@" ---> Kasa Discovery: Legacy bind error: %@", error);
        }
        if (![self.legacySocket beginReceiving:&error]) {
            NSLog(@" ---> Kasa Discovery: Legacy receive error: %@", error);
        }
        NSLog(@" ---> Kasa Discovery: Legacy socket ready on port %d", KASA_LEGACY_RECEIVE_PORT);
    }

    // KLAP socket for port 20002
    if (!self.klapSocket) {
        self.klapSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                        delegateQueue:dispatch_get_main_queue()];
        [self.klapSocket setIPv4Enabled:YES];
        [self.klapSocket setIPv6Enabled:NO];

        NSError *error = nil;
        if (![self.klapSocket enableBroadcast:YES error:&error]) {
            NSLog(@" ---> Kasa Discovery: KLAP broadcast error: %@", error);
        }
        if (![self.klapSocket bindToPort:KASA_KLAP_RECEIVE_PORT error:&error]) {
            NSLog(@" ---> Kasa Discovery: KLAP bind error: %@", error);
        }
        if (![self.klapSocket beginReceiving:&error]) {
            NSLog(@" ---> Kasa Discovery: KLAP receive error: %@", error);
        }
        NSLog(@" ---> Kasa Discovery: KLAP socket ready on port %d", KASA_KLAP_RECEIVE_PORT);
    }
}

- (void)closeSockets {
    [self.legacySocket close];
    self.legacySocket = nil;

    [self.klapSocket close];
    self.klapSocket = nil;
}

- (void)closeAllTCPSockets {
    for (NSString *key in self.tcpSockets.allKeys) {
        GCDAsyncSocket *socket = self.tcpSockets[key];
        [socket disconnect];
    }
    [self.tcpSockets removeAllObjects];
}

#pragma mark - Network Helpers

- (NSArray *)getBroadcastAddresses {
    NSMutableArray *addresses = [NSMutableArray array];

    NSString *localIP = [self getLocalIPAddress];
    if (localIP) {
        NSArray *components = [localIP componentsSeparatedByString:@"."];
        if (components.count == 4) {
            NSString *subnetBroadcast = [NSString stringWithFormat:@"%@.%@.%@.255",
                                         components[0], components[1], components[2]];
            [addresses addObject:subnetBroadcast];
            NSLog(@" ---> Kasa Discovery: Using subnet broadcast: %@", subnetBroadcast);
        }
    }

    [addresses addObject:@"255.255.255.255"];
    return addresses;
}

- (NSString *)getSubnetPrefix {
    NSString *localIP = [self getLocalIPAddress];
    if (localIP) {
        NSArray *components = [localIP componentsSeparatedByString:@"."];
        if (components.count == 4) {
            return [NSString stringWithFormat:@"%@.%@.%@", components[0], components[1], components[2]];
        }
    }
    return nil;
}

- (NSString *)getLocalIPAddress {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;

    if (getifaddrs(&interfaces) != 0) return nil;

    struct ifaddrs *temp = interfaces;
    while (temp != NULL) {
        if (temp->ifa_addr->sa_family == AF_INET) {
            NSString *name = [NSString stringWithUTF8String:temp->ifa_name];
            if ([name isEqualToString:@"en0"]) { // WiFi interface
                address = [NSString stringWithUTF8String:
                           inet_ntoa(((struct sockaddr_in *)temp->ifa_addr)->sin_addr)];
            }
        }
        temp = temp->ifa_next;
    }

    freeifaddrs(interfaces);
    return address;
}

#pragma mark - Discovery Broadcasts

- (void)sendDiscoveryBroadcasts {
    [self sendLegacyDiscovery];
    [self sendKLAPDiscovery];

    // Schedule retry
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        typeof(self) self = weakSelf;
        if (!self) return;

        if (self.attemptsLeft <= 0) {
            NSLog(@" ---> Kasa Discovery: Complete. Found %lu devices.",
                  (unsigned long)self.discoveredIPs.count);
            [self.delegate discoveryFinishedScanning];
            return;
        }

        self.attemptsLeft -= 1;
        NSLog(@" ---> Kasa Discovery: %ld attempts remaining...", (long)self.attemptsLeft);
        [self sendDiscoveryBroadcasts];
    });
}

- (void)sendLegacyDiscovery {
    NSString *command = @"{\"system\":{\"get_sysinfo\":{}}}";
    NSData *commandData = [command dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [TTModeKasaLegacyProtocol encrypt:commandData];

    for (NSString *broadcastAddr in [self getBroadcastAddresses]) {
        [self.legacySocket sendData:encryptedData
                             toHost:broadcastAddr
                               port:KASA_LEGACY_PORT
                        withTimeout:3
                                tag:0];
        NSLog(@" ---> Kasa Discovery: Sent legacy broadcast to %@:%d", broadcastAddr, KASA_LEGACY_PORT);
    }
}

- (void)sendKLAPDiscovery {
    uint8_t discoveryBytes[] = {0x02, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
                                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    NSData *discoveryPacket = [NSData dataWithBytes:discoveryBytes length:16];

    for (NSString *broadcastAddr in [self getBroadcastAddresses]) {
        [self.klapSocket sendData:discoveryPacket
                           toHost:broadcastAddr
                             port:KASA_KLAP_DISCOVERY_PORT
                      withTimeout:3
                              tag:1];
        NSLog(@" ---> Kasa Discovery: Sent KLAP broadcast to %@:%d", broadcastAddr, KASA_KLAP_DISCOVERY_PORT);
    }
}

#pragma mark - TCP Network Scan (Fallback)

- (void)startTCPScan {
    NSString *subnetPrefix = [self getSubnetPrefix];
    if (!subnetPrefix) {
        NSLog(@" ---> Kasa Discovery: Could not get subnet prefix for TCP scan");
        return;
    }

    NSLog(@" ---> Kasa Discovery: Starting TCP scan on %@.x", subnetPrefix);

    NSArray *priorityIPs = @[@1, @2, @100, @101, @102, @103, @104, @105, @106, @107, @108, @109, @110,
                             @150, @151, @152, @153, @154, @155, @200, @201, @202, @203, @204, @205];

    // First scan priority IPs
    for (NSNumber *lastOctet in priorityIPs) {
        NSString *ip = [NSString stringWithFormat:@"%@.%@", subnetPrefix, lastOctet];
        [self scanIP:ip port:KASA_LEGACY_PORT];
        [self scanIP:ip port:80];
    }

    // Then scan the rest with delays
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.scanQueue, ^{
        typeof(self) self = weakSelf;
        if (!self) return;

        NSSet *prioritySet = [NSSet setWithArray:priorityIPs];
        for (NSInteger lastOctet = 1; lastOctet < 255; lastOctet++) {
            if (self.attemptsLeft <= 0) return;
            if ([prioritySet containsObject:@(lastOctet)]) continue;

            NSString *ip = [NSString stringWithFormat:@"%@.%ld", subnetPrefix, (long)lastOctet];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self scanIP:ip port:KASA_LEGACY_PORT];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)),
                          dispatch_get_main_queue(), ^{
                [self scanIP:ip port:80];
            });

            [NSThread sleepForTimeInterval:0.03];
        }
    });
}

- (void)scanIP:(NSString *)ip port:(UInt16)port {
    if ([self.discoveredIPs containsObject:ip]) return;

    NSString *socketKey = [NSString stringWithFormat:@"%@:%d", ip, port];
    if (self.tcpSockets[socketKey]) return;

    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                        delegateQueue:dispatch_get_main_queue()];
    socket.userData = @{@"ip": ip, @"port": @(port)};
    self.tcpSockets[socketKey] = socket;

    NSError *error = nil;
    if (![socket connectToHost:ip onPort:port withTimeout:2 error:&error]) {
        [self.tcpSockets removeObjectForKey:socketKey];
    }
}

#pragma mark - GCDAsyncSocketDelegate (TCP)

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@" ---> Kasa Discovery: TCP connected to %@:%d", host, port);

    if (port == 80) {
        // KLAP device - try handshake1 endpoint with random seed
        uint8_t seedBytes[16];
        arc4random_buf(seedBytes, 16);
        NSData *seed = [NSData dataWithBytes:seedBytes length:16];

        NSString *httpHeader = [NSString stringWithFormat:
                                @"POST /app/handshake1 HTTP/1.1\r\nHost: %@\r\nContent-Type: application/octet-stream\r\nContent-Length: 16\r\nUser-Agent: Kasa_Android\r\n\r\n",
                                host];
        NSMutableData *requestData = [[httpHeader dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
        [requestData appendData:seed];
        [sock writeData:requestData withTimeout:3 tag:80];
        [sock readDataWithTimeout:3 tag:80];
    } else {
        // Legacy device - send get_sysinfo
        NSString *command = @"{\"system\":{\"get_sysinfo\":{}}}";
        NSData *commandData = [command dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptedData = [TTModeKasaLegacyProtocol encryptWithHeader:commandData];

        [sock writeData:encryptedData withTimeout:3 tag:0];
        [sock readDataWithTimeout:3 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // Use userData for host since connectedHost can be nil during disconnection
    NSDictionary *userData = (NSDictionary *)sock.userData;
    NSString *host = sock.connectedHost ?: userData[@"ip"];
    NSNumber *portNum = userData[@"port"];
    uint16_t port = portNum ? [portNum unsignedShortValue] : sock.connectedPort;

    NSLog(@" ---> Kasa Discovery: TCP received %lu bytes from %@:%d",
          (unsigned long)data.length, host, port);

    if (tag == 80 || port == 80) {
        [self handleHTTPResponse:data host:host sock:sock];
    } else {
        [self handleLegacyTCPResponse:data host:host sock:sock];
    }
}

- (void)handleHTTPResponse:(NSData *)data host:(NSString *)host sock:(GCDAsyncSocket *)sock {
    if (!host) {
        [sock disconnect];
        return;
    }

    // Check for KLAP handshake1 response (200 OK with 48-byte body = serverSeed + serverHash)
    NSString *headerStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    BOOL isKLAPDevice = NO;

    if (headerStr) {
        NSLog(@" ---> Kasa Discovery: HTTP response from %@: %@", host,
              [headerStr substringToIndex:MIN(200, headerStr.length)]);

        // KLAP handshake1 returns 200 with binary body (48 bytes: 16 server seed + 32 server hash)
        if ([headerStr containsString:@"200 OK"]) {
            isKLAPDevice = YES;
        }
        // Also check for TP-Link specific markers
        if ([headerStr containsString:@"TP-Link"] || [headerStr containsString:@"Tapo"]) {
            isKLAPDevice = YES;
        }
        // error_code is a TP-Link API response pattern
        if ([headerStr containsString:@"error_code"]) {
            isKLAPDevice = YES;
        }
    } else {
        // Binary response - could be KLAP handshake response
        NSLog(@" ---> Kasa Discovery: Binary HTTP response from %@ (%lu bytes)",
              host, (unsigned long)data.length);
        // Look for HTTP/1.1 200 in first bytes
        if (data.length > 15) {
            NSData *statusLine = [data subdataWithRange:NSMakeRange(0, MIN(30, data.length))];
            NSString *statusStr = [[NSString alloc] initWithData:statusLine encoding:NSASCIIStringEncoding];
            if (statusStr && [statusStr containsString:@"200"]) {
                isKLAPDevice = YES;
            }
        }
    }

    if (isKLAPDevice) {
        [self.discoveredIPs addObject:host];

        TTModeKasaDevice *device = [self.delegate discoveryFoundDeviceWithIpAddress:host
                                                                              port:80
                                                                      protocolType:KASA_PROTOCOL_KLAP
                                                                              name:nil
                                                                          deviceId:nil
                                                                        macAddress:nil];
        NSLog(@" ---> Kasa Discovery: Found KLAP device via HTTP: %@", device);
    }

    [sock disconnect];
    NSString *socketKey = [NSString stringWithFormat:@"%@:80", host];
    [self.tcpSockets removeObjectForKey:socketKey];
}

- (void)handleLegacyTCPResponse:(NSData *)data host:(NSString *)host sock:(GCDAsyncSocket *)sock {
    if (data.length <= 4) {
        [sock disconnect];
        return;
    }

    NSData *payloadData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
    NSData *decryptedData = [TTModeKasaLegacyProtocol decrypt:payloadData];

    NSString *jsonString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    if (!jsonString) {
        [sock disconnect];
        return;
    }

    NSLog(@" ---> Kasa Discovery: TCP response from %@: %@", host,
          [jsonString substringToIndex:MIN(200, jsonString.length)]);

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:decryptedData options:0 error:&error];

    if (!error && json) {
        NSDictionary *sysinfo = json[@"system"][@"get_sysinfo"];
        if (sysinfo) {
            [self.discoveredIPs addObject:host];

            NSString *deviceId = sysinfo[@"deviceId"];
            if (!deviceId) deviceId = sysinfo[@"device_id"];
            if (!deviceId) deviceId = sysinfo[@"deviceid"];

            TTModeKasaDevice *device = [self.delegate discoveryFoundDeviceWithIpAddress:host
                                                                                  port:KASA_LEGACY_PORT
                                                                          protocolType:KASA_PROTOCOL_LEGACY
                                                                                  name:sysinfo[@"alias"]
                                                                              deviceId:deviceId
                                                                            macAddress:sysinfo[@"mac"]];
            NSLog(@" ---> Kasa Discovery: Found device via TCP: %@", device);
        }
    }

    [sock disconnect];
    NSString *socketKey = [NSString stringWithFormat:@"%@:%d", host, KASA_LEGACY_PORT];
    [self.tcpSockets removeObjectForKey:socketKey];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSDictionary *userData = (NSDictionary *)sock.userData;
    if (userData) {
        NSString *ip = userData[@"ip"];
        NSNumber *port = userData[@"port"];
        if (ip && port) {
            NSString *socketKey = [NSString stringWithFormat:@"%@:%@", ip, port];
            [self.tcpSockets removeObjectForKey:socketKey];
        }
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext {
    NSString *host = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];

    if (!host) return;

    NSLog(@" ---> Kasa Discovery: UDP response from %@:%d (%lu bytes)", host, port, (unsigned long)data.length);

    if ([self.discoveredIPs containsObject:host]) return;

    if (sock == self.legacySocket) {
        [self handleLegacyResponse:data host:host port:port];
    } else if (sock == self.klapSocket) {
        [self handleKLAPResponse:data host:host port:port];
    }
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@" ---> Kasa Discovery: UDP socket closed");
}

#pragma mark - Response Handling

- (void)handleLegacyResponse:(NSData *)data host:(NSString *)host port:(uint16_t)port {
    NSData *decryptedData = [TTModeKasaLegacyProtocol decrypt:data];

    NSString *jsonString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    if (!jsonString) return;

    NSLog(@" ---> Kasa Discovery: Legacy response: %@", jsonString);

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:decryptedData options:0 error:&error];

    if (!error && json) {
        NSDictionary *sysinfo = json[@"system"][@"get_sysinfo"];
        if (sysinfo) {
            [self.discoveredIPs addObject:host];

            NSString *deviceId = sysinfo[@"deviceId"];
            if (!deviceId) deviceId = sysinfo[@"device_id"];
            if (!deviceId) deviceId = sysinfo[@"deviceid"];

            TTModeKasaDevice *device = [self.delegate discoveryFoundDeviceWithIpAddress:host
                                                                                  port:KASA_LEGACY_PORT
                                                                          protocolType:KASA_PROTOCOL_LEGACY
                                                                                  name:sysinfo[@"alias"]
                                                                              deviceId:deviceId
                                                                            macAddress:sysinfo[@"mac"]];
            NSLog(@" ---> Kasa Discovery: Found legacy device: %@", device);
        }
    }
}

- (void)handleKLAPResponse:(NSData *)data host:(NSString *)host port:(uint16_t)port {
    if (data.length <= 16) return;

    // Skip first 16 bytes (header)
    NSData *jsonData = [data subdataWithRange:NSMakeRange(16, data.length - 16)];

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!jsonString) return;

    NSLog(@" ---> Kasa Discovery: KLAP response: %@", jsonString);

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (!error && json) {
        NSDictionary *result = json[@"result"];
        if (result) {
            [self.discoveredIPs addObject:host];

            TTModeKasaDevice *device = [self.delegate discoveryFoundDeviceWithIpAddress:host
                                                                                  port:KASA_KLAP_DISCOVERY_PORT
                                                                          protocolType:KASA_PROTOCOL_KLAP
                                                                                  name:nil
                                                                              deviceId:result[@"device_id"]
                                                                            macAddress:result[@"mac"]];
            NSLog(@" ---> Kasa Discovery: Found KLAP device: %@", device);
        }
    }
}

@end
