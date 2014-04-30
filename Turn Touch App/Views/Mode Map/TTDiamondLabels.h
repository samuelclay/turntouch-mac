//
//  TTDiamondLabels.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/7/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTDiamondLabel.h"

@class TTAppDelegate;
@class TTDiamondLabel;

@interface TTDiamondLabels : NSView {
    TTAppDelegate *appDelegate;
    NSRect diamondRect;
    CGSize textSize;
    
    NSBezierPath *northLine;
    NSBezierPath *eastLine;
    NSBezierPath *westLine;
    NSBezierPath *southLine;
    
    TTDiamondLabel *northLabel;
    TTDiamondLabel *eastLabel;
    TTDiamondLabel *westLabel;
    TTDiamondLabel *southLabel;
    
    TTDiamondView *diamondView;
}

@property (nonatomic) NSRect diamondRect;

- (id)initWithFrame:(NSRect)frame diamondRect:(NSRect)theDiamondRect;
- (void)drawLabels;

@end
