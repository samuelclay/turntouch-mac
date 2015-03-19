//
//  TTModeTabsContainer.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeTab.h"

@class TTModeTab;

@interface TTModeTabsContainer : NSView {
    TTModeTab *northItem;
    TTModeTab *eastItem;
    TTModeTab *westItem;
    TTModeTab *southItem;
}

@property (nonatomic) TTModeTab *northItem;
@property (nonatomic) TTModeTab *eastItem;
@property (nonatomic) TTModeTab *westItem;
@property (nonatomic) TTModeTab *southItem;

@end
