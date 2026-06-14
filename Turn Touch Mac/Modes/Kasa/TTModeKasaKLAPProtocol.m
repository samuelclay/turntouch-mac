//
//  TTModeKasaKLAPProtocol.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasaKLAPProtocol.h"
#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>

#define KASA_KLAP_HTTP_PORT 80

@interface TTModeKasaKLAPProtocol ()

@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic) UInt16 port;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

// Session state
@property (nonatomic, strong) NSString *sessionCookie;
@property (nonatomic, strong) NSData *localSeed;
@property (nonatomic, strong) NSData *remoteSeed;
@property (nonatomic, strong) NSData *authHash;

// Derived keys
@property (nonatomic, strong) NSData *encryptionKey;
@property (nonatomic, strong) NSData *ivBase;
@property (nonatomic, strong) NSData *signatureKey;
@property (nonatomic) int32_t sequenceNumber;

@property (nonatomic) BOOL isAuthenticated;
@property (nonatomic, strong) NSURLSession *urlSession;

@end

@implementation TTModeKasaKLAPProtocol

- (id)initWithIpAddress:(NSString *)ipAddress port:(UInt16)port {
    if (self = [super init]) {
        self.ipAddress = ipAddress;
        self.port = port;
        self.isAuthenticated = NO;

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 10;
        config.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        self.urlSession = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (void)setCredentialsUsername:(NSString *)username password:(NSString *)password {
    self.username = username;
    self.password = password;
    self.authHash = [self computeAuthHashWithUsername:username password:password];
}

#pragma mark - Authentication Hash

- (NSData *)computeAuthHashWithUsername:(NSString *)username password:(NSString *)password {
    NSData *usernameData = [username dataUsingEncoding:NSUTF8StringEncoding];
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];

    NSData *md5Username = [self md5:usernameData];
    NSData *md5Password = [self md5:passwordData];

    NSMutableData *combined = [NSMutableData dataWithData:md5Username];
    [combined appendData:md5Password];

    return [self md5:combined];
}

#pragma mark - Handshake

- (void)performHandshakeWithCompletion:(void (^)(BOOL success))completion {
    if (!self.authHash) {
        [self.delegate klapProtocolNeedsAuthentication];
        completion(NO);
        return;
    }

    // Generate 16-byte random local seed
    self.localSeed = [self generateRandomBytes:16];
    if (!self.localSeed) {
        completion(NO);
        return;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/app/handshake1",
                                       self.ipAddress, self.port]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = self.localSeed;
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        typeof(self) self = weakSelf;
        if (!self) return;

        if (error) {
            NSLog(@" ---> Kasa KLAP: Handshake1 network error: %@", error);
            completion(NO);
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        // Extract session cookie
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.name isEqualToString:@"TP_SESSIONID"]) {
                self.sessionCookie = cookie.value;
                NSLog(@" ---> Kasa KLAP: Got session cookie: %@", cookie.value);
            }
        }

        if (httpResponse.statusCode != 200 || !data || data.length < 48) {
            NSLog(@" ---> Kasa KLAP: Handshake1 failed with status %ld", (long)httpResponse.statusCode);
            if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                [self.delegate klapProtocolNeedsAuthentication];
            }
            completion(NO);
            return;
        }

        // Response: 16 bytes remote_seed + 32 bytes server_hash
        self.remoteSeed = [data subdataWithRange:NSMakeRange(0, 16)];
        NSData *serverHash = [data subdataWithRange:NSMakeRange(16, 32)];

        // Verify server hash = SHA256(local_seed + auth_hash)
        NSMutableData *expectedHashInput = [NSMutableData dataWithData:self.localSeed];
        [expectedHashInput appendData:self.authHash];
        NSData *expectedHash = [self sha256:expectedHashInput];

        if (![serverHash isEqualToData:expectedHash]) {
            NSLog(@" ---> Kasa KLAP: Server hash verification failed");
            [self.delegate klapProtocolNeedsAuthentication];
            completion(NO);
            return;
        }

        NSLog(@" ---> Kasa KLAP: Handshake1 successful");
        [self performHandshake2WithCompletion:completion];
    }];
    [task resume];
}

