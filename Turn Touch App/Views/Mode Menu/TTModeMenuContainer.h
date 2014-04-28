//
//  TTModeMenuContainer.h
//  Turn Touch App
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeMenuItem.h"
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTModeMenuContainer : NSCollectionView {
    TTAppDelegate *appDelegate;

}

@end
