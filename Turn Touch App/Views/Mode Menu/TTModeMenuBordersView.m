//
//  TTModeMenuBordersView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/7/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeMenuBordersView.h"

@implementation TTModeMenuBordersView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [self drawShadowTop:dirtyRect];
    if (NSHeight(self.bounds) > 36) {
        [self drawShadowBottom:dirtyRect];
    }
}


- (CGImageRef)maskForRectBottom:(NSRect)dirtyRect {
    NSSize size = [self bounds].size;
    size.height = 8;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextClipToRect(context, *(CGRect*)&dirtyRect);
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    
    size_t num_locations = 3;
    CGFloat locations[3] = { 0.0, 0.5, 1.0 };
    CGFloat components[12] = {
        1.0, 1.0, 1.0, 1.0,  // Start color
        0.0, 0.0, 0.0, 1.0,  // Middle color
        1.0, 1.0, 1.0, 1.0,  // End color
    };
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    
    CGPoint myStartPoint = CGPointMake(NSMinX(rect), NSMinY(rect));
    CGPoint myEndPoint = CGPointMake(NSMaxX(rect), NSMinY(rect));
    
    CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);
    
    CGImageRef theImage = CGBitmapContextCreateImage(context);
    CGImageRef theMask = CGImageMaskCreate(CGImageGetWidth(theImage), CGImageGetHeight(theImage), CGImageGetBitsPerComponent(theImage), CGImageGetBitsPerPixel(theImage), CGImageGetBytesPerRow(theImage), CGImageGetDataProvider(theImage), NULL, YES);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return theMask;
}

- (void)drawShadowBottom:(NSRect)dirtyRect {
    [NSGraphicsContext saveGraphicsState];
    
    NSRect nsRect = [self bounds];
    CGRect rect = *(CGRect*)&nsRect;
    CGRect lineRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, (CGFloat)1.0);
    rect.size.height = 8;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextClipToRect(context, *(CGRect*)&dirtyRect);
    CGContextClipToMask(context, rect, [self maskForRectBottom:dirtyRect]);
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        0.315, 0.371, 0.450, 0.1,  // Bottom color
        0.315, 0.371, 0.450, 0.0  // Top color
    };
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    
    CGPoint myStartPoint = CGPointMake(NSMinX(rect), NSMinY(rect));
    CGPoint myEndPoint = CGPointMake(NSMinX(rect), NSMaxY(rect));
    
    CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);
    
    CGContextSetRGBFillColor(context, 0.315, 0.371, 0.450, 0.2 );
    CGContextFillRect(context, lineRect);
    
    CGColorSpaceRelease(colorSpace);
    
    [NSGraphicsContext restoreGraphicsState];
}

- (CGImageRef)maskForRectTop:(NSRect)dirtyRect {
    CGFloat height = fminf(NSHeight(self.bounds), 8);
    NSSize size = [self bounds].size;
    size.height = height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextClipToRect(context, *(CGRect*)&dirtyRect);
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    
    size_t num_locations = 3;
    CGFloat locations[3] = { 0.0, 0.5, 1.0 };
    CGFloat components[12] = {
        1.0, 1.0, 1.0, 1.0,  // Start color
        0.0, 0.0, 0.0, 1.0,  // Middle color
        1.0, 1.0, 1.0, 1.0,  // End color
    };
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    
    CGPoint myStartPoint = CGPointMake(NSMinX(rect), NSMinY(rect));
    CGPoint myEndPoint = CGPointMake(NSMaxX(rect), NSMinY(rect));
    
    CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);
    
    CGImageRef theImage = CGBitmapContextCreateImage(context);
    CGImageRef theMask = CGImageMaskCreate(CGImageGetWidth(theImage), CGImageGetHeight(theImage), CGImageGetBitsPerComponent(theImage), CGImageGetBitsPerPixel(theImage), CGImageGetBytesPerRow(theImage), CGImageGetDataProvider(theImage), NULL, YES);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return theMask;
}

- (void)drawShadowTop:(NSRect)dirtyRect {
    [NSGraphicsContext saveGraphicsState];
    
    NSRect nsRect = [self bounds];
    CGRect rect = *(CGRect*)&nsRect;
    rect.origin.y = rect.size.height - 8;
    rect.size.height = 8;
    CGRect lineRect = CGRectMake(rect.origin.x, NSHeight(self.bounds) - 1, rect.size.width, (CGFloat)1.0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextClipToRect(context, *(CGRect*)&dirtyRect);
    CGContextClipToMask(context, rect, [self maskForRectTop:dirtyRect]);
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        0.315, 0.371, 0.450, 0.0,  // Top color
        0.315, 0.371, 0.450, 0.1  // Bottom color
    };
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    
    CGPoint myStartPoint = CGPointMake(NSMinX(rect), NSMinY(rect));
    CGPoint myEndPoint = CGPointMake(NSMinX(rect), NSMaxY(rect));
    
//    if (height >= 8) {
        CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);
//    }
    
    CGContextSetRGBFillColor(context, 0.315, 0.371, 0.450, 0.2);
    CGContextFillRect(context, lineRect);
    
    CGColorSpaceRelease(colorSpace);
    
    [NSGraphicsContext restoreGraphicsState];
    
}


@end
