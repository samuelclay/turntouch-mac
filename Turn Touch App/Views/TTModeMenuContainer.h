//
//  TTModeMenuContainer.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeMenuItem.h"

@class TTModeMenuItem;

@interface TTModeMenuContainer : NSView {
    TTModeMenuItem *northItem;
    TTModeMenuItem *eastItem;
    TTModeMenuItem *westItem;
    TTModeMenuItem *southItem;
}

@property (nonatomic) TTModeMenuItem *northItem;
@property (nonatomic) TTModeMenuItem *eastItem;
@property (nonatomic) TTModeMenuItem *westItem;
@property (nonatomic) TTModeMenuItem *southItem;

@end
