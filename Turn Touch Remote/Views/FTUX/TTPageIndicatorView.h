//
//  TTPageIndicatorView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTPanelStates.h"

@interface TTPageIndicatorView : NSView {
    TTAppDelegate *appDelegate;
    TTModalFTUX modalFTUX;
    NSTrackingArea *trackingArea;
    BOOL highlighted;
    BOOL selected;
}

@property (nonatomic) TTModalFTUX modalFTUX;

@end
