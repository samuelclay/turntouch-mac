//
//  TTSegmentedCell.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 6/16/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTSegmentedCell : NSSegmentedCell {
    TTAppDelegate *appDelegate;
    NSDictionary *labelAttributes;
    CGFloat radius;
}

@property(assign) NSInteger highlightedSegment;

@end