- (void)performHandshake2WithCompletion:(void (^)(BOOL success))completion {
    if (!self.remoteSeed || !self.authHash) {
        completion(NO);
        return;
    }

    // Send SHA256(remote_seed + auth_hash)
    NSMutableData *hashInput = [NSMutableData dataWithData:self.remoteSeed];
    [hashInput appendData:self.authHash];
    NSData *clientHash = [self sha256:hashInput];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/app/handshake2",
                                       self.ipAddress, self.port]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = clientHash;
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];

    if (self.sessionCookie) {
        [request setValue:[NSString stringWithFormat:@"TP_SESSIONID=%@", self.sessionCookie]
       forHTTPHeaderField:@"Cookie"];
    }

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        typeof(self) self = weakSelf;
        if (!self) return;

        if (error) {
            NSLog(@" ---> Kasa KLAP: Handshake2 network error: %@", error);
            completion(NO);
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            NSLog(@" ---> Kasa KLAP: Handshake2 failed with status %ld", (long)httpResponse.statusCode);
            if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                [self.delegate klapProtocolNeedsAuthentication];
            }
            completion(NO);
            return;
        }

        NSLog(@" ---> Kasa KLAP: Handshake2 successful");
        [self deriveKeys];
        self.isAuthenticated = YES;
        completion(YES);
    }];
    [task resume];
}

#pragma mark - Key Derivation

- (void)deriveKeys {
    if (!self.localSeed || !self.remoteSeed || !self.authHash) return;

    // Encryption key: SHA256("lsk" + local_seed + remote_seed + auth_hash)[:16]
    NSMutableData *encKeyInput = [NSMutableData dataWithData:[@"lsk" dataUsingEncoding:NSUTF8StringEncoding]];
    [encKeyInput appendData:self.localSeed];
    [encKeyInput appendData:self.remoteSeed];
    [encKeyInput appendData:self.authHash];
    NSData *fullEncHash = [self sha256:encKeyInput];
    self.encryptionKey = [fullEncHash subdataWithRange:NSMakeRange(0, 16)];

    // IV base: SHA256("iv" + local_seed + remote_seed + auth_hash)[:12]
    NSMutableData *ivInput = [NSMutableData dataWithData:[@"iv" dataUsingEncoding:NSUTF8StringEncoding]];
    [ivInput appendData:self.localSeed];
    [ivInput appendData:self.remoteSeed];
    [ivInput appendData:self.authHash];
    NSData *fullIvHash = [self sha256:ivInput];
    self.ivBase = [fullIvHash subdataWithRange:NSMakeRange(0, 12)];

    // Extract sequence number from last 4 bytes
    const uint8_t *ivHashBytes = fullIvHash.bytes;
    self.sequenceNumber = (int32_t)(((uint32_t)ivHashBytes[28] << 24) |
                                    ((uint32_t)ivHashBytes[29] << 16) |
                                    ((uint32_t)ivHashBytes[30] << 8) |
                                    ((uint32_t)ivHashBytes[31]));

    // Signature key: SHA256("ldk" + local_seed + remote_seed + auth_hash)[:28]
    NSMutableData *sigInput = [NSMutableData dataWithData:[@"ldk" dataUsingEncoding:NSUTF8StringEncoding]];
    [sigInput appendData:self.localSeed];
    [sigInput appendData:self.remoteSeed];
    [sigInput appendData:self.authHash];
    NSData *fullSigHash = [self sha256:sigInput];
    self.signatureKey = [fullSigHash subdataWithRange:NSMakeRange(0, 28)];

    NSLog(@" ---> Kasa KLAP: Keys derived, initial sequence: %d", self.sequenceNumber);
}

#pragma mark - Encryption/Decryption

- (NSData *)encryptPayload:(NSData *)plaintext {
    if (!self.encryptionKey || !self.ivBase || !self.signatureKey) return nil;

    // Build IV: ivBase (12 bytes) + seq (4 bytes big-endian)
    self.sequenceNumber += 1;
    NSMutableData *iv = [NSMutableData dataWithData:self.ivBase];
    int32_t seqBigEndian = CFSwapInt32HostToBig(self.sequenceNumber);
    [iv appendBytes:&seqBigEndian length:4];

    // PKCS7 pad the plaintext
    NSData *paddedPlaintext = [self pkcs7Pad:plaintext blockSize:kCCBlockSizeAES128];

    // AES-128-CBC encrypt
    NSData *ciphertext = [self aes128CBCEncrypt:paddedPlaintext key:self.encryptionKey iv:iv];
    if (!ciphertext) return nil;

    // Signature: SHA256(sigKey + seq_bytes + ciphertext)
    NSMutableData *sigInput = [NSMutableData dataWithData:self.signatureKey];
    [sigInput appendBytes:&seqBigEndian length:4];
    [sigInput appendData:ciphertext];
    NSData *signature = [self sha256:sigInput];

    // Result: signature (32 bytes) + ciphertext
    NSMutableData *result = [NSMutableData dataWithData:signature];
    [result appendData:ciphertext];
    return result;
}

