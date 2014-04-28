//
//  TTModeMenuItem.h
//  Turn Touch App
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeMenuItemView.h"
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTModeMenuItem : NSCollectionViewItem {
    TTAppDelegate *appDelegate;
}

@end
