//
//  TTModeKasaDiscovery.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "TTModeKasaDevice.h"

@protocol TTModeKasaDiscoveryDelegate <NSObject>

- (TTModeKasaDevice *)discoveryFoundDeviceWithIpAddress:(NSString *)ipAddress
                                                   port:(UInt16)port
                                           protocolType:(TTKasaProtocolType)protocolType
                                                   name:(NSString *)name
                                               deviceId:(NSString *)deviceId
                                             macAddress:(NSString *)macAddress;
- (void)discoveryFinishedScanning;

@end

@interface TTModeKasaDiscovery : NSObject <GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate>

@property (nonatomic, weak) id<TTModeKasaDiscoveryDelegate> delegate;

- (void)beginDiscovery;
- (void)stopDiscovery;
- (void)deactivate;

@end
