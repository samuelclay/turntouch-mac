//
//  TTSerialMonitor.m
//  Turn Touch App
//
//  Created by Samuel Clay on 10/31/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//  Based on work by Gabe Ghearing on 6/30/09.
//

#import "TTAppDelegate.h"
#import "TTSerialMonitor.h"

const int kBaudRate = 57600;

@implementation TTSerialMonitor

// executes after everything in the xib/nib is initiallized
- (id)init {
    self = [super init];
    
    if (self) {
        // we don't have a serial port open yet
        serialFileDescriptor = -1;
        readThreadRunning = FALSE;
        serialDeviceNames = [NSMutableArray array];
        appDelegate = [NSApp delegate];
        buttonTimer = [[TTButtonTimer alloc] init];
        textBuffer = [[NSMutableString alloc] init];
        
        // first thing is to refresh the serial port list
        [self refreshSerialList];
        [self autoSelectSerialDevice];
    }
    
    return self;
}

- (void)dealloc {
    if (serialFileDescriptor != -1) {
        close(serialFileDescriptor);
        serialFileDescriptor = -1;
    }
}

- (void)autoSelectSerialDevice {
    for (NSString *serialDevice in serialDeviceNames) {
        if ([serialDevice rangeOfString:@"usbserial"].location != NSNotFound) {
            selectedSerialDevice = serialDevice;
            [self serialPortSelected:nil];
            break;
        }
    }
}

// open the serial port
//   - nil is returned on success
//   - an error message is returned otherwise
- (NSString *) openSerialPort: (NSString *)serialPortFile baud: (speed_t)baudRate {
	int success;
	
	// close the port if it is already open
	if (serialFileDescriptor != -1) {
		close(serialFileDescriptor);
		serialFileDescriptor = -1;
		
		// wait for the reading thread to die
		while(readThreadRunning);
		
		// re-opening the same port REALLY fast will fail spectacularly... better to sleep a sec
		sleep(0.5);
	}
	
	// c-string path to serial-port file
	const char *bsdPath = [serialPortFile cStringUsingEncoding:NSUTF8StringEncoding];
	
	// Hold the original termios attributes we are setting
	struct termios options;
	
	// receive latency ( in microseconds )
	unsigned long mics = 3;
	
	// error message string
	NSString *errorMessage;
	
	// open the port
	//     O_NONBLOCK causes the port to open without any delay (we'll block with another call)
	serialFileDescriptor = open(bsdPath, O_RDWR | O_NOCTTY | O_NONBLOCK );
	
	if (serialFileDescriptor == -1) {
		// check if the port opened correctly
		errorMessage = @"Error: couldn't open serial port";
	} else {
		// TIOCEXCL causes blocking of non-root processes on this serial-port
		success = ioctl(serialFileDescriptor, TIOCEXCL);
		if ( success == -1) {
			errorMessage = @"Error: couldn't obtain lock on serial port";
		} else {
			success = fcntl(serialFileDescriptor, F_SETFL, 0);
			if ( success == -1) {
				// clear the O_NONBLOCK flag; all calls from here on out are blocking for non-root processes
				errorMessage = @"Error: couldn't obtain lock on serial port";
			} else {
				// Get the current options and save them so we can restore the default settings later.
				success = tcgetattr(serialFileDescriptor, &gOriginalTTYAttrs);
				if ( success == -1) {
					errorMessage = @"Error: couldn't get serial attributes";
				} else {
					// copy the old termios settings into the current
					//   you want to do this so that you get all the control characters assigned
					options = gOriginalTTYAttrs;
					
					/*
					 cfmakeraw(&options) is equivilent to:
					 options->c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
					 options->c_oflag &= ~OPOST;
					 options->c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
					 options->c_cflag &= ~(CSIZE | PARENB);
					 options->c_cflag |= CS8;
					 */
					cfmakeraw(&options);
					
					// set tty attributes (raw-mode in this case)
					success = tcsetattr(serialFileDescriptor, TCSANOW, &options);
					if ( success == -1) {
						errorMessage = @"Error: coudln't set serial attributes";
					} else {
						// Set baud rate (any arbitrary baud rate can be set this way)
						success = ioctl(serialFileDescriptor, IOSSIOSPEED, &baudRate);
						if ( success == -1) {
							errorMessage = @"Error: Baud Rate out of bounds";
						} else {
							// Set the receive latency (a.k.a. don't wait to buffer data)
							success = ioctl(serialFileDescriptor, IOSSDATALAT, &mics);
							if ( success == -1) {
								errorMessage = @"Error: coudln't set serial latency";
							}
						}
					}
				}
			}
		}
	}
	
	// make sure the port is closed if a problem happens
	if ((serialFileDescriptor != -1) && (errorMessage != nil)) {
		close(serialFileDescriptor);
		serialFileDescriptor = -1;
	}
	
	return errorMessage;
}

