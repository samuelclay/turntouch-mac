//
//  TTMenubarController.h
//  Turn Touch App
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define STATUS_ITEM_VIEW_WIDTH 24.0

#pragma mark -

@class TTStatusItemView;

@interface TTMenubarController : NSObject {

@private
    TTStatusItemView *_statusItemView;

}

@property (nonatomic) BOOL hasActiveIcon;
@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong, readonly) TTStatusItemView *statusItemView;

@end
