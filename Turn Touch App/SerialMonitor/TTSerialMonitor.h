//
//  TTSerialMonitor.h
//  Turn Touch App
//
//  Created by Samuel Clay on 10/31/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//  Based on work by Gabe Ghearing on 6/30/09.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTButtonTimer.h"
#import "ORSSerialPortManager.h"
#import "ORSSerialPort.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <IOKit/serial/ioss.h>
#include <sys/ioctl.h>

@class TTAppDelegate;
@class TTButtonTimer;


@interface TTSerialMonitor : NSObject
<ORSSerialPortDelegate, NSUserNotificationCenterDelegate> {
    TTAppDelegate *appDelegate;
    TTButtonTimer *buttonTimer;
    bool isVerifiedSerialDevice;
	NSMutableString *textBuffer;
}

@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;

- (void)reload;
- (void)reload:(BOOL)force;

@end
