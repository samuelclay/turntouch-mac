//
//  TTModeKasaKLAPProtocol.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTModeKasaKLAPProtocol;

@protocol TTModeKasaKLAPProtocolDelegate <NSObject>

- (void)klapProtocolDidReceiveDeviceInfoWithNickname:(NSString *)nickname
                                            deviceId:(NSString *)deviceId
                                          macAddress:(NSString *)mac
                                            deviceOn:(BOOL)deviceOn
                                               model:(NSString *)model;
- (void)klapProtocolDidReceiveState:(BOOL)deviceOn;
- (void)klapProtocolDidChangeState:(BOOL)success;
- (void)klapProtocolDidFail:(NSError *)error;
- (void)klapProtocolNeedsAuthentication;

@end

@interface TTModeKasaKLAPProtocol : NSObject

@property (nonatomic, weak) id<TTModeKasaKLAPProtocolDelegate> delegate;

- (id)initWithIpAddress:(NSString *)ipAddress port:(UInt16)port;

- (void)setCredentialsUsername:(NSString *)username password:(NSString *)password;
- (void)requestDeviceInfo;
- (void)setDeviceState:(BOOL)on;

@end
