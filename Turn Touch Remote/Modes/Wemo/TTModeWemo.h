//
//  TTModeWemo.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "TTModeWemoMulticastServer.h"

@interface TTModeWemo : TTMode <TTModeWemoMulticastDelegate>

@property (nonatomic) TTModeWemoMulticastServer *multicastServer;

@end
