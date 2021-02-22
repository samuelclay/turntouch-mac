//
//  TTMenubarController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMenubarController.h"
#import "TTStatusItemView.h"

@interface TTMenubarController ()

@property (nonatomic, strong) TTStatusItemView *statusItemView;

@end

@implementation TTMenubarController

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // Install status item into the menu bar
        NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        if (@available(macOS 10.16, *)) {
//            statusItem.length -= 8;
        }
        self.statusItemView = [[TTStatusItemView alloc] initWithStatusItem:statusItem];
        self.statusItemView.action = @selector(togglePanel:);
    }
    return self;
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

#pragma mark -
#pragma mark Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

#pragma mark -

- (BOOL)hasActiveIcon
{
    return self.statusItemView.isHighlighted;
}

- (void)setHasActiveIcon:(BOOL)flag
{
    self.statusItemView.isHighlighted = flag;
}

@end