// updates the textarea for incoming text by appending text
- (void)appendToIncomingText: (id) text {
	// add the text to the textarea
    if (!text) return;
//    NSLog(@"Incoming text: %@", text);
//    NSLog(@"TextBuffer: %@", textBuffer);
    [textBuffer appendString:text];
    [self parseTextBuffer];
}

- (void)parseTextBuffer {
    NSMutableArray *substrings = [NSMutableArray new];
    NSScanner *scanner = [NSScanner scannerWithString:textBuffer];
    [scanner scanUpToString:@"START:" intoString:nil];
    [scanner scanString:@"START:" intoString:nil];
    while (![scanner isAtEnd]) {
        NSString *substring = nil;
        [scanner scanString:@":" intoString:nil];
        if ([scanner scanUpToString:@":" intoString:&substring]) {
            if ([substring isEqualToString:@"END"]) break;
            [substrings addObject:[NSNumber numberWithBool:[substring boolValue]]];
        } else {
            break;
        }
    }
//    NSLog(@"Substrings: %@", substrings);
    if ([substrings count] == 4) {
//        NSLog(@"Clearing text buffer");
        [buttonTimer readButtons:substrings];
        [textBuffer setString:@""];
    } else {
//        NSLog(@"Not yet clearing text buffer: %@", textBuffer);
    }
}

// This selector/function will be called as another thread...
//  this thread will read from the serial port and exits when the port is closed
- (void)incomingTextUpdateThread: (NSThread *) parentThread {
	
	// create a pool so we can use regular Cocoa stuff
	//   child threads can't re-use the parent's autorelease pool
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// mark that the thread is running
	readThreadRunning = TRUE;
	
	const ssize_t BUFFER_SIZE = 100;
	char byte_buffer[BUFFER_SIZE]; // buffer for holding incoming data
	ssize_t numBytes=0; // number of bytes read during read
	NSString *text; // incoming text from the serial port
	
	// assign a high priority to this thread
	[NSThread setThreadPriority:1.0];
	
	// this will loop unitl the serial port closes
	while(TRUE) {
		// read() blocks until some data is available or the port is closed
		numBytes = read(serialFileDescriptor, byte_buffer, BUFFER_SIZE); // read up to the size of the buffer
		if(numBytes>0) {
			// create an NSString from the incoming bytes (the bytes aren't null terminated)
			text = [NSString stringWithCString:byte_buffer length:numBytes];
			
			// this text can't be directly sent to the text area from this thread
			//  BUT, we can call a selctor on the main thread.
			[self performSelectorOnMainThread:@selector(appendToIncomingText:)
                                   withObject:text
                                waitUntilDone:YES];
		} else {
			break; // Stop the thread if there is an error
		}
	}
	
	// make sure the serial port is closed
	if (serialFileDescriptor != -1) {
		close(serialFileDescriptor);
		serialFileDescriptor = -1;
	}
	
	// mark that the thread has quit
	readThreadRunning = FALSE;
}

