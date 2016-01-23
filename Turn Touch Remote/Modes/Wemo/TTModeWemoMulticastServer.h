//
//  TTModeWemoMulticastServer.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/22/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@protocol TTModeWemoMulticastDelegate <NSObject>

- (void)foundDevice:(NSDictionary *)headers host:(NSString *)ipAddress port:(NSInteger)port;

@end


@interface TTModeWemoMulticastServer : NSObject <GCDAsyncUdpSocketDelegate> {
    NSSocketNativeHandle receiveSocket;
    NSSocketNativeHandle sendSocket;
}

@property (nonatomic) id<TTModeWemoMulticastDelegate> delegate;

- (void)beginbroadcast;

@end