- (NSData *)decryptPayload:(NSData *)encryptedData {
    if (encryptedData.length <= 32 || !self.encryptionKey || !self.ivBase) return nil;

    // Skip signature (32 bytes), get ciphertext
    NSData *ciphertext = [encryptedData subdataWithRange:NSMakeRange(32, encryptedData.length - 32)];

    // Build IV with current sequence
    NSMutableData *iv = [NSMutableData dataWithData:self.ivBase];
    int32_t seqBigEndian = CFSwapInt32HostToBig(self.sequenceNumber);
    [iv appendBytes:&seqBigEndian length:4];

    // AES-128-CBC decrypt
    NSData *paddedPlaintext = [self aes128CBCDecrypt:ciphertext key:self.encryptionKey iv:iv];
    if (!paddedPlaintext) return nil;

    return [self pkcs7Unpad:paddedPlaintext];
}

#pragma mark - Commands

- (void)requestDeviceInfo {
    NSString *command = @"{\"method\":\"get_device_info\"}";
    __weak typeof(self) weakSelf = self;
    [self sendCommand:command completion:^(NSData *data, NSError *error) {
        typeof(self) self = weakSelf;
        if (!self) return;
        if (error || !data) {
            [self.delegate klapProtocolDidFail:error];
            return;
        }
        [self parseDeviceInfoResponse:data];
    }];
}

- (void)setDeviceState:(BOOL)on {
    NSString *command = [NSString stringWithFormat:
                         @"{\"method\":\"set_device_info\",\"params\":{\"device_on\":%@}}",
                         on ? @"true" : @"false"];
    __weak typeof(self) weakSelf = self;
    [self sendCommand:command completion:^(NSData *data, NSError *error) {
        typeof(self) self = weakSelf;
        if (!self) return;
        if (error) {
            [self.delegate klapProtocolDidFail:error];
        } else {
            [self.delegate klapProtocolDidChangeState:YES];
        }
    }];
}

- (void)sendCommand:(NSString *)command completion:(void (^)(NSData *data, NSError *error))completion {
    if (!self.isAuthenticated) {
        __weak typeof(self) weakSelf = self;
        [self performHandshakeWithCompletion:^(BOOL success) {
            typeof(self) self = weakSelf;
            if (!self) return;
            if (success) {
                [self sendCommand:command completion:completion];
            } else {
                completion(nil, [NSError errorWithDomain:@"TTKasaKLAP"
                                                    code:-1
                                                userInfo:@{NSLocalizedDescriptionKey: @"Handshake failed"}]);
            }
        }];
        return;
    }

    NSData *commandData = [command dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [self encryptPayload:commandData];
    if (!encryptedData) {
        completion(nil, [NSError errorWithDomain:@"TTKasaKLAP"
                                            code:-2
                                        userInfo:@{NSLocalizedDescriptionKey: @"Encryption failed"}]);
        return;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/app/request?seq=%d",
                                       self.ipAddress, self.port, self.sequenceNumber]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = encryptedData;
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];

    if (self.sessionCookie) {
        [request setValue:[NSString stringWithFormat:@"TP_SESSIONID=%@", self.sessionCookie]
       forHTTPHeaderField:@"Cookie"];
    }

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        typeof(self) self = weakSelf;
        if (!self) return;

        if (error) {
            completion(nil, error);
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (httpResponse.statusCode == 403) {
            // Session expired, re-authenticate
            self.isAuthenticated = NO;
            [self performHandshakeWithCompletion:^(BOOL success) {
                if (success) {
                    [self sendCommand:command completion:completion];
                } else {
                    completion(nil, [NSError errorWithDomain:@"TTKasaKLAP"
                                                        code:-3
                                                    userInfo:@{NSLocalizedDescriptionKey: @"Re-authentication failed"}]);
                }
            }];
            return;
        }

        if (httpResponse.statusCode != 200 || !data) {
            completion(nil, [NSError errorWithDomain:@"TTKasaKLAP"
                                                code:httpResponse.statusCode
                                            userInfo:@{NSLocalizedDescriptionKey: @"Invalid response"}]);
            return;
        }

        NSData *decryptedData = [self decryptPayload:data];
        if (!decryptedData) {
            completion(nil, [NSError errorWithDomain:@"TTKasaKLAP"
                                                code:-4
                                            userInfo:@{NSLocalizedDescriptionKey: @"Decryption failed"}]);
            return;
        }

        completion(decryptedData, nil);
    }];
    [task resume];
}

