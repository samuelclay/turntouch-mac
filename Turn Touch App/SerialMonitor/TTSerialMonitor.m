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

const int kBaudRate = 9600;

@implementation TTSerialMonitor

// executes after everything in the xib/nib is initiallized
- (id)init {
    self = [super init];
    
    if (self) {
        // we don't have a serial port open yet
        isVerifiedSerialDevice = NO;
        appDelegate = [NSApp delegate];
        buttonTimer = [[TTButtonTimer alloc] init];
        textBuffer = [NSMutableString new];
        self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(serialPortsWereConnected:)
                   name:ORSSerialPortsWereConnectedNotification object:nil];
		[nc addObserver:self selector:@selector(serialPortsWereDisconnected:)
                   name:ORSSerialPortsWereDisconnectedNotification object:nil];
    
		[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

        [self reload];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload {
    [self reload:NO];
}

- (void)reload:(BOOL)force {
    if (!force && self.serialPort && self.serialPort.isOpen) return;

    [self autodetectSerialPort];
}

- (void)autodetectSerialPort {
    if (self.serialPort && self.serialPort.isOpen) {
        [self.serialPort close];
    }
    self.serialPort = nil;
    isVerifiedSerialDevice = NO;
    
    for (ORSSerialPort *serialDevice in [self.serialPortManager availablePorts]) {
        if ([serialDevice.name rangeOfString:@"usbserial"].location != NSNotFound ||
            [serialDevice.name rangeOfString:@"usbmodem"].location != NSNotFound) {
            NSLog(@"Found serial device %@: %@", serialDevice, serialDevice.name);
            self.serialPort = serialDevice;
            [self.serialPort setBaudRate:[NSNumber numberWithInt:kBaudRate]];
            [self.serialPort open];
            [self.serialPort sendData:[@"X" dataUsingEncoding:NSUTF8StringEncoding]];
            break;
        }
    }
    
    if (!self.serialPort) {
        NSLog(@"Didn't find serial device.");
    }
}

#pragma mark - ORSSerialPortDelegate Methods

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    NSLog(@"Opened serial port: %@", serialPort);
    [textBuffer setString:@""];
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    NSLog(@"Closed serial port: %@", serialPort);
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if ([string length] == 0) return;
//    NSLog(@"Received data: %@", string);
    [textBuffer appendString:string];
    [self parseTextBuffer];
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
{
	// After a serial port is removed from the system, it is invalid and we must discard any references to it
	self.serialPort = nil;
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
	NSLog(@"Serial port %@ encountered an error: %@", serialPort, error);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, object, keyPath);
	NSLog(@"Change dictionary: %@", change);
}

#pragma mark - Parse Data

- (void)parseTextBuffer {
//    NSLog(@"Parsing buffer: %@", textBuffer);

    if ([textBuffer rangeOfString:@"received"].location != NSNotFound) {
        isVerifiedSerialDevice = YES;
        [textBuffer setString:@""];
    }

    NSMutableArray *substrings = [NSMutableArray new];
    NSScanner *scanner = [NSScanner scannerWithString:textBuffer];
    [scanner scanUpToString:@"START:" intoString:nil];
    [scanner scanString:@"START:" intoString:nil];
    while (![scanner isAtEnd]) {
        NSString *substring = nil;
        [scanner scanString:@":" intoString:nil];
        if ([scanner scanUpToString:@":" intoString:&substring]) {
            if ([substring isEqualToString:@"END"]) break;
            [substrings addObject:[NSNumber numberWithInteger:[substring integerValue]]];
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

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[center removeDeliveredNotification:notification];
	});
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	return YES;
}

#pragma mark - Notifications

- (void)serialPortsWereConnected:(NSNotification *)notification
{
	NSArray *connectedPorts = [[notification userInfo] objectForKey:ORSConnectedSerialPortsKey];
	NSLog(@"Ports were connected: %@", connectedPorts);
	[self postUserNotificationForConnectedPorts:connectedPorts];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
        [self reload];
    });
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification
{
	NSArray *disconnectedPorts = [[notification userInfo] objectForKey:ORSDisconnectedSerialPortsKey];
	NSLog(@"Ports were disconnected: %@", disconnectedPorts);
	[self postUserNotificationForDisconnectedPorts:disconnectedPorts];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^
    {
        [self reload];
    });
}

- (void)postUserNotificationForConnectedPorts:(NSArray *)connectedPorts
{
	if (!NSClassFromString(@"NSUserNotificationCenter")) return;
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	for (ORSSerialPort *port in connectedPorts)
	{
		NSUserNotification *userNote = [[NSUserNotification alloc] init];
		userNote.title = NSLocalizedString(@"Serial Port Connected", @"Serial Port Connected");
		NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was connected to your Mac.", @"Serial port connected user notification informative text");
		userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
		userNote.soundName = nil;
		[unc deliverNotification:userNote];
	}
}

- (void)postUserNotificationForDisconnectedPorts:(NSArray *)disconnectedPorts
{
	if (!NSClassFromString(@"NSUserNotificationCenter")) return;
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	for (ORSSerialPort *port in disconnectedPorts)
	{
		NSUserNotification *userNote = [[NSUserNotification alloc] init];
		userNote.title = NSLocalizedString(@"Serial Port Disconnected", @"Serial Port Disconnected");
		NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was disconnected from your Mac.", @"Serial port disconnected user notification informative text");
		userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
		userNote.soundName = nil;
		[unc deliverNotification:userNote];
	}
}


#pragma mark - Properties

@synthesize serialPortManager = _serialPortManager;
- (void)setSerialPortManager:(ORSSerialPortManager *)manager
{
	if (manager != _serialPortManager)
	{
		[_serialPortManager removeObserver:self forKeyPath:@"availablePorts"];
		_serialPortManager = manager;
		NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
		[_serialPortManager addObserver:self forKeyPath:@"availablePorts" options:options context:NULL];
	}
}

@synthesize serialPort = _serialPort;
- (void)setSerialPort:(ORSSerialPort *)port
{
	if (port != _serialPort)
	{
		[_serialPort close];
		_serialPort.delegate = nil;
		
		_serialPort = port;
		
		_serialPort.delegate = self;
	}
}

@end
