//
//  TTDiamondLabels.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/7/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTDiamondLabels : NSView {
    TTAppDelegate *appDelegate;
    NSRect diamondRect;
    NSDictionary *labelAttributes;
    CGSize textSize;
}

- (id)initWithFrame:(NSRect)frame diamondRect:(NSRect)theDiamondRect;

@end
