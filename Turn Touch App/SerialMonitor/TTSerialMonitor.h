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
#import "hidapi.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <IOKit/serial/ioss.h>
#include <sys/ioctl.h>

@class TTAppDelegate;
@class TTButtonTimer;


@interface TTSerialMonitor : NSObject
<NSUserNotificationCenterDelegate> {
    TTAppDelegate *appDelegate;
    TTButtonTimer *buttonTimer;
    BOOL isVerifiedSerialDevice;
	NSMutableString *textBuffer;
    NSMutableArray *rejectedSerialPorts;
    hid_device *hidDevice;
}

@property (readonly, getter = isOpen) BOOL open;

- (void)reload;
- (void)reload:(BOOL)force;

@end
