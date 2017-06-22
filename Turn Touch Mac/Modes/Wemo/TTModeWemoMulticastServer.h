//
//  TTModeWemoMulticastServer.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/22/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "TTModeWemoDevice.h"

@protocol TTModeWemoMulticastDelegate <NSObject>

- (TTModeWemoDevice *)foundDevice:(NSDictionary *)headers host:(NSString *)ipAddress port:(NSInteger)port name:(NSString *)name live:(BOOL)live;
- (void)finishScanning;

@end


@interface TTModeWemoMulticastServer : NSObject <GCDAsyncUdpSocketDelegate> {
    GCDAsyncUdpSocket *udpSocket;
    NSInteger attemptsLeft;
}

@property (nonatomic) id<TTModeWemoMulticastDelegate> delegate;

- (void)beginbroadcast;
- (void)deactivate;

@end
