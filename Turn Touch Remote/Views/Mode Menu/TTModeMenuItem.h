//
//  TTModeMenuItem.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeMenuCollectionView.h"
#import "TTModeMenuItemView.h"

#define MENU_ITEM_HEIGHT 48.0f

@class TTAppDelegate;
@class TTModeMenuCollectionView;

@interface TTModeMenuItem : NSCollectionViewItem {
    TTAppDelegate *appDelegate;
}

@end
