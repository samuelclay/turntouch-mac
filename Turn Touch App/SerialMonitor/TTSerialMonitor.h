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
	IBOutlet NSTextView *serialOutputArea;
	IBOutlet NSTextField *serialInputField;
	IBOutlet NSTextField *baudInputField;
	int serialFileDescriptor; // file handle to the serial port
	struct termios gOriginalTTYAttrs; // Hold the original termios attributes so we can reset them on quit ( best practice )
	bool readThreadRunning;
	NSTextStorage *storage;
}

- (NSString *) openSerialPort: (NSString *)serialPortFile baud: (speed_t)baudRate;
- (void)appendToIncomingText: (id) text;
- (void)incomingTextUpdateThread: (NSThread *) parentThread;
- (void) refreshSerialList;
- (void) writeString: (NSString *) str;
- (void) writeByte: (uint8_t *) val;
- (IBAction) serialPortSelected: (id) cntrl;
- (IBAction) baudAction: (id) cntrl;
- (IBAction) refreshAction: (id) cntrl;
- (IBAction) sendText: (id) cntrl;
- (IBAction) sliderChange: (NSSlider *) sldr;
- (IBAction) hitAButton: (NSButton *) btn;
- (IBAction) hitBButton: (NSButton *) btn;
- (IBAction) hitCButton: (NSButton *) btn;
- (IBAction) resetButton: (NSButton *) btn;

@end
