//
//  TTStatusItemView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTDiamondView.h"

@class TTDiamondView;

@interface TTStatusItemView : NSView {
@private
    TTAppDelegate *appDelegate;
    NSImage *_image;
    NSImage *_alternateImage;
    TTDiamondView *_diamondView;
    NSStatusItem *_statusItem;
    BOOL _isHighlighted;
    SEL _action;
    __unsafe_unretained id _target;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *alternateImage;
@property (nonatomic, strong) TTDiamondView *diamondView;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic, readonly) NSRect globalRect;
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;


@end
