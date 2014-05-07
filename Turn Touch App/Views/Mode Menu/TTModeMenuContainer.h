//
//  TTModeMenuContainer.h
//  Turn Touch App
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeMenuCollectionView.h"
#import "TTModeMenuBordersView.h"
#import "TTAppDelegate.h"

@class TTAppDelegate;
@class TTModeMenuCollectionView;

@interface TTModeMenuContainer : NSView {
    TTAppDelegate *appDelegate;

}

@property (nonatomic) TTModeMenuCollectionView *collectionView;
@property (nonatomic) TTModeMenuBordersView *bordersView;

@end
