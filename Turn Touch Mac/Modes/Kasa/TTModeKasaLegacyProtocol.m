//
//  TTModeKasaLegacyProtocol.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasaLegacyProtocol.h"

#define KASA_XOR_INITIAL_KEY 171
#define KASA_LEGACY_PORT 9999

static const NSInteger kSocketTagHeader = 1;
static const NSInteger kSocketTagBody = 2;

@interface TTModeKasaLegacyProtocol ()

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic) UInt16 port;
@property (nonatomic, copy) void (^pendingCallback)(void);
@property (nonatomic, strong) NSData *pendingCommand;

@end

@implementation TTModeKasaLegacyProtocol

- (id)initWithIpAddress:(NSString *)ipAddress port:(UInt16)port {
    if (self = [super init]) {
        self.ipAddress = ipAddress;
        self.port = port;
    }
    return self;
}

#pragma mark - XOR Encryption/Decryption

+ (NSData *)encrypt:(NSData *)plaintext {
    const uint8_t *bytes = plaintext.bytes;
    NSUInteger length = plaintext.length;
    uint8_t *result = malloc(length);
    uint8_t key = KASA_XOR_INITIAL_KEY;

    for (NSUInteger i = 0; i < length; i++) {
        uint8_t encrypted = key ^ bytes[i];
        result[i] = encrypted;
        key = encrypted; // Key advances with ciphertext
    }

    NSData *encryptedData = [NSData dataWithBytes:result length:length];
    free(result);
    return encryptedData;
}

+ (NSData *)decrypt:(NSData *)ciphertext {
    const uint8_t *bytes = ciphertext.bytes;
    NSUInteger length = ciphertext.length;
    uint8_t *result = malloc(length);
    uint8_t key = KASA_XOR_INITIAL_KEY;

    for (NSUInteger i = 0; i < length; i++) {
        uint8_t decrypted = key ^ bytes[i];
        result[i] = decrypted;
        key = bytes[i]; // Key advances with ciphertext (input)
    }

    NSData *decryptedData = [NSData dataWithBytes:result length:length];
    free(result);
    return decryptedData;
}

+ (NSData *)encryptWithHeader:(NSData *)plaintext {
    NSData *encryptedData = [self encrypt:plaintext];

    // 4-byte big-endian length header
    uint32_t length = CFSwapInt32HostToBig((uint32_t)encryptedData.length);
    NSMutableData *packet = [NSMutableData dataWithBytes:&length length:4];
    [packet appendData:encryptedData];

    return packet;
}

#pragma mark - Packet Building

- (NSData *)buildPacket:(NSString *)json {
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [TTModeKasaLegacyProtocol encryptWithHeader:jsonData];
}

#pragma mark - Commands

- (void)requestDeviceInfo {
    NSString *command = @"{\"system\":{\"get_sysinfo\":{}}}";
    [self sendCommand:command];
}

- (void)requestDeviceStateWithCallback:(void (^)(void))callback {
    self.pendingCallback = callback;
    [self requestDeviceInfo];
}

- (void)setRelayState:(NSInteger)state {
    NSString *command = [NSString stringWithFormat:
                         @"{\"system\":{\"set_relay_state\":{\"state\":%ld}}}",
                         (long)state];
    [self sendCommand:command];
}

#pragma mark - TCP Communication

- (void)sendCommand:(NSString *)command {
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                             delegateQueue:dispatch_get_main_queue()];

    NSError *error = nil;
    if (![self.socket connectToHost:self.ipAddress onPort:self.port withTimeout:10 error:&error]) {
        NSLog(@" ---> Kasa Legacy: Failed to connect to %@:%d - %@", self.ipAddress, self.port, error);
        [self.delegate legacyProtocolDidFail:error];
        return;
    }

    self.pendingCommand = [self buildPacket:command];
}

- (void)disconnect {
    [self.socket disconnect];
    self.socket = nil;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@" ---> Kasa Legacy: Connected to %@:%d", host, port);

    [self.socket writeData:self.pendingCommand withTimeout:10 tag:0];
    [self.socket readDataToLength:4 withTimeout:10 tag:kSocketTagHeader];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == kSocketTagHeader) {
        // Parse 4-byte length header
        if (data.length < 4) {
            NSLog(@" ---> Kasa Legacy: Invalid header length");
            [self.delegate legacyProtocolDidFail:nil];
            [self disconnect];
            return;
        }

        uint32_t length;
        [data getBytes:&length length:4];
        length = CFSwapInt32BigToHost(length);
        NSLog(@" ---> Kasa Legacy: Expecting %u bytes of payload", length);

        [self.socket readDataToLength:length withTimeout:10 tag:kSocketTagBody];

    } else if (tag == kSocketTagBody) {
        NSData *decryptedData = [TTModeKasaLegacyProtocol decrypt:data];

        NSString *jsonString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        NSLog(@" ---> Kasa Legacy: Received response: %@", jsonString);

        [self parseResponse:decryptedData];
        [self disconnect];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err) {
        NSLog(@" ---> Kasa Legacy: Disconnected with error: %@", err);
        [self.delegate legacyProtocolDidFail:err];
    }
}

#pragma mark - Response Parsing

- (void)parseResponse:(NSData *)data {
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error || !json) {
        NSLog(@" ---> Kasa Legacy: Failed to parse response: %@", error);
        [self.delegate legacyProtocolDidFail:error];
        return;
    }

    NSDictionary *system = json[@"system"];
    if (!system) return;

    NSDictionary *sysinfo = system[@"get_sysinfo"];
    if (sysinfo) {
        NSString *alias = sysinfo[@"alias"];
        NSString *deviceId = sysinfo[@"deviceId"];
        // TP-Link uses different keys for device ID
        if (!deviceId) deviceId = sysinfo[@"device_id"];
        if (!deviceId) deviceId = sysinfo[@"deviceid"];
        NSString *mac = sysinfo[@"mac"];
        NSInteger relayState = [sysinfo[@"relay_state"] integerValue];

        [self.delegate legacyProtocolDidReceiveState:relayState];
        [self.delegate legacyProtocolDidReceiveDeviceInfoWithAlias:alias
                                                         deviceId:deviceId
                                                       macAddress:mac
                                                       relayState:relayState];

        if (self.pendingCallback) {
            self.pendingCallback();
            self.pendingCallback = nil;
        }
    }

    NSDictionary *setRelay = system[@"set_relay_state"];
    if (setRelay) {
        NSInteger errCode = [setRelay[@"err_code"] integerValue];
        [self.delegate legacyProtocolDidChangeState:(errCode == 0)];
    }
}

@end
