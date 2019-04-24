//
//  TTMenubarController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define STATUS_ITEM_VIEW_WIDTH 30.0

#pragma mark -

@class TTStatusItemView;

@interface TTMenubarController : NSObject

@property (nonatomic) BOOL hasActiveIcon;
@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong, readonly) TTStatusItemView *statusItemView;

@end
