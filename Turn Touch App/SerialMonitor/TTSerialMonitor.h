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

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <IOKit/serial/ioss.h>
#include <sys/ioctl.h>

@class TTAppDelegate;
@class TTButtonTimer;

@interface TTSerialMonitor : NSObject {
    TTAppDelegate *appDelegate;
    TTButtonTimer *buttonTimer;
	NSMutableArray *serialDeviceNames;
    NSString *selectedSerialDevice;
    bool vertifiedSerialDevice;
	IBOutlet NSTextField *serialInputField;
	IBOutlet NSTextField *baudInputField;
	int serialFileDescriptor; // file handle to the serial port
	struct termios gOriginalTTYAttrs; // Hold the original termios attributes so we can reset them on quit ( best practice )
	bool readThreadRunning;
	NSMutableString *textBuffer;
}

- (void)reload;
- (void)reload:(BOOL)force;
- (NSString *) openSerialPort: (NSString *)serialPortFile baud: (speed_t)baudRate;
- (void)appendToIncomingText: (id) text;
- (void)incomingTextUpdateThread: (NSThread *) parentThread;
- (void) refreshSerialList;
- (BOOL) writeString: (NSString *) str;
- (BOOL) writeByte: (uint8_t *) val;
- (void)autoSelectSerialDevice;
- (void) serialPortSelected: (id) cntrl;
- (void)resetSerialPort;

@end
