#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"

FOUNDATION_EXPORT double CocoaAsyncSocketVersionNumber;
FOUNDATION_EXPORT const unsigned char CocoaAsyncSocketVersionString[];

