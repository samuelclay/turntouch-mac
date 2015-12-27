//
//  TTBorder.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/26/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTBorder.h"

@implementation TTBorder

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
        
    NSBezierPath *border = [NSBezierPath bezierPath];
    [border moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
    [border lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
    [NSColorFromRGB(0xC2CBCE) set];
    [border setLineWidth:1.f];
    [border stroke];
}

@end