#pragma mark - Response Parsing

- (void)parseDeviceInfoResponse:(NSData *)data {
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error || !json) {
        NSLog(@" ---> Kasa KLAP: Failed to parse device info: %@", error);
        [self.delegate klapProtocolDidFail:error];
        return;
    }

    NSDictionary *result = json[@"result"];
    if (result) {
        NSString *nickname = result[@"nickname"];
        NSString *deviceId = result[@"device_id"];
        NSString *mac = result[@"mac"];
        NSString *model = result[@"model"];
        BOOL deviceOn = [result[@"device_on"] boolValue];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate klapProtocolDidReceiveDeviceInfoWithNickname:nickname
                                                              deviceId:deviceId
                                                            macAddress:mac
                                                              deviceOn:deviceOn
                                                                 model:model];
            [self.delegate klapProtocolDidReceiveState:deviceOn];
        });
    }
}

#pragma mark - Crypto Utilities

- (NSData *)md5:(NSData *)data {
    uint8_t digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, digest);
    return [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

- (NSData *)sha256:(NSData *)data {
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

- (NSData *)generateRandomBytes:(NSUInteger)count {
    uint8_t *bytes = malloc(count);
    OSStatus status = SecRandomCopyBytes(kSecRandomDefault, count, bytes);
    if (status != errSecSuccess) {
        free(bytes);
        return nil;
    }
    NSData *data = [NSData dataWithBytes:bytes length:count];
    free(bytes);
    return data;
}

- (NSData *)pkcs7Pad:(NSData *)data blockSize:(NSUInteger)blockSize {
    NSUInteger paddingLength = blockSize - (data.length % blockSize);
    NSMutableData *padded = [NSMutableData dataWithData:data];
    uint8_t paddingByte = (uint8_t)paddingLength;
    for (NSUInteger i = 0; i < paddingLength; i++) {
        [padded appendBytes:&paddingByte length:1];
    }
    return padded;
}

- (NSData *)pkcs7Unpad:(NSData *)data {
    if (data.length == 0) return nil;
    const uint8_t *bytes = data.bytes;
    uint8_t paddingLength = bytes[data.length - 1];
    if (paddingLength == 0 || paddingLength > 16 || data.length < paddingLength) return nil;
    return [data subdataWithRange:NSMakeRange(0, data.length - paddingLength)];
}

- (NSData *)aes128CBCEncrypt:(NSData *)data key:(NSData *)key iv:(NSData *)iv {
    size_t outLength = 0;
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES,
                                     0, // No padding - we handle PKCS7 manually
                                     key.bytes, key.length,
                                     iv.bytes,
                                     data.bytes, data.length,
                                     buffer, bufferSize,
                                     &outLength);

    if (status != kCCSuccess) {
        free(buffer);
        return nil;
    }

    NSData *result = [NSData dataWithBytes:buffer length:outLength];
    free(buffer);
    return result;
}

- (NSData *)aes128CBCDecrypt:(NSData *)data key:(NSData *)key iv:(NSData *)iv {
    size_t outLength = 0;
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    CCCryptorStatus status = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES,
                                     0, // No padding - we handle PKCS7 manually
                                     key.bytes, key.length,
                                     iv.bytes,
                                     data.bytes, data.length,
                                     buffer, bufferSize,
                                     &outLength);

    if (status != kCCSuccess) {
        free(buffer);
        return nil;
    }

    NSData *result = [NSData dataWithBytes:buffer length:outLength];
    free(buffer);
    return result;
}

@end