- (void) refreshSerialList {
	io_object_t serialPort;
	io_iterator_t serialPortIterator;
	
	// remove everything from the pull down list
	[serialDeviceNames removeAllObjects];
	
	// ask for all the serial ports
	IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(kIOSerialBSDServiceValue), &serialPortIterator);
	
	// loop through all the serial ports and add them to the array
	while ((serialPort = IOIteratorNext(serialPortIterator))) {
        [serialDeviceNames addObject:
         (__bridge NSString*)IORegistryEntryCreateCFProperty(serialPort, CFSTR(kIOCalloutDeviceKey),  kCFAllocatorDefault, 0)];
		IOObjectRelease(serialPort);
	}
	
	IOObjectRelease(serialPortIterator);
}

// send a string to the serial port
- (void) writeString: (NSString *) str {
	if(serialFileDescriptor!=-1) {
		write(serialFileDescriptor, [str cStringUsingEncoding:NSUTF8StringEncoding], [str length]);
	} else {
		// make sure the user knows they should select a serial port
		[self appendToIncomingText:@"\n ERROR:  Select a Serial Port from the pull-down menu\n"];
	}
}

// send a byte to the serial port
- (void) writeByte: (uint8_t *) val {
	if(serialFileDescriptor!=-1) {
		write(serialFileDescriptor, val, 1);
	} else {
		// make sure the user knows they should select a serial port
		[self appendToIncomingText:@"\n ERROR:  Select a Serial Port from the pull-down menu\n"];
	}
}

// action sent when serial port selected
- (IBAction) serialPortSelected: (id) cntrl {
	// open the serial port
	NSString *error = [self openSerialPort: selectedSerialDevice baud:kBaudRate];
	
	if(error!=nil) {
		[self refreshSerialList];
		[self appendToIncomingText:error];
	} else {
		[self refreshSerialList];
        [self resetButton:nil];
		[self performSelectorInBackground:@selector(incomingTextUpdateThread:) withObject:[NSThread currentThread]];
	}
}

// action from baud rate change
- (IBAction) baudAction: (id) cntrl {
	if (serialFileDescriptor != -1) {
		speed_t baudRate = kBaudRate;
		
		// if the new baud rate isn't possible, refresh the serial list
		//   this will also deselect the current serial port
		if(ioctl(serialFileDescriptor, IOSSIOSPEED, &baudRate)==-1) {
			[self refreshSerialList];
			[self appendToIncomingText:@"Error: Baud Rate out of bounds"];
		}
	}
}

// action from refresh button
- (IBAction) refreshAction: (id) cntrl {
	[self refreshSerialList];
	
	// close serial port if open
	if (serialFileDescriptor != -1) {
		close(serialFileDescriptor);
		serialFileDescriptor = -1;
	}
}

// action from send button and on return in the text field
- (IBAction) sendText: (id) cntrl {
	// send the text to the Arduino
	[self writeString:[serialInputField stringValue]];
	
	// blank the field
	[serialInputField setTitleWithMnemonic:@""];
}

// action from send button and on return in the text field
- (IBAction) sliderChange: (NSSlider *) sldr {
	uint8_t val = [sldr intValue];
	[self writeByte:&val];
}


// action from the A button
- (IBAction) hitAButton: (NSButton *) btn {
	[self writeString:@"A"];
}

// action from the B button
- (IBAction) hitBButton: (NSButton *) btn {
	[self writeString:@"B"];
}

// action from the C button
- (IBAction) hitCButton: (NSButton *) btn {
	[self writeString:@"C"];
}

// action from the reset button
- (IBAction) resetButton: (NSButton *) btn {
	// set and clear DTR to reset an arduino
	struct timespec interval = {0,100000000}, remainder;
	if(serialFileDescriptor!=-1) {
		ioctl(serialFileDescriptor, TIOCSDTR);
		nanosleep(&interval, &remainder); // wait 0.1 seconds
		ioctl(serialFileDescriptor, TIOCCDTR);
	}
}

@end
