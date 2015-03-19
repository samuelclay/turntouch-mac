//
//  TTPanelArrowView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/1/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@class TTAppDelegate;

#define LINE_THICKNESS 1.0f
#define ARROW_WIDTH 18
#define ARROW_HEIGHT 8
#define CORNER_RADIUS 8.0f

@interface TTPanelArrowView : NSView {
    TTAppDelegate *appDelegate;
}

@property (nonatomic, assign) NSInteger arrowX;

@end
