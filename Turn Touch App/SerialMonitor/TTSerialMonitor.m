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
#import "hidapi.h"

const int kBaudRate = 9600;
const int MAX_STR = 255;

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
        rejectedSerialPorts = [NSMutableArray new];
        
        [self reload];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isOpen {
    if (hidDevice) {
        unsigned char buf[65];
        int res = 0;
        buf[0] = 0;
        res = hid_get_feature_report(hidDevice, buf, sizeof(buf));
        if (res <= 0) NSLog(@"Checking if isOpen: %d", res);
        return res > 0;
    }
    return NO;
}

- (void)reload {
    [self reload:NO];
}

- (void)reload:(BOOL)force {
    if (!force && self.isOpen) return;

    [self autodetectSerialPort];
}

- (void)autodetectSerialPort {
    if (hidDevice) {
        hid_close(hidDevice);
    }
    hidDevice = nil;
    wchar_t wstr[MAX_STR];
	int res = hid_init();
	hidDevice = hid_open(0x16c0, 0x05df, NULL);
    
    if (!hidDevice) {
        return;
    }
    
	res = hid_get_manufacturer_string(hidDevice, wstr, MAX_STR);
	res = hid_get_product_string(hidDevice, wstr, MAX_STR);
	printf("Manufacturer String: %S\n", wstr);
	wprintf(L"Product String: %S\n", wstr);
    
    // Start a read poller in the background
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		while (self.isOpen) {
			unsigned char *buf = malloc(32);
			long lengthRead = hid_read(hidDevice, buf, 32);
            if (!self.isOpen) break;
			if (lengthRead > 0) {
				NSData *readData = [NSData dataWithBytes:buf length:lengthRead];
                NSLog(@"Read: %@", readData);
				if (readData != nil) dispatch_async(dispatch_get_main_queue(), ^{
					[self serialPortReceivedData:readData];
				});
			} else if (lengthRead < 0) {
                printf("Unable to read()\n");
                hid_close(hidDevice);
            }
		}
	});
}

- (void)serialPortReceivedData:(NSData *)data {
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if ([string length] == 0) return;
//    NSLog(@"Received data: %@", string);
    [textBuffer appendString:string];
    [self parseTextBuffer];
}


#pragma mark - Parse Data

- (void)parseTextBuffer {
//    NSLog(@"Parsing buffer: %@", textBuffer);

    if ([textBuffer rangeOfString:@"received"].location != NSNotFound) {
        NSLog(@"Verified serial device!");
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
        [self reload];
    });
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^
    {
        [self reload];
    });
}

@end
