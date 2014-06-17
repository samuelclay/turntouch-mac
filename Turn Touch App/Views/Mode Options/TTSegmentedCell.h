//
//  TTSegmentedCell.h
//  Turn Touch App
//
//  Created by Samuel Clay on 6/16/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTSegmentedCell : NSSegmentedCell {
    TTAppDelegate *appDelegate;
    NSDictionary *labelAttributes;
}

@property(assign) NSInteger highlightedSegment;

@end
