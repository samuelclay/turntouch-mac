//
//  TTSerialMonitor.m
//  Turn Touch App
//
//  Created by Samuel Clay on 10/31/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//  Based on work by Gabe Ghearing on 6/30/09.
//

#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#import "TTAppDelegate.h"
#import "TTSerialMonitor.h"
#import "hidapi.h"

#define vendorID    0x16c0
#define productID   0x05df
const int kBaudRate = 9600;
const int MAX_STR   = 255;

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
        
        [self watchForNewUsbDevices];
        [self reload];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)confirmDevice {
    if (hidDevice) {
        unsigned char buf[65];
        int res = 0;
        buf[0] = 0x0;
        res = hid_get_feature_report(hidDevice, buf, sizeof(buf));
        if (res <= 0) {
            NSLog(@"Checking if isOpen: %d", res);
        } else {
            NSLog(@"Confirmed: %d %s", res, buf);
        }
        return res > 0;
    }
    return NO;
}

- (BOOL)isOpen {
    return !!hidDevice;
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
	hidDevice = hid_open(vendorID, productID, NULL);
    
    if (!hidDevice) {
        return;
    }

    [self confirmDevice];

	res = hid_get_manufacturer_string(hidDevice, wstr, MAX_STR);
	res = hid_get_product_string(hidDevice, wstr, MAX_STR);
	printf("Manufacturer String: %S\n", wstr);
	wprintf(L"Product String: %S\n", wstr);
    
    // Start a read poller in the background
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		while (self.isOpen) {
			unsigned char *buf = malloc(4);
			long lengthRead = hid_read_timeout(hidDevice, buf, 64, 10 * 1000);
            if (!self.isOpen) break;
			if (lengthRead > 0) {
				NSData *readData = [NSData dataWithBytes:buf length:lengthRead];
//                NSLog(@"Read: %@", readData);
                
				if (readData != nil) {
					[self serialPortReceivedData:readData];
				}
			} else if (lengthRead < 0) {
                printf("Unable to read()\n");
            }
		}
	});
}

- (void)serialPortReceivedData:(NSData *)data {
	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	if ([string length] == 0) return;
    NSLog(@"Received data: %@", string);
    [self parse:string];
}


#pragma mark - Parse Data

- (void)parse:(NSString *)buffer {
    
    NSMutableArray *substrings = [NSMutableArray new];
    for (int i=0; i < [buffer length]; i++) {
        [substrings addObject:[NSNumber numberWithChar:[buffer characterAtIndex:i]]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [buttonTimer readButtons:substrings];
    });
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

#pragma mark - USB Watcher

- (void)watchForNewUsbDevices {
    io_iterator_t newDevicesIterator;
    io_iterator_t lostDevicesIterator;
    
    newDevicesIterator = 0;
    lostDevicesIterator = 0;
    
    NSMutableDictionary *matchingDict = (__bridge NSMutableDictionary *)IOServiceMatching(kIOUSBDeviceClassName);
    
    if (matchingDict == nil){
        NSLog(@"Could not create matching dictionary");
        return;
    }
    [matchingDict setObject:[NSNumber numberWithShort:vendorID] forKey:(NSString *)CFSTR(kUSBVendorID)];
    [matchingDict setObject:[NSNumber numberWithShort:productID] forKey:(NSString *)CFSTR(kUSBProductID)];
    
    //  Add notification ports to runloop
    IONotificationPortRef notificationPort = IONotificationPortCreate(kIOMasterPortDefault);
    CFRunLoopSourceRef notificationRunLoopSource = IONotificationPortGetRunLoopSource(notificationPort);
    CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], notificationRunLoopSource, kCFRunLoopDefaultMode);
    
    kern_return_t err;
    err = IOServiceAddMatchingNotification(notificationPort,
                                           kIOMatchedNotification,
                                           (__bridge CFDictionaryRef)matchingDict,
                                           usbDeviceAppeared,
                                           (__bridge void *)self,
                                           &newDevicesIterator);
    if (err)
    {
        NSLog(@"error adding publish notification");
    }
    [self matchingDevicesAdded: newDevicesIterator];
    
    
    NSMutableDictionary *matchingDictRemoved = (__bridge NSMutableDictionary *)IOServiceMatching(kIOUSBDeviceClassName);
    
    if (matchingDictRemoved == nil){
        NSLog(@"Could not create matching dictionary");
        return;
    }
    [matchingDictRemoved setObject:[NSNumber numberWithShort:vendorID] forKey:(NSString *)CFSTR(kUSBVendorID)];
    [matchingDictRemoved setObject:[NSNumber numberWithShort:productID] forKey:(NSString *)CFSTR(kUSBProductID)];
    
    
    err = IOServiceAddMatchingNotification(notificationPort,
                                           kIOTerminatedNotification,
                                           (__bridge CFDictionaryRef)matchingDictRemoved,
                                           usbDeviceDisappeared,
                                           (__bridge void *)self,
                                           &lostDevicesIterator);
    if (err)
    {
        NSLog(@"error adding removed notification");
    }
    [self matchingDevicesRemoved: lostDevicesIterator];
    
    
}

#pragma mark - USB Device Notifications

void usbDeviceAppeared(void *refCon, io_iterator_t iterator){
    NSLog(@"Matching USB device appeared");
    TTSerialMonitor *monitor = (__bridge TTSerialMonitor *)refCon;
    [monitor matchingDevicesAdded:iterator];
    [monitor reload];
    
}
void usbDeviceDisappeared(void *refCon, io_iterator_t iterator){
    NSLog(@"Matching USB device disappeared");
    TTSerialMonitor *monitor = (__bridge TTSerialMonitor *)refCon;
    [monitor matchingDevicesRemoved:iterator];
    [monitor reload];
}

- (void)matchingDevicesAdded:(io_iterator_t)devices {
    NSLog(@"matchingDevicesAdded");
    io_object_t thisObject;
    while ( (thisObject = IOIteratorNext(devices))) {
        NSLog(@"new Matching device added ");
        IOObjectRelease(thisObject);
    }
}

- (void)matchingDevicesRemoved:(io_iterator_t)devices {
    NSLog(@"matchingDevicesRemoved");

    if (hidDevice) {
        hid_close(hidDevice);
    }
    hidDevice = nil;

    io_object_t thisObject;
    while ( (thisObject = IOIteratorNext(devices))) {
        NSLog(@"new Matching device removed ");
        IOObjectRelease(thisObject);
    }
}

@end
