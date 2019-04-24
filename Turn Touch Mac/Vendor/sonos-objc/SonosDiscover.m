//
//  SonosDiscover.m
//  Sonos Controller
//
//  Created by Axel Möller on 21/11/13.
//  Copyright (c) 2013 Appreviation AB. All rights reserved.
//

#import "SonosDiscover.h"
#import "XMLReader.h"
#import "SonosController.h"

typedef void (^findDevicesBlock)(NSArray *ipAddresses);

@interface SonosDiscover ()
- (void)findDevices:(findDevicesBlock)block;
- (void)stopDiscovery;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) findDevicesBlock completionBlock;
@property (nonatomic, strong) NSArray *ipAddressesArray;
@end

@implementation SonosDiscover

+ (void)discoverControllers:(void (^)(NSArray *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SonosDiscover *discover = [[SonosDiscover alloc] init];
        [discover findDevices:^(NSArray *ipAddresses) {
            __block NSMutableArray         *controllers      = [[NSMutableArray alloc] init];
            __block dispatch_semaphore_t   responseSemaphore = dispatch_semaphore_create(1);
            __block int                    responseCount     = 0;
            __block void (^callCompletionHandlerIfReady)(void)   = ^{
                dispatch_semaphore_wait(responseSemaphore, DISPATCH_TIME_FOREVER);
                responseCount++;
                BOOL shouldCallCompletionHandler = responseCount == ipAddresses.count;
                dispatch_semaphore_signal(responseSemaphore);
                if (shouldCallCompletionHandler) {
                    completion([controllers valueForKeyPath:@"@distinctUnionOfObjects.self"]);
                    controllers                  = nil;
                    responseSemaphore            = nil;
                    callCompletionHandlerIfReady = nil;
                }
            };
            if (ipAddresses.count == 0) {
                callCompletionHandlerIfReady();
                return;
            }
            void (^handler)(SonosController *) = ^(SonosController *controller) {
                [controllers addObject:controller];
                callCompletionHandlerIfReady();
            };
          
            for (NSString *ipAddress in ipAddresses) {
                NSArray *ipParts = [ipAddress componentsSeparatedByString:@":"];
                SonosController *controller = [[SonosController alloc] initWithIP:ipParts[0] port:[ipParts[1] intValue]];
                [controller refresh:^(NSError * _Nullable error) {
                  handler(controller);
                }];
            }
        }];
    });
}

- (void)findDevices:(findDevicesBlock)block {
    self.completionBlock = block;
    self.ipAddressesArray = [NSArray array];
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    NSError *error = nil;
    if(![self.udpSocket bindToPort:0 error:&error]) {
        NSLog(@"Error binding");
    }

    if(![self.udpSocket beginReceiving:&error]) {
        NSLog(@"Error receiving");
    }

    [self.udpSocket enableBroadcast:TRUE error:&error];
    if(error) {
        NSLog(@"Error enabling broadcast");
    }

    NSString *str = @"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp: discover\"\r\nMX: 3\r\nST: urn:schemas-upnp-org:device:ZonePlayer:1\r\n\r\n";
    [self.udpSocket sendData:[str dataUsingEncoding:NSUTF8StringEncoding] toHost:@"239.255.255.250" port:1900 withTimeout:-1 tag:0];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self stopDiscovery];
    });
}

- (void)stopDiscovery {
    [self.udpSocket close];
    self.udpSocket = nil;
    self.completionBlock(self.ipAddressesArray);
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(msg) {
        NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@"http:\\/\\/(.*?):1400\\/" options:0 error:nil];
        NSArray *matches = [reg matchesInString:msg options:0 range:NSMakeRange(0, msg.length)];
        if (matches.count > 0) {
            NSTextCheckingResult *result = matches[0];
            NSString *matched = [msg substringWithRange:[result rangeAtIndex:0]];
            NSString *ip = [[matched substringFromIndex:7] substringToIndex:matched.length-8];
            self.ipAddressesArray = [self.ipAddressesArray arrayByAddingObject:ip];
        }
    }
}

@end
